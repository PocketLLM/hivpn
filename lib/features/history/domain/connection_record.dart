import 'package:equatable/equatable.dart';

class ConnectionRecord extends Equatable {
  const ConnectionRecord({
    required this.serverId,
    required this.serverName,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.bytesReceived,
    required this.bytesSent,
  });

  final String serverId;
  final String serverName;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSeconds;
  final int bytesReceived;
  final int bytesSent;

  Map<String, dynamic> toJson() => {
        'serverId': serverId,
        'serverName': serverName,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'durationSeconds': durationSeconds,
        'bytesReceived': bytesReceived,
        'bytesSent': bytesSent,
      };

  factory ConnectionRecord.fromJson(Map<String, dynamic> json) {
    return ConnectionRecord(
      serverId: json['serverId'] as String? ?? 'unknown',
      serverName: json['serverName'] as String? ?? 'Unknown',
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      endedAt: DateTime.tryParse(json['endedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      bytesReceived: (json['bytesReceived'] as num?)?.toInt() ?? 0,
      bytesSent: (json['bytesSent'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        serverId,
        serverName,
        startedAt,
        endedAt,
        durationSeconds,
        bytesReceived,
        bytesSent,
      ];
}
