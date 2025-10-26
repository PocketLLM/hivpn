import 'dart:convert';

/// Represents the nearest ndt7 server returned by the Locate API.
class LocateResult {
  const LocateResult({
    required this.downloadUrl,
    required this.uploadUrl,
    required this.serverCity,
    required this.serverCountry,
  });

  factory LocateResult.fromJson(Map<String, dynamic> json) {
    final urls = (json['urls'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final download = urls.values.cast<String?>().firstWhere(
          (value) => value != null && value.contains('/ndt/v7/download'),
          orElse: () => null,
        );
    final upload = urls.values.cast<String?>().firstWhere(
          (value) => value != null && value.contains('/ndt/v7/upload'),
          orElse: () => null,
        );
    if (download == null || upload == null) {
      throw const FormatException('Missing ndt7 URLs in locate response');
    }

    final location = json['location'] as Map<String, dynamic>?;
    return LocateResult(
      downloadUrl: Uri.parse(download),
      uploadUrl: Uri.parse(upload),
      serverCity: (location?['city'] as String?)?.trim() ?? '',
      serverCountry: (location?['country'] as String?)?.trim() ?? '',
    );
  }

  final Uri downloadUrl;
  final Uri uploadUrl;
  final String serverCity;
  final String serverCountry;
}

/// Summary of a full ndt7 speed test.
class TestSummary {
  const TestSummary({
    required this.downloadMbps,
    required this.uploadMbps,
    required this.minRttMs,
    required this.lossRate,
    required this.serverCity,
    required this.serverCountry,
    required this.timestampUtc,
    required this.downloadDuration,
    required this.uploadDuration,
  });

  final double downloadMbps;
  final double uploadMbps;
  final double? minRttMs;
  final double? lossRate;
  final String serverCity;
  final String serverCountry;
  final DateTime timestampUtc;
  final Duration downloadDuration;
  final Duration uploadDuration;
}

/// Progress phases emitted during a test.
enum Ndt7ProgressPhase {
  idle,
  locating,
  downloadWarmup,
  download,
  uploadWarmup,
  upload,
  complete,
  error,
}

/// Lightweight event describing the current measurement progress.
class Ndt7Progress {
  const Ndt7Progress({
    required this.phase,
    this.mbps,
    this.elapsedSeconds,
    this.summary,
    this.error,
  });

  const Ndt7Progress.idle() : this(phase: Ndt7ProgressPhase.idle);

  factory Ndt7Progress.locating() {
    return const Ndt7Progress(phase: Ndt7ProgressPhase.locating);
  }

  factory Ndt7Progress.update(
    Ndt7ProgressPhase phase, {
    double? mbps,
    double? elapsedSeconds,
  }) {
    return Ndt7Progress(
      phase: phase,
      mbps: mbps,
      elapsedSeconds: elapsedSeconds,
    );
  }

  factory Ndt7Progress.complete(TestSummary summary) {
    return Ndt7Progress(
      phase: Ndt7ProgressPhase.complete,
      summary: summary,
    );
  }

  factory Ndt7Progress.failure(Ndt7Exception error) {
    return Ndt7Progress(
      phase: Ndt7ProgressPhase.error,
      error: error,
    );
  }

  final Ndt7ProgressPhase phase;
  final double? mbps;
  final double? elapsedSeconds;
  final TestSummary? summary;
  final Ndt7Exception? error;
}

/// Error categories for ndt7 failures.
enum Ndt7ErrorCode {
  timeout,
  invalidToken,
  tlsFailure,
  noResult,
  network,
}

/// Exception thrown when an ndt7 run fails.
class Ndt7Exception implements Exception {
  const Ndt7Exception(this.code, this.message);

  final Ndt7ErrorCode code;
  final String message;

  @override
  String toString() => 'Ndt7Exception(code: $code, message: $message)';
}

/// Server-side metrics exposed through ndt7 messages.
class Ndt7ServerMetrics {
  const Ndt7ServerMetrics({
    this.meanThroughputMbps,
    this.minRttMs,
    this.lossRate,
  });

  final double? meanThroughputMbps;
  final double? minRttMs;
  final double? lossRate;

  Ndt7ServerMetrics merge(Ndt7ServerMetrics other) {
    return Ndt7ServerMetrics(
      meanThroughputMbps: other.meanThroughputMbps ?? meanThroughputMbps,
      minRttMs: other.minRttMs ?? minRttMs,
      lossRate: other.lossRate ?? lossRate,
    );
  }

  static Ndt7ServerMetrics fromJson(Map<String, dynamic> message) {
    double? throughput;
    double? minRtt;
    double? loss;

    void visit(dynamic value) {
      if (value is Map<String, dynamic>) {
        if (value['MeanThroughputMbps'] is num) {
          throughput = (value['MeanThroughputMbps'] as num).toDouble();
        }
        if (value['MinRTT'] is num) {
          final raw = (value['MinRTT'] as num).toDouble();
          // Values from TCP_INFO are provided in microseconds.
          minRtt = raw >= 1000 ? raw / 1000 : raw;
        }
        if (value['LossRate'] is num) {
          loss = (value['LossRate'] as num).toDouble();
        }
        for (final entry in value.values) {
          visit(entry);
        }
      } else if (value is List<dynamic>) {
        for (final element in value) {
          visit(element);
        }
      }
    }

    visit(message);
    return Ndt7ServerMetrics(
      meanThroughputMbps: throughput,
      minRttMs: minRtt,
      lossRate: loss,
    );
  }
}

/// Utility to compute throughput in Mbps from bytes and elapsed microseconds.
double computeThroughputMbps(int bytes, int elapsedMicros) {
  if (bytes <= 0 || elapsedMicros <= 0) {
    return 0;
  }
  return (bytes * 8) / elapsedMicros;
}

/// Parse a Locate API payload into a [LocateResult].
LocateResult parseLocatePayload(String body) {
  final dynamic decoded = jsonDecode(body);
  if (decoded is Map<String, dynamic>) {
    final results = decoded['results'];
    if (results is List && results.isNotEmpty) {
      final first = results.first;
      if (first is Map<String, dynamic>) {
        return LocateResult.fromJson(first);
      }
    }
  }
  throw const FormatException('Unexpected locate response payload');
}
