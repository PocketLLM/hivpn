import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:web_socket_channel/status.dart' as websocket_status;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'ndt7_models.dart';

const _defaultLocateEndpoint =
    'https://locate.measurementlab.net/v2/nearest/ndt/ndt7';
const _defaultUserAgent = 'hivpn-ndt7/1.0';
const _inactivityTimeout = Duration(seconds: 6);
const _uploadChunkSize = 64 * 1024;

enum _MeasurementDirection { download, upload }

class _MeasurementRequest {
  const _MeasurementRequest({
    required this.url,
    required this.warmupMicros,
    required this.measureMicros,
    required this.direction,
    required this.progressPort,
  });

  final String url;
  final int warmupMicros;
  final int measureMicros;
  final _MeasurementDirection direction;
  final SendPort progressPort;
}

class _MeasurementResult {
  const _MeasurementResult({
    required this.direction,
    required this.clientMbps,
    required this.duration,
    this.serverMbps,
    this.minRttMs,
    this.lossRate,
  });

  factory _MeasurementResult.fromMap(Map<dynamic, dynamic> data) {
    final direction = data['direction'] as String;
    return _MeasurementResult(
      direction: direction == 'download'
          ? _MeasurementDirection.download
          : _MeasurementDirection.upload,
      clientMbps: (data['clientMbps'] as num?)?.toDouble() ?? 0,
      duration: Duration(microseconds: data['durationMicros'] as int? ?? 0),
      serverMbps: (data['serverMbps'] as num?)?.toDouble(),
      minRttMs: (data['minRttMs'] as num?)?.toDouble(),
      lossRate: (data['lossRate'] as num?)?.toDouble(),
    );
  }

  final _MeasurementDirection direction;
  final double clientMbps;
  final Duration duration;
  final double? serverMbps;
  final double? minRttMs;
  final double? lossRate;
}

/// Service that performs ndt7 discovery and measurement flows.
class Ndt7Service {
  Ndt7Service({
    http.Client? client,
    Uri? locateEndpoint,
    this.userAgent = _defaultUserAgent,
  })  : _client = client ?? http.Client(),
        _locateEndpoint = locateEndpoint ?? Uri.parse(_defaultLocateEndpoint);

  final http.Client _client;
  final Uri _locateEndpoint;
  final String userAgent;
  final StreamController<Ndt7Progress> _progressController =
      StreamController<Ndt7Progress>.broadcast();

  Stream<Ndt7Progress> get progressStream => _progressController.stream;

  Future<LocateResult> locate({Duration timeout = const Duration(seconds: 5)}) async {
    try {
      final response = await _client
          .get(
            _locateEndpoint,
            headers: {
              HttpHeaders.acceptHeader: 'application/json',
              HttpHeaders.userAgentHeader: userAgent,
            },
          )
          .timeout(timeout);

      if (response.statusCode == HttpStatus.noContent) {
        throw const Ndt7Exception(
          Ndt7ErrorCode.network,
          'No ndt7 servers available right now',
        );
      }

      if (response.statusCode != HttpStatus.ok) {
        throw Ndt7Exception(
          Ndt7ErrorCode.network,
          'Failed to locate ndt7 server (${response.statusCode})',
        );
      }

      return parseLocatePayload(response.body);
    } on TimeoutException {
      throw const Ndt7Exception(
        Ndt7ErrorCode.timeout,
        'Timed out locating an ndt7 server',
      );
    } on http.ClientException catch (error) {
      throw Ndt7Exception(
        Ndt7ErrorCode.network,
        'Failed to contact locate API: ${error.message}',
      );
    } on SocketException catch (error) {
      throw Ndt7Exception(
        Ndt7ErrorCode.network,
        'Network error while locating ndt7 server: ${error.message}',
      );
    }
  }

  Future<_MeasurementResult> runDownload(
    Uri url,
    Duration warmup,
    Duration measure,
  ) {
    return _runMeasurement(
      url,
      warmup,
      measure,
      _MeasurementDirection.download,
    );
  }

