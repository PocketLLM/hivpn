import 'dart:async';
import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hivpn/core/utils/iterable_extensions.dart';

import '../../../core/errors/app_error.dart';
import '../../../services/ads/rewarded_ad_service.dart';
import '../../../services/storage/prefs.dart';
import '../../../services/storage/secure_store_provider.dart';
import '../../../services/time/session_clock.dart';
import '../../../services/time/session_clock_provider.dart';
import '../../../services/vpn/vpn_port.dart';
import '../../../services/vpn/vpn_provider.dart';
import '../../../services/vpn/wg_config.dart';
import '../../usage/data_usage_controller.dart';
import '../../servers/domain/server.dart';
import '../../servers/domain/server_catalog_controller.dart';
import 'session_state.dart';
import 'session_status.dart';

const _privateKeyStorageKey = 'wg_private_key';
const _sessionPrefsKey = 'active_session';
const sessionDuration = Duration(hours: 1);
const _dataLimitMessage = 'Monthly data limit reached.';

class SessionController extends StateNotifier<SessionState> {
  SessionController(this._ref)
      : _vpnPort = _ref.read(vpnPortProvider),
        _adService = _ref.read(rewardedAdServiceProvider),
        _clock = _ref.read(sessionClockProvider),
        _settings = _ref.read(settingsControllerProvider.notifier),
        super(SessionState.initial()) {
    _bootstrap();
  }

  final Ref _ref;
  final VpnPort _vpnPort;
  final RewardedAdService _adService;
  final SessionClock _clock;
  final SettingsController _settings;

  Timer? _ticker;
  int _reconnectAttempts = 0;
  bool _pendingAutoConnect = false;
  int _tickCounter = 0;

  Future<void> _bootstrap() async {
    await _adService.initialize();
    await _restoreSession();
    _startTicker();
    _pendingAutoConnect = true;
  }

  Future<void> _restoreSession() async {
    final prefs = await _ref.read(prefsStoreProvider.future);
    final stored = prefs.getString(_sessionPrefsKey);
    if (stored == null) {
      state = SessionState.initial();
      return;
    }
    try {
      final jsonMap = jsonDecode(stored) as Map<String, dynamic>;
      final restored = SessionState.fromJson(jsonMap);
      if (restored.start == null || restored.duration == null) {
        await prefs.remove(_sessionPrefsKey);
        state = SessionState.initial();
        return;
      }
      final remaining = _clock.remaining(
        start: restored.start!,
        duration: restored.duration!,
      );
      final connected = await _vpnPort.isConnected();
      if (remaining == Duration.zero || !connected) {
        await _forceDisconnect(clearPrefs: true);
        return;
      }
      state = restored.copyWith(
        status: SessionStatus.connected,
        duration: restored.duration,
        expired: false,
      );
    } catch (_) {
      await prefs.remove(_sessionPrefsKey);
      state = SessionState.initial();
    }
  }

  Future<String> _getOrCreatePrivateKey() async {
    final store = _ref.read(secureStoreProvider);
    final existing = await store.read(_privateKeyStorageKey);
    if (existing != null) {
      return existing;
    }
    final keyPair = await X25519().newKeyPair();
    final privateBytes = await keyPair.extractPrivateKeyBytes();
    final privateKey = base64Encode(privateBytes);
    await store.write(_privateKeyStorageKey, privateKey);
    return privateKey;
  }

  Future<void> connect({
    required BuildContext context,
    required Server server,
  }) async {
    if (state.status == SessionStatus.connected) {
      throw const AppError('Already connected.');
    }
    final settingsState = _ref.read(settingsControllerProvider);
    if (!settingsState.protocol.protocol.isSupported) {
      state = state.copyWith(
        status: SessionStatus.error,
        errorMessage: 'Protocol not supported yet. Please select WireGuard.',
      );
      return;
    }
    state = state.copyWith(
      status: SessionStatus.preparing,
      errorMessage: null,
    );

    try {
      await _adService.unlock(duration: sessionDuration, context: context);
    } catch (error) {
      state = state.copyWith(
        status: SessionStatus.disconnected,
        errorMessage: 'Ad must be completed to connect.',
      );
      return;
    }

    final prepared = await _vpnPort.prepare();
    if (!prepared) {
      state = state.copyWith(
        status: SessionStatus.error,
        errorMessage: 'VPN permission required.',
      );
      return;
    }

    state = state.copyWith(status: SessionStatus.connecting);

    try {
      final privateKey = await _getOrCreatePrivateKey();

      final dnsServers = settingsState.protocol.resolvedDnsServers;
      final config = WgConfig(
        interfacePrivateKey: privateKey,
        interfaceDns: dnsServers.isNotEmpty ? dnsServers.join(',') : null,
        peerPublicKey: server.publicKey,
        peerAllowedIps: server.allowedIps,
        peerEndpoint: server.endpoint,
        peerPersistentKeepalive: settingsState.protocol.keepaliveSeconds,
        mtu: settingsState.protocol.mtu,
        protocol: settingsState.protocol.protocol.name,
        dnsServers: dnsServers,
        splitTunnelEnabled: settingsState.splitTunnel.isEnabled,
        splitTunnelPackages:
            settingsState.splitTunnel.selectedPackages.toList(),
        splitTunnelMode: settingsState.splitTunnel.mode.name,
        connectOnAppLaunch: settingsState.autoConnect.connectOnLaunch,
        connectOnBoot: settingsState.autoConnect.connectOnBoot,
        reconnectOnNetworkChange:
            settingsState.autoConnect.reconnectOnNetworkChange,
      );

      final connected = await _vpnPort.connect(config);
      if (!connected) {
        state = state.copyWith(
          status: SessionStatus.error,
          errorMessage: 'Unable to establish tunnel.',
        );
        return;
      }

      final start = _clock.now();
      state = state.copyWith(
        status: SessionStatus.connected,
        start: start,
        duration: sessionDuration,
        serverId: server.id,
        config: config,
        expired: false,
      );
      await _persistState();
      await _ref.read(serverCatalogProvider.notifier).rememberSelection(server);
      _reconnectAttempts = 0;
    } catch (e) {
      state = state.copyWith(
        status: SessionStatus.error,
        errorMessage: 'Connection failed: $e',
      );
    }
  }

