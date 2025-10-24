import 'dart:async';
import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/utils/iterable_extensions.dart';
import '../../../services/ads/rewarded_ad_service.dart';
import '../../../services/storage/prefs.dart';
import '../../../services/storage/secure_store_provider.dart';
import '../../../services/time/session_clock.dart';
import '../../../services/time/session_clock_provider.dart';
import '../../../services/vpn/vpn_port.dart';
import '../../../services/vpn/vpn_provider.dart';
import '../../../services/vpn/wg_config.dart';
import '../../servers/domain/server.dart';
import '../../servers/domain/server_providers.dart';
import '../../settings/domain/settings_controller.dart';
import '../../speedtest/domain/speedtest_controller.dart';
import '../../speedtest/domain/speedtest_state.dart';
import '../../usage/data_usage_controller.dart';
import 'session_meta.dart';
import 'session_state.dart';
import 'session_status.dart';

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
    _speedSubscription =
        _ref.listen<SpeedTestState>(speedTestControllerProvider, _onSpeedUpdate);
    _bootstrap();
  }

  final Ref _ref;
  final VpnPort _vpnPort;
  final RewardedAdService _adService;
  final SessionClock _clock;
  final SettingsController _settings;

  Timer? _ticker;
  StreamSubscription<String>? _intentSubscription;
  late final ProviderSubscription<SpeedTestState> _speedSubscription;
  int _reconnectAttempts = 0;
  bool _pendingAutoConnect = false;
  int _tickCounter = 0;
  SessionMeta? _activeMeta;
  Server? _queuedServer;

  Future<void> _bootstrap() async {
    await _adService.initialize();
    _intentSubscription = _vpnPort.intentActions.listen(_handleIntentAction);
    await _restoreSession();
    _startTicker();
    _pendingAutoConnect = true;
  }

  void _handleIntentAction(String action) {
    final normalized = action.toLowerCase();
    if (normalized.contains('extend')) {
      state = state.copyWith(extendRequested: true);
      return;
    }
    if (normalized.contains('disconnect')) {
      unawaited(disconnect(userInitiated: false));
    }
  }

  void _onSpeedUpdate(SpeedTestState? previous, SpeedTestState next) {
    final ip = next.ip;
    if (state.status != SessionStatus.connected || ip == null || ip.isEmpty) {
      return;
    }
    if (state.publicIp == ip) {
      return;
    }
    state = state.copyWith(publicIp: ip);
    final meta = _activeMeta;
    if (meta != null) {
      final updated = meta.copyWith(publicIp: ip);
      _activeMeta = updated;
      state = state.copyWith(meta: updated);
      unawaited(_persistMeta(updated));
      unawaited(_vpnPort.extendSession(updated.duration, publicIp: ip));
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
      final remaining = await _clock.remaining(
        startElapsedMs: meta.startElapsedMs,
        duration: meta.duration,
      );
      final connected = await _vpnPort.isConnected();
      if (!connected || remaining == Duration.zero) {
        await _forceDisconnect(clearPrefs: true);
        return;
      }
      final elapsed = meta.duration - remaining;
      final startWall = DateTime.now().toUtc().subtract(elapsed);
      _activeMeta = meta;
      state = state.copyWith(
        status: SessionStatus.connected,
        start: startWall,
        duration: meta.duration,
        startElapsedMs: meta.startElapsedMs,
        serverId: meta.serverId,
        serverName: meta.serverName,
        countryCode: meta.countryCode,
        publicIp: meta.publicIp,
        expired: false,
        sessionLocked: true,
        meta: meta,
      );
      await _vpnPort.extendSession(Duration.zero);
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
      final initialIp = _ref.read(speedTestControllerProvider).ip;
      final startElapsed = await _clock.elapsedRealtime();
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
        serverId: server.id,
        serverName: server.name,
        countryCode: server.countryCode,
        publicIp: initialIp,
        sessionStartElapsedMs: startElapsed,
        sessionDurationMs: sessionDuration.inMilliseconds,
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
      final publicIp = initialIp;
      final meta = SessionMeta(
        serverId: server.id,
        serverName: server.name,
        countryCode: server.countryCode,
        startElapsedMs: startElapsed,
        durationMs: sessionDuration.inMilliseconds,
        publicIp: publicIp,
      );
      _activeMeta = meta;
      state = state.copyWith(
        status: SessionStatus.connected,
        start: start,
        duration: sessionDuration,
        startElapsedMs: startElapsed,
        serverId: server.id,
        serverName: server.name,
        countryCode: server.countryCode,
        publicIp: publicIp,
        config: config,
        expired: false,
        sessionLocked: true,
        meta: meta,
      );
      await _persistMeta(meta);
      await _ref.read(serverCatalogProvider.notifier).rememberSelection(server);
      _reconnectAttempts = 0;
      _queuedServer = null;
    } catch (e) {
      state = state.copyWith(
        status: SessionStatus.error,
        errorMessage: 'Unable to establish tunnel.',
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
    await _clearPersistedState();
    _activeMeta = null;
    state = SessionState.initial();
    _applyQueuedServerSelection();
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
      await _clearPersistedMeta();
    }
    _activeMeta = null;
    state = SessionState.initial().copyWith(expired: true, sessionLocked: false);
    _applyQueuedServerSelection();
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

  Future<void> _clearPersistedState() async {
    await _clearPersistedMeta();
  }

  void _applyQueuedServerSelection() {
    final queued = _queuedServer;
    if (queued == null) {
      return;
    }
    _ref.read(selectedServerProvider.notifier).select(queued);
    _queuedServer = null;
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
          state.startElapsedMs == null ||
          state.duration == null) {
        return;
      }
      final remaining = await _clock.remaining(
        startElapsedMs: state.startElapsedMs!,
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

  Future<void> extendSession(BuildContext context) async {
    if (state.status != SessionStatus.connected) {
      return;
    }
    state = state.copyWith(extendRequested: false);
    try {
      await _adService.unlock(duration: _extendDuration, context: context);
      await extend(_extendDuration);
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  void requestExtension() {
    state = state.copyWith(extendRequested: true);
  }

  Future<void> extend(Duration extra) async {
    final meta = _activeMeta;
    if (state.status != SessionStatus.connected || meta == null) {
      return;
    }
    final extended = meta.extend(extra);
    _activeMeta = extended;
    state = state.copyWith(
      duration: extended.duration,
      meta: extended,
      extendRequested: false,
    );
    await _persistMeta(extended);
    await _vpnPort.extendSession(extended.duration, publicIp: extended.publicIp);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _intentSubscription?.cancel();
    _speedSubscription.close();
    super.dispose();
  }

  Future<void> switchServer(Server server) async {
    _queuedServer = server;
    if (state.status != SessionStatus.connected) {
      _applyQueuedServerSelection();
    }
  }
}

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>((ref) {
  return SessionController(ref);
});
