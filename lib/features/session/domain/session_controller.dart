import 'dart:async';
import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../services/ads/rewarded_ad_service.dart';
import '../../../services/storage/prefs.dart';
import '../../../services/storage/secure_store_provider.dart';
import '../../../services/time/session_clock.dart';
import '../../../services/time/session_clock_provider.dart';
import '../../../services/vpn/vpn_port.dart';
import '../../../services/vpn/vpn_provider.dart';
import '../../../services/vpn/wg_config.dart';
import '../../servers/domain/server.dart';
import 'session_state.dart';
import 'session_status.dart';

const _privateKeyStorageKey = 'wg_private_key';
const _sessionPrefsKey = 'active_session';
const sessionDuration = Duration(hours: 1);

class SessionController extends StateNotifier<SessionState> {
  SessionController(this._ref)
      : _vpnPort = _ref.read(vpnPortProvider),
        _adService = _ref.read(rewardedAdServiceProvider),
        _clock = _ref.read(sessionClockProvider),
        super(SessionState.initial()) {
    _bootstrap();
  }

  final Ref _ref;
  final VpnPort _vpnPort;
  final RewardedAdService _adService;
  final SessionClock _clock;

  Timer? _ticker;

  Future<void> _bootstrap() async {
    await _adService.initialize();
    await _restoreSession();
    _startTicker();
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
    } catch (e) {
      state = state.copyWith(
        status: SessionStatus.error,
        errorMessage: 'Connection failed: $e',
      );
    }
  }

  Future<void> disconnect({bool userInitiated = true}) async {
    await _vpnPort.disconnect();
    await _clearPersistedState();
    state = SessionState.initial();
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
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>((ref) {
  return SessionController(ref);
});
