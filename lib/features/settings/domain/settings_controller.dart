import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../history/domain/connection_history_notifier.dart';
import '../../history/domain/connection_record.dart';
import '../../servers/domain/server.dart';
import '../../session/domain/session_state.dart';
import 'auto_connect_rules.dart';
import 'protocol_config.dart';
import 'settings_state.dart';
import 'split_tunnel_config.dart';
import '../data/settings_repository.dart';
import 'vpn_protocol.dart';

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController(this._ref, this._repository)
      : super(const SettingsState()) {
    _restore();
  }

  final Ref _ref;
  final SettingsRepository? _repository;

  Future<void> _restore() async {
    if (_repository == null) return;
    final protocol = _repository!.loadProtocol();
    final splitTunnel = _repository!.loadSplitTunnel();
    final autoConnect = _repository!.loadAutoConnect();
    final batterySaver = _repository!.loadBatterySaver();
    final networkQuality = _repository!.loadNetworkQuality();
    final accent = _repository!.loadAccent() ?? 'lavender';
    state = state.copyWith(
      protocol: protocol,
      splitTunnel: splitTunnel,
      autoConnect: autoConnect,
      batterySaverEnabled: batterySaver,
      networkQualityMonitoring: networkQuality,
      accentSeed: accent,
    );
  }

  Future<void> updateProtocol(ProtocolConfig config) async {
    state = state.copyWith(protocol: config);
    await _repository?.saveProtocol(config);
  }

  Future<void> setProtocol(VpnProtocol protocol) =>
      updateProtocol(state.protocol.copyWith(protocol: protocol));

  Future<void> setMtu(int mtu) =>
      updateProtocol(state.protocol.copyWith(mtu: mtu));

  Future<void> setKeepalive(int seconds) =>
      updateProtocol(state.protocol.copyWith(keepaliveSeconds: seconds));

  Future<void> setDnsOption(VpnDnsOption option) async {
    if (option == VpnDnsOption.custom &&
        state.protocol.customDnsServers.isEmpty) {
      await updateProtocol(state.protocol
          .copyWith(dnsOption: option, customDnsServers: const ['8.8.8.8']));
    } else {
      await updateProtocol(state.protocol.copyWith(dnsOption: option));
    }
  }

  Future<void> setCustomDns(List<String> servers) => updateProtocol(
        state.protocol.copyWith(
          dnsOption: VpnDnsOption.custom,
          customDnsServers: servers,
        ),
      );

  Future<void> updateSplitTunnel(SplitTunnelConfig config) async {
    state = state.copyWith(splitTunnel: config);
    await _repository?.saveSplitTunnel(config);
  }

  Future<void> toggleSplitTunnel(bool enabled) async {
    final mode = enabled
        ? SplitTunnelMode.selectedApps
        : SplitTunnelMode.allTraffic;
    await updateSplitTunnel(state.splitTunnel.copyWith(mode: mode));
  }

  Future<void> setSelectedPackages(Set<String> packages) async {
    await updateSplitTunnel(state.splitTunnel.copyWith(
      selectedPackages: packages,
    ));
  }

  Future<void> updateAutoConnect(AutoConnectRules rules) async {
    state = state.copyWith(autoConnect: rules);
    await _repository?.saveAutoConnect(rules);
  }

  Future<void> setAutoConnect({
    bool? onLaunch,
    bool? onBoot,
    bool? onNetworkChange,
  }) async {
    await updateAutoConnect(state.autoConnect.copyWith(
      connectOnLaunch: onLaunch,
      connectOnBoot: onBoot,
      reconnectOnNetworkChange: onNetworkChange,
    ));
  }

  Future<void> setBatterySaver(bool value) async {
    state = state.copyWith(batterySaverEnabled: value);
    await _repository?.saveBatterySaver(value);
  }

  Future<void> setNetworkQuality(bool value) async {
    state = state.copyWith(networkQualityMonitoring: value);
    await _repository?.saveNetworkQuality(value);
  }

  Future<void> setAccentSeed(String seed) async {
    state = state.copyWith(accentSeed: seed);
    await _repository?.saveAccent(seed);
  }

  Future<void> recordSessionEnd(SessionState session,
      {required Server? server, required Map<String, dynamic> stats}) async {
    if (server == null) return;
    final history = _ref.read(connectionHistoryProvider.notifier);
    final startedAt = session.start!;
    final endedAt = DateTime.now().toUtc();
    final bytesRx = (stats['rxBytes'] as num?)?.toInt() ?? 0;
    final bytesTx = (stats['txBytes'] as num?)?.toInt() ?? 0;
    await history.addRecord(
      ConnectionRecord(
        serverId: server.id,
        serverName: server.name,
        startedAt: startedAt,
        endedAt: endedAt,
        durationSeconds: duration.inSeconds,
        bytesReceived: bytesRx,
        bytesSent: bytesTx,
      ),
    );
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
  return SettingsController(
    ref,
    ref.watch(settingsRepositoryProvider),
  );
});
