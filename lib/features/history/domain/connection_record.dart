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
    this.publicIp,
    this.serverIp,
    this.serverLocation,
    this.serverBandwidth,
    this.serverDownloadSpeed,
    this.serverUploadSpeed,
    this.status = ConnectionStatus.success,
  });

  final String serverId;
  final String serverName;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSeconds;
  final int bytesReceived;
  final int bytesSent;
  final String? publicIp;
  final String? serverIp;
  final String? serverLocation;
  final int? serverBandwidth;
  final int? serverDownloadSpeed;
  final int? serverUploadSpeed;
  final ConnectionStatus status;

  Map<String, dynamic> toJson() => {
        'serverId': serverId,
        'serverName': serverName,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'durationSeconds': durationSeconds,
        'bytesReceived': bytesReceived,
        'bytesSent': bytesSent,
        'publicIp': publicIp,
        'serverIp': serverIp,
        'serverLocation': serverLocation,
        'serverBandwidth': serverBandwidth,
        'serverDownloadSpeed': serverDownloadSpeed,
        'serverUploadSpeed': serverUploadSpeed,
        'status': status.name,
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
      publicIp: json['publicIp'] as String?,
      serverIp: json['serverIp'] as String?,
      serverLocation: json['serverLocation'] as String?,
      serverBandwidth: (json['serverBandwidth'] as num?)?.toInt(),
      serverDownloadSpeed: (json['serverDownloadSpeed'] as num?)?.toInt(),
      serverUploadSpeed: (json['serverUploadSpeed'] as num?)?.toInt(),
      status: _statusFromJson(json['status']),
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
        publicIp,
        serverIp,
        serverLocation,
        serverBandwidth,
        serverDownloadSpeed,
        serverUploadSpeed,
        status,
      ];
}

enum ConnectionStatus { success, failure }

ConnectionStatus _statusFromJson(dynamic value) {
  if (value is String) {
    return ConnectionStatus.values.firstWhere(
      (element) => element.name == value,
      orElse: () => ConnectionStatus.success,
    );
  }
  if (value is int && value >= 0 && value < ConnectionStatus.values.length) {
    return ConnectionStatus.values[value];
  }
  return ConnectionStatus.success;
}
