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
import '../../servers/domain/server_providers.dart';
import '../../speedtest/data/speedtest_repository.dart';
import '../../speedtest/domain/speedtest_controller.dart';
import '../../settings/domain/settings_controller.dart';
import 'session_state.dart';
import 'session_status.dart';
import 'session_meta.dart';

const _privateKeyStorageKey = 'wg_private_key';
const _sessionMetaPrefsKey = 'session_meta_v1';
const sessionDuration = Duration(hours: 1);
const _dataLimitMessage = 'Monthly data limit reached.';
const _extendDuration = Duration(hours: 1);

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
  StreamSubscription<String>? _intentSubscription;
  String? _queuedServerId;

  Future<void> _bootstrap() async {
    await _adService.initialize();
    _intentSubscription = _vpnPort.intentActions.listen(_handleIntentAction);
    await _restoreSession();
    _startTicker();
    _pendingAutoConnect = true;
  }

  void _handleIntentAction(String action) {
    if (action == 'SHOW_EXTEND_AD') {
      final current = state;
      if (current.status == SessionStatus.connected && !current.extendRequested) {
        state = current.copyWith(extendRequested: true);
      }
    }
  }

  Future<void> _restoreSession() async {
    final prefs = await _ref.read(prefsStoreProvider.future);
    final stored = prefs.getString(_sessionMetaPrefsKey);
    if (stored == null) {
      state = SessionState.initial();
      return;
    }
    try {
      final jsonMap = jsonDecode(stored) as Map<String, dynamic>;
      final meta = SessionMeta.fromJson(jsonMap);
      final connected = await _vpnPort.isConnected();
      final remaining = await _clock.remaining(
        startElapsedMs: meta.startElapsedMs,
        duration: meta.duration,
      );
      if (!connected || remaining == Duration.zero) {
        await _forceDisconnect(clearPrefs: true);
        return;
      }
      final remainingMs = remaining.inMilliseconds;
      final startInstant = DateTime.now()
          .toUtc()
          .subtract(meta.duration - Duration(milliseconds: remainingMs));
      state = state.copyWith(
        status: SessionStatus.connected,
        start: startInstant,
        duration: meta.duration,
        serverId: meta.serverId,
        meta: meta,
        sessionLocked: true,
        expired: false,
      );
      await _vpnPort.extendSession(additionalDurationMs: 0, ip: null);
      unawaited(_refreshExternalIp());
    } catch (_) {
      await prefs.remove(_sessionMetaPrefsKey);
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
      final startElapsedMs = await _clock.elapsedRealtime();
      final meta = SessionMeta(
        serverId: server.id,
        serverName: server.name,
        countryCode: server.countryCode,
        startElapsedMs: startElapsedMs,
        durationMs: sessionDuration.inMilliseconds,
      );
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
        sessionServerId: meta.serverId,
        sessionServerName: meta.serverName,
        sessionCountryCode: meta.countryCode,
        sessionStartElapsedMs: meta.startElapsedMs,
        sessionDurationMs: meta.durationMs,
      );

      final connected = await _vpnPort.connect(config);
      if (!connected) {
        state = state.copyWith(
          status: SessionStatus.error,
          errorMessage: 'Unable to establish tunnel.',
        );
        return;
      }

      final start = DateTime.now().toUtc();
      state = state.copyWith(
        status: SessionStatus.connected,
        start: start,
        duration: sessionDuration,
        serverId: server.id,
        config: config,
        expired: false,
        meta: meta,
        sessionLocked: true,
        queuedServerId: null,
        extendRequested: false,
        publicIp: null,
      );
      await _persistMeta(meta);
      await _ref.read(serverCatalogProvider.notifier).rememberSelection(server);
      _reconnectAttempts = 0;
      unawaited(_refreshExternalIp());
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
    final meta = state.meta;
    Duration? actualDuration;
    if (meta != null) {
      final nowMs = await _clock.elapsedRealtime();
      final elapsedMs = nowMs - meta.startElapsedMs;
      final clamped = elapsedMs.clamp(0, meta.durationMs) as num;
      actualDuration = Duration(milliseconds: clamped.toInt());
    }
    await _vpnPort.disconnect();
    final sessionForHistory = actualDuration != null
        ? state.copyWith(duration: actualDuration)
        : state;
    await _settings.recordSessionEnd(
      sessionForHistory,
      server: server,
      stats: stats,
    );
    await _clearPersistedMeta();
    final queued = _queuedServerId;
    _queuedServerId = null;
    state = SessionState.initial();
    if (queued != null) {
      _applyQueuedServer(queued);
    }
  }

  Future<void> extendSession(BuildContext context) async {
    final current = state;
    if (current.status != SessionStatus.connected || current.meta == null) {
      state = current.copyWith(extendRequested: false);
      return;
    }
    state = current.copyWith(extendRequested: false);
    try {
      await _adService.unlock(duration: _extendDuration, context: context);
      await _applyExtension(_extendDuration);
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  Future<void> _applyExtension(Duration extension) async {
    final meta = state.meta;
    if (meta == null) {
      return;
    }
    final extendedMeta = meta.copyWith(
      durationMs: meta.durationMs + extension.inMilliseconds,
    );
    state = state.copyWith(
      meta: extendedMeta,
      duration: extendedMeta.duration,
      sessionLocked: true,
    );
    await _persistMeta(extendedMeta);
    await _vpnPort.extendSession(
      additionalDurationMs: extension.inMilliseconds,
      ip: state.publicIp,
    );
  }

  Future<void> _refreshExternalIp() async {
    if (state.meta == null) {
      return;
    }
    try {
      final config = await _ref.read(speedTestConfigProvider.future);
      final service = _ref.read(speedTestServiceProvider);
      final ip = await service.externalIp(config.ipEndpoint);
      if (ip.isEmpty) {
        return;
      }
      state = state.copyWith(publicIp: ip);
      await _vpnPort.extendSession(additionalDurationMs: 0, ip: ip);
    } catch (_) {
      // ignore IP fetch failures; notification will reuse previous value
    }
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

  void _applyQueuedServer(String serverId) {
    final catalog = _ref.read(serverCatalogProvider);
    final next = catalog.servers.firstWhereOrNull((s) => s.id == serverId);
    if (next != null) {
      _ref.read(selectedServerProvider.notifier).select(next);
    }
  }

  Future<void> _forceDisconnect({bool clearPrefs = false}) async {
    await _vpnPort.disconnect();
    if (clearPrefs) {
      await _clearPersistedMeta();
    }
    final queued = _queuedServerId;
    _queuedServerId = null;
    state = const SessionState(status: SessionStatus.disconnected, expired: true);
    if (queued != null) {
      _applyQueuedServer(queued);
    }
  }

  Future<void> _persistMeta(SessionMeta meta) async {
    final prefs = await _ref.read(prefsStoreProvider.future);
    final jsonStr = jsonEncode(meta.toJson());
    await prefs.setString(_sessionMetaPrefsKey, jsonStr);
  }

  Future<void> _clearPersistedMeta() async {
    final prefs = await _ref.read(prefsStoreProvider.future);
    await prefs.remove(_sessionMetaPrefsKey);
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      _tickCounter += 1;
      final settings = _ref.read(settingsControllerProvider);
      if (settings.batterySaverEnabled && _tickCounter % 3 != 0) {
        return;
      }
      final current = state;
      final meta = current.meta;
      if (current.status != SessionStatus.connected || meta == null) {
        return;
      }
      final remaining = await _clock.remaining(
        startElapsedMs: meta.startElapsedMs,
        duration: meta.duration,
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
    _intentSubscription?.cancel();
    super.dispose();
  }

  Future<void> switchServer(Server server) async {
    if (state.status != SessionStatus.connected) {
      return;
    }
    if (state.sessionLocked) {
      _queuedServerId = server.id;
      state = state.copyWith(queuedServerId: server.id);
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
        meta: state.meta?.copyWith(
          serverId: server.id,
          serverName: server.name,
          countryCode: server.countryCode,
        ),
      );
      final updatedMeta = state.meta;
      if (updatedMeta != null) {
        await _persistMeta(updatedMeta);
      }
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
