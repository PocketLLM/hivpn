import 'package:equatable/equatable.dart';

class AutoConnectRules extends Equatable {
  const AutoConnectRules({
    this.connectOnLaunch = false,
    this.connectOnBoot = false,
    this.reconnectOnNetworkChange = true,
  });

  final bool connectOnLaunch;
  final bool connectOnBoot;
  final bool reconnectOnNetworkChange;

  AutoConnectRules copyWith({
    bool? connectOnLaunch,
    bool? connectOnBoot,
    bool? reconnectOnNetworkChange,
  }) {
    return AutoConnectRules(
      connectOnLaunch: connectOnLaunch ?? this.connectOnLaunch,
      connectOnBoot: connectOnBoot ?? this.connectOnBoot,
      reconnectOnNetworkChange:
          reconnectOnNetworkChange ?? this.reconnectOnNetworkChange,
    );
  }

  Map<String, dynamic> toJson() => {
        'connectOnLaunch': connectOnLaunch,
        'connectOnBoot': connectOnBoot,
        'reconnectOnNetworkChange': reconnectOnNetworkChange,
      };

  factory AutoConnectRules.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AutoConnectRules();
    }
    return AutoConnectRules(
      connectOnLaunch: json['connectOnLaunch'] as bool? ?? false,
      connectOnBoot: json['connectOnBoot'] as bool? ?? false,
      reconnectOnNetworkChange:
          json['reconnectOnNetworkChange'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        connectOnLaunch,
        connectOnBoot,
        reconnectOnNetworkChange,
      ];
}
