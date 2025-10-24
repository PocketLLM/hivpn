import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../servers/domain/server.dart';
import '../../servers/domain/server_providers.dart';
import '../../session/domain/session_controller.dart';
import '../../session/domain/session_state.dart';
import '../../session/domain/session_status.dart';
import '../../settings/domain/preferences_controller.dart';
import '../../speedtest/domain/speedtest_controller.dart';
import '../../speedtest/domain/speedtest_state.dart';
import 'connection_quality.dart';
import 'connection_quality_state.dart';

class ConnectionQualityController
    extends StateNotifier<ConnectionQualityState> {
  ConnectionQualityController(this._ref)
      : super(ConnectionQualityState.initial()) {
    _sessionSub = _ref.listen(sessionControllerProvider, _handleSession,
        fireImmediately: true);
    _speedSub = _ref.listen(speedTestControllerProvider, _handleSpeed,
        fireImmediately: true);
  }

  final Ref _ref;
  late final ProviderSubscription<SessionState> _sessionSub;
  late final ProviderSubscription<SpeedTestState> _speedSub;

  void _handleSession(SessionState? previous, SessionState next) {
    _evaluate(next, _ref.read(speedTestControllerProvider));
  }

  void _handleSpeed(SpeedTestState? previous, SpeedTestState next) {
    _evaluate(_ref.read(sessionControllerProvider), next);
  }

  void refresh() {
    _evaluate(
      _ref.read(sessionControllerProvider),
      _ref.read(speedTestControllerProvider),
    );
  }

  void _evaluate(SessionState session, SpeedTestState speed) {
    ConnectionQuality quality;
    double? download = speed.downloadMbps == 0 ? null : speed.downloadMbps;
    double? upload = speed.uploadMbps == 0 ? null : speed.uploadMbps;
    final ping = speed.ping;

    if (session.status != SessionStatus.connected) {
      quality = ConnectionQuality.offline;
    } else {
      final downloadScore = download ?? 0;
      final pingMs = ping?.inMilliseconds ?? 999;
      if (downloadScore >= 50 && pingMs <= 80) {
        quality = ConnectionQuality.excellent;
      } else if (downloadScore >= 25 && pingMs <= 150) {
        quality = ConnectionQuality.good;
      } else if (downloadScore >= 10 && pingMs <= 250) {
        quality = ConnectionQuality.fair;
      } else {
        quality = ConnectionQuality.poor;
      }
    }

    state = state.copyWith(
      quality: quality,
      downloadMbps: download,
      uploadMbps: upload,
      ping: ping,
    );

    if (quality == ConnectionQuality.poor) {
      _maybeAutoSwitch();
    }
  }

  Future<void> _maybeAutoSwitch() async {
    if (state.isSwitching) {
      return;
    }
    final enabled = _ref
        .read(preferencesControllerProvider.select((value) => value.autoServerSwitch));
    if (!enabled) {
      return;
    }
    final lastSwitch = state.lastSwitch;
    if (lastSwitch != null &&
        DateTime.now().difference(lastSwitch) < const Duration(minutes: 5)) {
      return;
    }

    final servers = _ref.read(serversProvider);
    if (servers.isEmpty) {
      return;
    }
    final current = _ref.read(selectedServerProvider);
    final target = _chooseNextServer(servers, current);
    if (target == null || (current != null && current.id == target.id)) {
      return;
    }

    state = state.copyWith(isSwitching: true);
    await _ref.read(sessionControllerProvider.notifier).switchServer(target);
    state = state.copyWith(
      lastSwitch: DateTime.now(),
      isSwitching: false,
    );
  }

  Server? _chooseNextServer(List<Server> servers, Server? current) {
    if (servers.length <= 1) {
      return servers.isNotEmpty ? servers.first : null;
    }
    if (current == null) {
      return servers.first;
    }
    final index = servers.indexWhere((element) => element.id == current.id);
    if (index == -1) {
      return servers.first;
    }
    final nextIndex = (index + 1) % servers.length;
    if (nextIndex == index) {
      return current;
    }
    return servers[nextIndex];
  }

  @override
  void dispose() {
    _sessionSub.close();
    _speedSub.close();
    super.dispose();
  }
}

final connectionQualityControllerProvider =
    StateNotifierProvider<ConnectionQualityController, ConnectionQualityState>(
        (ref) {
  return ConnectionQualityController(ref);
});
