import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_test_plus/flutter_speed_test_plus.dart';

import '../../../services/speedtest/speedtest_service.dart';
import '../../../services/storage/prefs.dart';
import '../../history/domain/speed_test_history_notifier.dart';
import '../../history/domain/speed_test_record.dart';
import '../data/speedtest_repository.dart';
import 'speedtest_state.dart';

double rollingAverage(List<double> values, {int window = 5}) {
  if (values.isEmpty) {
    return 0;
  }
  final start = values.length > window ? values.length - window : 0;
  final slice = values.sublist(start);
  final sum = slice.fold<double>(0, (acc, value) => acc + value);
  return sum / slice.length;
}

double _toMbps(TestResult result) {
  final value = result.transferRate;
  switch (result.unit) {
    case SpeedUnit.mbps:
      return value;
    case SpeedUnit.kbps:
      return value / 1000;
  }
}

class SpeedTestController extends StateNotifier<SpeedTestState> {
  SpeedTestController(this._ref, this._service)
      : super(SpeedTestState.initial());

  final Ref _ref;
  final SpeedTestService _service;

  Future<void> run() async {
    if (state.status == SpeedTestStatus.running || state.status == SpeedTestStatus.preparing) {
      return;
    }
    state = SpeedTestState(status: SpeedTestStatus.preparing);
    try {
      final config = await _ref.read(speedTestConfigProvider.future);
      final prefs = await _ref.read(prefsStoreProvider.future);
      final pingEndpoint = config.firstPing;
      Duration? ping;
      if (pingEndpoint != null) {
        try {
          ping = await _service.ping(pingEndpoint);
        } catch (_) {
          ping = null;
        }
      }
      final downloadSeries = <double>[];
      final uploadSeries = <double>[];
      final downloadServer = config.firstDownload?.toString();
      final uploadServer = config.firstUpload?.toString();
      final useFastApi = downloadServer == null || uploadServer == null;
      final completer = Completer<void>();
      var hadError = false;
      DateTime? completionTimestamp;

      state = state.copyWith(
        status: SpeedTestStatus.running,
        ping: ping,
        downloadSeries: const <double>[],
        uploadSeries: const <double>[],
        downloadMbps: 0,
        uploadMbps: 0,
        errorMessage: null,
      );

      void emitDownload(double value) {
        if (value.isNaN || value.isInfinite) {
          return;
        }
        downloadSeries.add(value);
        state = state.copyWith(
          downloadSeries: List<double>.from(downloadSeries),
          downloadMbps: rollingAverage(downloadSeries),
          errorMessage: null,
        );
      }

      void emitUpload(double value) {
        if (value.isNaN || value.isInfinite) {
          return;
        }
        uploadSeries.add(value);
        state = state.copyWith(
          uploadSeries: List<double>.from(uploadSeries),
          uploadMbps: rollingAverage(uploadSeries),
          errorMessage: null,
        );
      }

      try {
        await _service.startTest(
          useFastApi: useFastApi,
          downloadTestServer: downloadServer,
          uploadTestServer: uploadServer,
          onProgress: (percent, data) {
            final mbps = _toMbps(data);
            switch (data.type) {
              case TestType.download:
                emitDownload(mbps);
                break;
              case TestType.upload:
                emitUpload(mbps);
                break;
            }
          },
          onDownloadComplete: (data) {
            final mbps = _toMbps(data);
            if (downloadSeries.isEmpty || downloadSeries.last != mbps) {
              emitDownload(mbps);
            }
          },
          onUploadComplete: (data) {
            final mbps = _toMbps(data);
            if (uploadSeries.isEmpty || uploadSeries.last != mbps) {
              emitUpload(mbps);
            }
          },
          onCompleted: (download, upload) {
            completionTimestamp = DateTime.now().toUtc();
            final downloadMbps = _toMbps(download);
            final uploadMbps = _toMbps(upload);
            if (downloadSeries.isEmpty) {
              downloadSeries.add(downloadMbps);
            }
            if (uploadSeries.isEmpty) {
              uploadSeries.add(uploadMbps);
            }
            state = state.copyWith(
              status: SpeedTestStatus.complete,
              downloadMbps: downloadMbps,
              uploadMbps: uploadMbps,
              downloadSeries: List<double>.from(downloadSeries),
              uploadSeries: List<double>.from(uploadSeries),
              lastRun: completionTimestamp,
              errorMessage: null,
            );
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
          onError: (message, code) {
            hadError = true;
            state = state.copyWith(
              status: SpeedTestStatus.error,
              errorMessage: _friendlyPluginError(message, code),
              downloadSeries: const <double>[],
              uploadSeries: const <double>[],
            );
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
          onCancel: () {
            hadError = true;
            state = state.copyWith(
              status: SpeedTestStatus.error,
              errorMessage: 'Speed test was cancelled.',
              downloadSeries: const <double>[],
              uploadSeries: const <double>[],
            );
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
          onStarted: () {
            state = state.copyWith(status: SpeedTestStatus.running, errorMessage: null);
          },
        );
        await completer.future;
      } on Object catch (error) {
        hadError = true;
        state = state.copyWith(
          status: SpeedTestStatus.error,
          errorMessage: _friendlyException(error),
          downloadSeries: const <double>[],
          uploadSeries: const <double>[],
        );
        if (!completer.isCompleted) {
          completer.complete();
        }
      }

      if (hadError || state.status != SpeedTestStatus.complete) {
        return;
      }

      String ip = state.ip ?? '';
      try {
        final fetched = await _service.externalIp(config.ipEndpoint);
        if (fetched.isNotEmpty) {
          ip = fetched;
        }
      } on DioException catch (_) {
        // Leave IP unchanged when the lookup fails
      } on TimeoutException catch (_) {
        // Leave IP unchanged when the lookup times out
      } on SocketException catch (_) {
        // Leave IP unchanged when the lookup fails due to connectivity
      }
      final updated = state.copyWith(
        ip: ip.isNotEmpty ? ip : state.ip,
        lastRun: completionTimestamp ?? state.lastRun ?? DateTime.now().toUtc(),
      );
      state = updated;
      await prefs.setString('speedtest_last', jsonEncode(_serializeResult(updated)));
      final history = _ref.read(speedTestHistoryProvider.notifier);
      unawaited(history.addRecord(
        SpeedTestRecord(
          timestamp: updated.lastRun ?? DateTime.now().toUtc(),
          downloadMbps: updated.downloadMbps,
          uploadMbps: updated.uploadMbps,
          pingMs: updated.ping?.inMilliseconds,
          ip: updated.ip,
        ),
      ));
    } catch (error) {
      state = state.copyWith(
        status: SpeedTestStatus.error,
        errorMessage: error.toString(),
        downloadSeries: const <double>[],
        uploadSeries: const <double>[],
      );
  }
}

String _friendlyPluginError(String message, String code) {
  final combined = (message.isNotEmpty ? message : code).trim();
  final normalized = combined.toLowerCase();
  if (normalized.contains('socket') || normalized.contains('host lookup')) {
    return 'Unable to reach the speed test servers. Please check your connection and try again.';
  }
  if (normalized.contains('timeout')) {
    return 'The speed test timed out before it could finish. Try again in a moment.';
  }
  if (normalized.contains('cancel')) {
    return 'Speed test was cancelled. Tap start to try again.';
  }
  return combined.isEmpty ? 'The speed test encountered an unexpected error.' : combined;
}

String _friendlyException(Object error) {
  if (error is TimeoutException) {
    return 'The speed test took too long and timed out. Please try again.';
  }
  if (error is SocketException) {
    return 'Unable to reach the speed test servers. Please check your connection and try again.';
  }
  if (error is PlatformException) {
    return error.message ?? 'The speed test could not start. Please try again.';
  }
  return error.toString();
}

  Future<void> hydrate() async {
    final prefs = await _ref.read(prefsStoreProvider.future);
    final raw = prefs.getString('speedtest_last');
    if (raw == null) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      state = SpeedTestState(
        status: SpeedTestStatus.complete,
        ping: data['pingMs'] != null ? Duration(milliseconds: data['pingMs'] as int) : null,
        downloadMbps: (data['download'] as num?)?.toDouble() ?? 0,
        uploadMbps: (data['upload'] as num?)?.toDouble() ?? 0,
        ip: data['ip'] as String?,
        downloadSeries: ((data['downloadSeries'] as List<dynamic>?) ?? [])
            .map((e) => (e as num).toDouble())
            .toList(),
        uploadSeries: ((data['uploadSeries'] as List<dynamic>?) ?? [])
            .map((e) => (e as num).toDouble())
            .toList(),
        lastRun: data['lastRun'] != null ? DateTime.parse(data['lastRun'] as String) : null,
      );
    } catch (_) {
      // ignore corrupt data
    }
  }

  Map<String, dynamic> _serializeResult(SpeedTestState state) {
    return {
      'pingMs': state.ping?.inMilliseconds,
      'download': state.downloadMbps,
      'upload': state.uploadMbps,
      'ip': state.ip,
      'downloadSeries': state.downloadSeries,
      'uploadSeries': state.uploadSeries,
      'lastRun': state.lastRun?.toIso8601String(),
    };
  }

}

final speedTestServiceProvider = Provider<SpeedTestService>((ref) {
  return SpeedTestService();
});

final speedTestControllerProvider =
    StateNotifierProvider<SpeedTestController, SpeedTestState>((ref) {
  final service = ref.watch(speedTestServiceProvider);
  final controller = SpeedTestController(ref, service);
  unawaited(controller.hydrate());
  return controller;
});