  Future<_MeasurementResult> runUpload(
    Uri url,
    Duration warmup,
    Duration measure,
  ) {
    return _runMeasurement(
      url,
      warmup,
      measure,
      _MeasurementDirection.upload,
    );
  }

  Future<TestSummary> runTest({
    Duration warmup = const Duration(seconds: 3),
    Duration measure = const Duration(seconds: 10),
  }) async {
    _progressController.add(Ndt7Progress.locating());

    LocateResult? locateResult;
    Ndt7Exception? lastError;

    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        locateResult ??= await locate();

        final downloadResult = await runDownload(
          locateResult.downloadUrl,
          warmup,
          measure,
        );
        final uploadResult = await runUpload(
          locateResult.uploadUrl,
          warmup,
          measure,
        );

        final downloadMbps =
            downloadResult.serverMbps ?? downloadResult.clientMbps;
        final uploadMbps = uploadResult.serverMbps ?? uploadResult.clientMbps;

        if (downloadMbps <= 0 || uploadMbps <= 0) {
          throw const Ndt7Exception(
            Ndt7ErrorCode.noResult,
            'Measurement did not return any throughput data',
          );
        }

        final summary = TestSummary(
          downloadMbps: downloadMbps,
          uploadMbps: uploadMbps,
          minRttMs: downloadResult.minRttMs ?? uploadResult.minRttMs,
          lossRate: downloadResult.lossRate ?? uploadResult.lossRate,
          serverCity: locateResult.serverCity,
          serverCountry: locateResult.serverCountry,
          timestampUtc: DateTime.now().toUtc(),
          downloadDuration: downloadResult.duration,
          uploadDuration: uploadResult.duration,
        );

        _progressController.add(Ndt7Progress.complete(summary));
        return summary;
      } on Ndt7Exception catch (error) {
        lastError = error;
        if (error.code == Ndt7ErrorCode.invalidToken && attempt == 0) {
          locateResult = await locate();
          continue;
        }
        _progressController.add(Ndt7Progress.failure(error));
        rethrow;
      }
    }

    final error = lastError ??
        const Ndt7Exception(
          Ndt7ErrorCode.network,
          'Unable to run ndt7 test',
        );
    _progressController.add(Ndt7Progress.failure(error));
    throw error;
  }

  void dispose() {
    _progressController.close();
    _client.close();
  }

  Future<_MeasurementResult> _runMeasurement(
    Uri url,
    Duration warmup,
    Duration measure,
    _MeasurementDirection direction,
  ) async {
    final receivePort = ReceivePort();
    final errorPort = ReceivePort();
    final exitPort = ReceivePort();

    final request = _MeasurementRequest(
      url: url.toString(),
      warmupMicros: warmup.inMicroseconds,
      measureMicros: measure.inMicroseconds,
      direction: direction,
      progressPort: receivePort.sendPort,
    );

    await Isolate.spawn<_MeasurementRequest>(
      _measurementEntry,
      request,
      onError: errorPort.sendPort,
      onExit: exitPort.sendPort,
    );

    Ndt7Exception? caughtError;
    final completer = Completer<_MeasurementResult>();

    StreamSubscription? receiveSub;
    StreamSubscription? errorSub;

    receiveSub = receivePort.listen((dynamic message) {
      if (message is Map) {
        final type = message['type'];
        if (type == 'progress') {
          final phase = _phaseFromMessage(
            direction,
            message['stage'] as String?,
          );
          final mbps = (message['mbps'] as num?)?.toDouble();
          final elapsedMicros = message['elapsedMicros'] as int?;
          _progressController.add(
            Ndt7Progress.update(
              phase,
              mbps: mbps,
              elapsedSeconds:
                  elapsedMicros != null ? elapsedMicros / 1000000 : null,
            ),
          );
        } else if (type == 'result') {
          if (!completer.isCompleted) {
            completer.complete(_MeasurementResult.fromMap(message));
          }
        } else if (type == 'error') {
          if (message['code'] is String && message['message'] is String) {
            final exception = _exceptionFromMessage(
              message['code'] as String,
              message['message'] as String,
            );
            caughtError = exception;
            if (!completer.isCompleted) {
              completer.completeError(exception);
            }
          }
        }
      }
    });

    errorSub = errorPort.listen((dynamic errorData) {
      if (caughtError != null) {
        return;
      }
      final description = errorData is List && errorData.isNotEmpty
          ? errorData.first.toString()
          : 'Measurement isolate error';
      final exception = Ndt7Exception(
        Ndt7ErrorCode.network,
        description,
      );
      caughtError = exception;
      if (!completer.isCompleted) {
        completer.completeError(exception);
      }
    });

    final exitFuture = exitPort.first;
    try {
      return await completer.future;
    } finally {
      await exitFuture;
      await receiveSub?.cancel();
      await errorSub?.cancel();
      receivePort.close();
      errorPort.close();
      exitPort.close();
    }
  }
}

