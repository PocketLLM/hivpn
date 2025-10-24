import 'package:equatable/equatable.dart';

class SessionMeta extends Equatable {
  const SessionMeta({
    required this.serverId,
    required this.serverName,
    required this.countryCode,
    required this.startElapsedMs,
    required this.durationMs,
  });

  final String serverId;
  final String serverName;
  final String countryCode;
  final int startElapsedMs;
  final int durationMs;

  Duration get duration => Duration(milliseconds: durationMs);

  SessionMeta copyWith({
    String? serverId,
    String? serverName,
    String? countryCode,
    int? startElapsedMs,
    int? durationMs,
  }) {
    return SessionMeta(
      serverId: serverId ?? this.serverId,
      serverName: serverName ?? this.serverName,
      countryCode: countryCode ?? this.countryCode,
      startElapsedMs: startElapsedMs ?? this.startElapsedMs,
      durationMs: durationMs ?? this.durationMs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serverId': serverId,
      'serverName': serverName,
      'countryCode': countryCode,
      'startElapsedMs': startElapsedMs,
      'durationMs': durationMs,
    };
  }

  factory SessionMeta.fromJson(Map<String, dynamic> json) {
    return SessionMeta(
      serverId: json['serverId'] as String,
      serverName: json['serverName'] as String,
      countryCode: json['countryCode'] as String,
      startElapsedMs: (json['startElapsedMs'] as num).toInt(),
      durationMs: (json['durationMs'] as num).toInt(),
    );
  }

  @override
  List<Object?> get props => [
        serverId,
        serverName,
        countryCode,
        startElapsedMs,
        durationMs,
      ];
}