  Future<void> disconnect({bool userInitiated = true}) async {
    final stats = await _vpnPort.getTunnelStats();
    final server = _resolveHistoryServer();
    await _vpnPort.disconnect();
    await _settings.recordSessionEnd(
      state,
      server: server,
      stats: stats,
    );
    await _clearPersistedState();
    state = SessionState.initial();
  }

  Server? _resolveHistoryServer() {
    final id = state.serverId;
    final catalog = _ref.read(serverCatalogProvider);
    if (id != null) {
      final match = catalog.servers.firstWhereOrNull((s) => s.id == id);
      if (match != null) {
        return match;
      }
    }
    return _ref.read(selectedServerProvider);
  }

  Future<void> _forceDisconnect({bool clearPrefs = false}) async {
    await _vpnPort.disconnect();
    if (clearPrefs) {
      await _clearPersistedState();
    }
    state = const SessionState(status: SessionStatus.disconnected, expired: true);
  }

  Future<void> _persistState() async {
    final prefs = await _ref.read(prefsStoreProvider.future);
    final jsonStr = jsonEncode(state.copyWith(config: null).toJson());
    await prefs.setString(_sessionPrefsKey, jsonStr);
  }

  Future<void> _clearPersistedState() async {
    final prefs = await _ref.read(prefsStoreProvider.future);
    await prefs.remove(_sessionPrefsKey);
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      _tickCounter += 1;
      final settings = _ref.read(settingsControllerProvider);
      if (settings.batterySaverEnabled && _tickCounter % 3 != 0) {
        return;
      }
      if (state.status != SessionStatus.connected ||
          state.start == null ||
          state.duration == null) {
        return;
      }
      final remaining = _clock.remaining(
        start: state.start!,
        duration: state.duration!,
      );
      if (remaining <= Duration.zero) {
        await _forceDisconnect(clearPrefs: true);
        return;
      }
      await _ref.read(dataUsageControllerProvider.notifier).recordTickUsage();
      final usage = _ref.read(dataUsageControllerProvider);
      if (usage.limitExceeded) {
        await _forceDisconnect(clearPrefs: true);
        state = state.copyWith(
          status: SessionStatus.error,
          errorMessage: _dataLimitMessage,
        );
      }
    });
  }

  Future<void> _attemptReconnect() async {
    if (state.config == null) return;
    if (_reconnectAttempts > 5) {
      state = state.copyWith(
        status: SessionStatus.error,
        errorMessage: 'Connection lost. Manual reconnect required.',
      );
      return;
    }
    _reconnectAttempts += 1;
    final backoff = Duration(seconds: 2 << (_reconnectAttempts - 1));
    await Future<void>.delayed(backoff);
    final success = await _vpnPort.connect(state.config!);
    if (!success) {
      return;
    }
    _reconnectAttempts = 0;
  }

  Future<void> autoConnectIfEnabled({required BuildContext context}) async {
    if (!_pendingAutoConnect) return;
    _pendingAutoConnect = false;
    final settings = _ref.read(settingsControllerProvider);
    if (!settings.autoConnect.connectOnLaunch) {
      return;
    }
    final server = _ref.read(selectedServerProvider);
    if (server == null) {
      return;
    }
    if (state.status == SessionStatus.connected) {
      return;
    }
    await connect(context: context, server: server);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> switchServer(Server server) async {
    if (state.status != SessionStatus.connected) {
      return;
    }
    try {
      final privateKey = await _getOrCreatePrivateKey();
      await _vpnPort.disconnect();
      final config = WgConfig(
        interfacePrivateKey: privateKey,
        peerPublicKey: server.publicKey,
        peerAllowedIps: server.allowedIps,
        peerEndpoint: server.endpoint,
        peerPersistentKeepalive: server.keepaliveSeconds,
        mtu: server.mtu,
      );
      final connected = await _vpnPort.connect(config);
      if (!connected) {
        state = state.copyWith(
          status: SessionStatus.error,
          errorMessage: 'Unable to switch server automatically.',
        );
        return;
      }
      state = state.copyWith(
        status: SessionStatus.connected,
        serverId: server.id,
        config: config,
        errorMessage: null,
      );
      await _persistState();
    } catch (e) {
      state = state.copyWith(
        status: SessionStatus.error,
        errorMessage: 'Automatic switch failed: $e',
      );
    }
  }
}

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>((ref) {
  return SessionController(ref);
});
