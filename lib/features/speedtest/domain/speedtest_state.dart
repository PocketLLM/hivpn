import 'package:equatable/equatable.dart';

enum SpeedTestStatus { idle, preparing, running, complete, error }

typedef SpeedSeries = List<double>;

class SpeedTestState extends Equatable {
  const SpeedTestState({
    required this.status,
    this.ping,
    this.downloadMbps = 0,
    this.uploadMbps = 0,
    this.ip,
    this.errorMessage,
    this.downloadSeries = const [],
    this.uploadSeries = const [],
    this.lastRun,
  });

  factory SpeedTestState.initial() => const SpeedTestState(status: SpeedTestStatus.idle);

  final SpeedTestStatus status;
  final Duration? ping;
  final double downloadMbps;
  final double uploadMbps;
  final String? ip;
  final String? errorMessage;
  final SpeedSeries downloadSeries;
  final SpeedSeries uploadSeries;
  final DateTime? lastRun;

  double get gaugeValue => (status == SpeedTestStatus.complete || status == SpeedTestStatus.running)
      ? (downloadMbps / 150).clamp(0, 1)
      : 0;

  SpeedTestState copyWith({
    SpeedTestStatus? status,
    Duration? ping,
    double? downloadMbps,
    double? uploadMbps,
    String? ip,
    String? errorMessage,
    SpeedSeries? downloadSeries,
    SpeedSeries? uploadSeries,
    DateTime? lastRun,
  }) {
    return SpeedTestState(
      status: status ?? this.status,
      ping: ping ?? this.ping,
      downloadMbps: downloadMbps ?? this.downloadMbps,
      uploadMbps: uploadMbps ?? this.uploadMbps,
      ip: ip ?? this.ip,
      errorMessage: errorMessage,
      downloadSeries: downloadSeries ?? this.downloadSeries,
      uploadSeries: uploadSeries ?? this.uploadSeries,
      lastRun: lastRun ?? this.lastRun,
    );
  }

  @override
  List<Object?> get props => [
        status,
        ping,
        downloadMbps,
        uploadMbps,
        ip,
        errorMessage,
        downloadSeries,
        uploadSeries,
        lastRun,
      ];
}
