import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/speedtest/speedtest_service.dart';
import '../../../services/storage/prefs.dart';
import '../data/speedtest_repository.dart';
import 'speedtest_state.dart';

typedef _SeriesUpdater = void Function(double value);

double rollingAverage(List<double> values, {int window = 5}) {
  if (values.isEmpty) {
    return 0;
  }
  final start = values.length > window ? values.length - window : 0;
  final slice = values.sublist(start);
  final sum = slice.fold<double>(0, (acc, value) => acc + value);
  return sum / slice.length;
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
    state = state.copyWith(status: SpeedTestStatus.preparing, errorMessage: null);
    try {
      final config = await _ref.read(speedTestConfigProvider.future);
      final prefs = await _ref.read(prefsStoreProvider.future);
      final pingEndpoint = config.firstPing;
      final downloadEndpoint = config.firstDownload;
      final uploadEndpoint = config.firstUpload;

      Duration? ping;
      if (pingEndpoint != null) {
        ping = await _service.ping(pingEndpoint);
      }
      state = state.copyWith(status: SpeedTestStatus.running, ping: ping);

      final downloadSeries = <double>[];
      if (downloadEndpoint != null) {
        await _consumeSeries(
          _service.download(downloadEndpoint),
          (value) {
            downloadSeries.add(value);
            state = state.copyWith(
              downloadSeries: List<double>.from(downloadSeries),
              downloadMbps: rollingAverage(downloadSeries),
            );
          },
        );
      }

      final uploadSeries = <double>[];
      if (uploadEndpoint != null) {
        await _consumeSeries(
          _service.upload(uploadEndpoint),
          (value) {
            uploadSeries.add(value);
            state = state.copyWith(
              uploadSeries: List<double>.from(uploadSeries),
              uploadMbps: rollingAverage(uploadSeries),
            );
          },
        );
      }

      final ip = await _service.externalIp(config.ipEndpoint);
      final completed = state.copyWith(
        status: SpeedTestStatus.complete,
        lastRun: DateTime.now().toUtc(),
        ip: ip.isNotEmpty ? ip : state.ip,
      );
      state = completed;
      await prefs.setString('speedtest_last', jsonEncode(_serializeResult(completed)));
    } catch (error) {
      state = state.copyWith(
        status: SpeedTestStatus.error,
        errorMessage: error.toString(),
      );
    }
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

  Future<void> _consumeSeries(Stream<double> stream, _SeriesUpdater onValue) async {
    await for (final value in stream) {
      onValue(value);
    }
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
