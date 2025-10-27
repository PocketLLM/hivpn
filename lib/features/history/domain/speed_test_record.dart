import 'package:equatable/equatable.dart';

class SpeedTestRecord extends Equatable {
  const SpeedTestRecord({
    required this.timestamp,
    required this.downloadMbps,
    required this.uploadMbps,
    this.pingMs,
    this.ip,
  });

  final DateTime timestamp;
  final double downloadMbps;
  final double uploadMbps;
  final int? pingMs;
  final String? ip;

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'download': downloadMbps,
        'upload': uploadMbps,
        'pingMs': pingMs,
        'ip': ip,
      };

  factory SpeedTestRecord.fromJson(Map<String, dynamic> json) {
    return SpeedTestRecord(
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      downloadMbps: (json['download'] as num?)?.toDouble() ?? 0,
      uploadMbps: (json['upload'] as num?)?.toDouble() ?? 0,
      pingMs: (json['pingMs'] as num?)?.toInt(),
      ip: json['ip'] as String?,
    );
  }

  @override
  List<Object?> get props => [timestamp, downloadMbps, uploadMbps, pingMs, ip];
}
