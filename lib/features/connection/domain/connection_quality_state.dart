import 'package:equatable/equatable.dart';

import 'connection_quality.dart';

class ConnectionQualityState extends Equatable {
  const ConnectionQualityState({
    required this.quality,
    this.downloadMbps,
    this.uploadMbps,
    this.ping,
    this.lastSwitch,
    this.isSwitching = false,
  });

  factory ConnectionQualityState.initial() =>
      const ConnectionQualityState(quality: ConnectionQuality.offline);

  final ConnectionQuality quality;
  final double? downloadMbps;
  final double? uploadMbps;
  final Duration? ping;
  final DateTime? lastSwitch;
  final bool isSwitching;

  ConnectionQualityState copyWith({
    ConnectionQuality? quality,
    double? downloadMbps,
    double? uploadMbps,
    Duration? ping,
    DateTime? lastSwitch,
    bool? isSwitching,
  }) {
    return ConnectionQualityState(
      quality: quality ?? this.quality,
      downloadMbps: downloadMbps ?? this.downloadMbps,
      uploadMbps: uploadMbps ?? this.uploadMbps,
      ping: ping ?? this.ping,
      lastSwitch: lastSwitch ?? this.lastSwitch,
      isSwitching: isSwitching ?? this.isSwitching,
    );
  }

  @override
  List<Object?> get props => [quality, downloadMbps, uploadMbps, ping, lastSwitch, isSwitching];
}