Ndt7Exception _exceptionFromMessage(String code, String message) {
  switch (code) {
    case 'timeout':
      return Ndt7Exception(Ndt7ErrorCode.timeout, message);
    case 'invalid_token':
      return Ndt7Exception(Ndt7ErrorCode.invalidToken, message);
    case 'tls_failure':
      return Ndt7Exception(Ndt7ErrorCode.tlsFailure, message);
    case 'no_result':
      return Ndt7Exception(Ndt7ErrorCode.noResult, message);
    default:
      return Ndt7Exception(Ndt7ErrorCode.network, message);
  }
}

Ndt7ProgressPhase _phaseFromMessage(
  _MeasurementDirection direction,
  String? stage,
) {
  if (stage == 'warmup') {
    return direction == _MeasurementDirection.download
        ? Ndt7ProgressPhase.downloadWarmup
        : Ndt7ProgressPhase.uploadWarmup;
  }
  return direction == _MeasurementDirection.download
      ? Ndt7ProgressPhase.download
      : Ndt7ProgressPhase.upload;
}

void _measurementEntry(_MeasurementRequest request) async {
  final sendPort = request.progressPort;
  WebSocketChannel? channel;
  try {
    channel = WebSocketChannel.connect(
      Uri.parse(request.url),
      protocols: const ['net.measurementlab.ndt.v7'],
    );
    var reportedMetrics = const Ndt7ServerMetrics();
    final stopwatch = Stopwatch()..start();
    final warmupMicros = request.warmupMicros;
    final measureMicros = request.measureMicros;
    final totalMicros = warmupMicros + measureMicros;
    var measuredBytes = 0;
    var isWarmup = true;

    final progressStage = request.direction == _MeasurementDirection.download
        ? 'download'
        : 'upload';

    void reportProgress({double? mbps, int? elapsedMicros, String? stage}) {
      sendPort.send({
        'type': 'progress',
        'phase': progressStage,
        'mbps': mbps,
        'elapsedMicros': elapsedMicros,
        'stage': stage ?? (isWarmup ? 'warmup' : 'measure'),
      });
    }

    final completer = Completer<void>();

    StreamSubscription<dynamic>? subscription;

    subscription = channel.stream.timeout(_inactivityTimeout).listen(
      (dynamic message) {
        final elapsed = stopwatch.elapsedMicroseconds;
        if (elapsed >= totalMicros) {
          if (!completer.isCompleted) {
            completer.complete();
          }
          return;
        }
        if (isWarmup && elapsed >= warmupMicros) {
          isWarmup = false;
        }

        if (message is List<int>) {
          if (!isWarmup) {
            measuredBytes += message.length;
            final measureElapsed = max(elapsed - warmupMicros, 1);
            final mbps = computeThroughputMbps(measuredBytes, measureElapsed);
            reportProgress(
              mbps: mbps,
              elapsedMicros: measureElapsed,
              stage: 'measure',
            );
          } else {
            reportProgress(elapsedMicros: elapsed, stage: 'warmup');
          }
        } else if (message is String) {
          try {
            final decoded = jsonDecode(message);
            if (decoded is Map<String, dynamic>) {
              final nextMetrics = Ndt7ServerMetrics.fromJson(decoded);
              reportedMetrics = reportedMetrics.merge(nextMetrics);
            }
          } catch (_) {
            // Ignore malformed JSON
          }
        }
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
      cancelOnError: true,
    );

    Future<void>? uploader;
    if (request.direction == _MeasurementDirection.upload) {
      uploader = _pumpUpload(
        channel,
        stopwatch,
        warmupMicros,
        totalMicros,
        onProgress: (bytes, elapsedMicros, warmup) {
          if (!warmup) {
            measuredBytes += bytes;
          }
          final measureElapsed = max(elapsedMicros - warmupMicros, 1);
          final mbps =
              computeThroughputMbps(measuredBytes, max(measureElapsed, 1));
          reportProgress(
            mbps: warmup ? null : mbps,
            elapsedMicros: warmup ? elapsedMicros : measureElapsed,
            stage: warmup ? 'warmup' : 'measure',
          );
        },
      );
    }

    try {
      await Future.wait([
        completer.future,
        if (uploader != null) uploader,
      ]);

      final elapsedMicros = max(stopwatch.elapsedMicroseconds - warmupMicros, 1);
      final clientMbps = computeThroughputMbps(measuredBytes, elapsedMicros);

      sendPort.send({
        'type': 'result',
        'direction': request.direction.name,
        'clientMbps': clientMbps,
        'serverMbps': reportedMetrics.meanThroughputMbps,
        'minRttMs': reportedMetrics.minRttMs,
        'lossRate': reportedMetrics.lossRate,
        'durationMicros': elapsedMicros,
      });
    } catch (error) {
      final descriptor = _classifyError(error);
      sendPort.send({
        'type': 'error',
        'code': descriptor.code,
        'message': descriptor.message,
      });
    } finally {
      await subscription?.cancel();
      try {
        await channel?.sink.close(websocket_status.normalClosure);
      } catch (_) {
        // ignore close errors
      }
    }
  }
}

Future<void> _pumpUpload(
  WebSocketChannel channel,
  Stopwatch stopwatch,
  int warmupMicros,
  int totalMicros,
  {required void Function(int bytes, int elapsedMicros, bool warmup)
          onProgress,}
) async {
  final random = Random();
  final chunk = Uint8List(_uploadChunkSize);
  for (var i = 0; i < chunk.length; i++) {
    chunk[i] = random.nextInt(256);
  }

  while (stopwatch.elapsedMicroseconds < totalMicros) {
    channel.sink.add(chunk);
    await Future<void>.delayed(Duration.zero);
    final elapsed = stopwatch.elapsedMicroseconds;
    final warmup = elapsed < warmupMicros;
    onProgress(
      chunk.length,
      elapsed,
      warmup,
    );
  }
}

({String code, String message}) _classifyError(Object error) {
  if (error is TimeoutException) {
    return (code: 'timeout', message: 'No response from ndt7 server');
  }
  if (error is HandshakeException ||
      (error is WebSocketChannelException &&
          error.inner is HandshakeException)) {
    return (code: 'tls_failure', message: 'TLS handshake with ndt7 server failed');
  }
  if (error is WebSocketChannelException) {
    final inner = error.inner;
    final message = inner?.toString() ?? error.toString();
    if (message.contains('403')) {
      return (
        code: 'invalid_token',
        message: 'Server rejected the access token for ndt7 measurement',
      );
    }
  }
  if (error is WebSocketException) {
    final message = error.message.toLowerCase();
    if (message.contains('handshake') && message.contains('403')) {
      return (
        code: 'invalid_token',
        message: 'Server rejected the access token for ndt7 measurement',
      );
    }
  }
  return (code: 'network', message: error.toString());
}
