import 'package:equatable/equatable.dart';

class SessionMeta extends Equatable {
  const SessionMeta({
    required this.serverId,
    required this.serverName,
    required this.countryCode,
    required this.startElapsedMs,
    required this.durationMs,
    this.publicIp,
  });

  final String serverId;
  final String serverName;
  final String countryCode;
  final int startElapsedMs;
  final int durationMs;
  final String? publicIp;

  Duration get duration => Duration(milliseconds: durationMs);

  SessionMeta copyWith({
    String? serverId,
    String? serverName,
    String? countryCode,
    int? startElapsedMs,
    int? durationMs,
    String? publicIp,
  }) {
    return SessionMeta(
      serverId: serverId ?? this.serverId,
      serverName: serverName ?? this.serverName,
      countryCode: countryCode ?? this.countryCode,
      startElapsedMs: startElapsedMs ?? this.startElapsedMs,
      durationMs: durationMs ?? this.durationMs,
      publicIp: publicIp ?? this.publicIp,
    );
  }

  SessionMeta extend(Duration extra) {
    return copyWith(durationMs: durationMs + extra.inMilliseconds);
  }

  Map<String, dynamic> toJson() {
    return {
      'serverId': serverId,
      'serverName': serverName,
      'countryCode': countryCode,
      'startElapsedMs': startElapsedMs,
      'durationMs': durationMs,
      if (publicIp != null) 'publicIp': publicIp,
    };
  }

  factory SessionMeta.fromJson(Map<String, dynamic> json) {
    return SessionMeta(
      serverId: json['serverId'] as String,
      serverName: json['serverName'] as String,
      countryCode: json['countryCode'] as String,
      startElapsedMs: (json['startElapsedMs'] as num).toInt(),
      durationMs: (json['durationMs'] as num).toInt(),
      publicIp: json['publicIp'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        serverId,
        serverName,
        countryCode,
        startElapsedMs,
        durationMs,
        publicIp,
      ];
}
