import 'package:equatable/equatable.dart';

import 'auto_connect_rules.dart';
import 'protocol_config.dart';
import 'split_tunnel_config.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.protocol = const ProtocolConfig(),
    this.splitTunnel = const SplitTunnelConfig(),
    this.autoConnect = const AutoConnectRules(),
    this.batterySaverEnabled = false,
    this.networkQualityMonitoring = true,
    this.accentSeed = 'lavender',
  });

  final ProtocolConfig protocol;
  final SplitTunnelConfig splitTunnel;
  final AutoConnectRules autoConnect;
  final bool batterySaverEnabled;
  final bool networkQualityMonitoring;
  final String accentSeed;

  SettingsState copyWith({
    ProtocolConfig? protocol,
    SplitTunnelConfig? splitTunnel,
    AutoConnectRules? autoConnect,
    bool? batterySaverEnabled,
    bool? networkQualityMonitoring,
    String? accentSeed,
  }) {
    return SettingsState(
      protocol: protocol ?? this.protocol,
      splitTunnel: splitTunnel ?? this.splitTunnel,
      autoConnect: autoConnect ?? this.autoConnect,
      batterySaverEnabled: batterySaverEnabled ?? this.batterySaverEnabled,
      networkQualityMonitoring:
          networkQualityMonitoring ?? this.networkQualityMonitoring,
      accentSeed: accentSeed ?? this.accentSeed,
    );
  }

  @override
  List<Object?> get props => [
        protocol,
        splitTunnel,
        autoConnect,
        batterySaverEnabled,
        networkQualityMonitoring,
        accentSeed,
      ];
}
