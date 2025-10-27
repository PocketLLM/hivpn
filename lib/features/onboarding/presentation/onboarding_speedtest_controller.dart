import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_test_plus/flutter_speed_test_plus.dart';

import '../../../services/analytics/analytics_service.dart';
import '../../../services/speedtest/speedtest_service.dart';
import '../../speedtest/data/speedtest_repository.dart';
import '../../speedtest/domain/speedtest_controller.dart';
import 'onboarding_controller.dart';

enum OnboardingSpeedTestStatus { idle, running, completed, error }

class SpeedTestSummary {
  const SpeedTestSummary({
    required this.downloadMbps,
    required this.uploadMbps,
    this.latency,
  });

  final double downloadMbps;
  final double uploadMbps;
  final Duration? latency;
}

class OnboardingSpeedTestState {
  const OnboardingSpeedTestState({
    this.optIn = false,
    this.status = OnboardingSpeedTestStatus.idle,
    this.progress = 0,
    this.downloadMbps = 0,
    this.uploadMbps = 0,
    this.latency,
    this.errorMessage,
    this.showUnavailableBanner = false,
    this.summary,
  });

  final bool optIn;
  final OnboardingSpeedTestStatus status;
  final double progress;
  final double downloadMbps;
  final double uploadMbps;
  final Duration? latency;
  final String? errorMessage;
  final bool showUnavailableBanner;
  final SpeedTestSummary? summary;

  bool get isRunning => status == OnboardingSpeedTestStatus.running;

  OnboardingSpeedTestState copyWith({
    bool? optIn,
    OnboardingSpeedTestStatus? status,
    double? progress,
    double? downloadMbps,
    double? uploadMbps,
    Object? latency = _sentinel,
    Object? errorMessage = _sentinel,
    bool? showUnavailableBanner,
    Object? summary = _sentinel,
  }) {
    return OnboardingSpeedTestState(
      optIn: optIn ?? this.optIn,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      downloadMbps: downloadMbps ?? this.downloadMbps,
      uploadMbps: uploadMbps ?? this.uploadMbps,
      latency: identical(latency, _sentinel) ? this.latency : latency as Duration?,
      errorMessage:
          identical(errorMessage, _sentinel) ? this.errorMessage : errorMessage as String?,
      showUnavailableBanner: showUnavailableBanner ?? this.showUnavailableBanner,
      summary: identical(summary, _sentinel) ? this.summary : summary as SpeedTestSummary?,
    );
  }

  static const Object _sentinel = Object();
}

class OnboardingSpeedTestController
    extends StateNotifier<OnboardingSpeedTestState> {
  OnboardingSpeedTestController(this._ref, this._service)
      : super(const OnboardingSpeedTestState());

  final Ref _ref;
  final SpeedTestService _service;
  Completer<void>? _activeTest;

  Future<void> toggleOptIn(bool optIn) async {
    state = state.copyWith(optIn: optIn);
    await _ref
        .read(analyticsServiceProvider)
        .logEvent('speedtest_opt_in_changed', {'opt_in': optIn});
  }

  Future<void> startTest() async {
    if (state.isRunning) {
      return;
    }
    _activeTest?.completeError(StateError('superseded'));
    _activeTest = Completer<void>();

    state = state.copyWith(
      status: OnboardingSpeedTestStatus.running,
      progress: 0,
      downloadMbps: 0,
      uploadMbps: 0,
      latency: null,
      errorMessage: null,
      showUnavailableBanner: false,
      summary: null,
    );

    await _ref.read(analyticsServiceProvider).logEvent('speedtest_started');

    try {
      final config = await _ref.read(speedTestConfigProvider.future);
      Duration? latency;
      final pingEndpoint = config.firstPing;
      if (pingEndpoint != null) {
        try {
          latency = await _service.ping(pingEndpoint);
        } catch (_) {
          latency = null;
        }
      }

      state = state.copyWith(latency: latency);

      final downloadServer = config.firstDownload?.toString();
      final uploadServer = config.firstUpload?.toString();
      final useFastApi = downloadServer == null || uploadServer == null;

      await _service.startTest(
        useFastApi: useFastApi,
        downloadTestServer: downloadServer,
        uploadTestServer: uploadServer,
        onProgress: (percent, data) {
          final mbps = _toMbps(data);
          switch (data.type) {
            case TestType.download:
              state = state.copyWith(
                downloadMbps: mbps,
                progress: percent / 100,
              );
              break;
            case TestType.upload:
              state = state.copyWith(
                uploadMbps: mbps,
                progress: percent / 100,
              );
              break;
          }
        },
        onDownloadComplete: (data) {
          state = state.copyWith(downloadMbps: _toMbps(data));
        },
        onUploadComplete: (data) {
          state = state.copyWith(uploadMbps: _toMbps(data));
        },
        onError: (message, code) {
          state = state.copyWith(
            status: OnboardingSpeedTestStatus.error,
            errorMessage: message.isNotEmpty ? message : code,
            showUnavailableBanner: true,
          );
          _activeTest?.complete();
        },
        onCancel: () {
          state = state.copyWith(
            status: OnboardingSpeedTestStatus.idle,
            progress: 0,
            errorMessage: 'Speed test cancelled.',
            summary: null,
          );
          _activeTest?.complete();
        },
        onCompleted: (download, upload) {
          final downloadMbps = _toMbps(download);
          final uploadMbps = _toMbps(upload);
          final summary = SpeedTestSummary(
            downloadMbps: downloadMbps,
            uploadMbps: uploadMbps,
            latency: state.latency,
          );
          state = state.copyWith(
            status: OnboardingSpeedTestStatus.completed,
            progress: 1,
            downloadMbps: downloadMbps,
            uploadMbps: uploadMbps,
            summary: summary,
            errorMessage: null,
          );
          _ref
              .read(onboardingControllerProvider.notifier)
              .setSpeedTestSummary(summary);
          _activeTest?.complete();
          unawaited(
            _ref.read(analyticsServiceProvider).logEvent('speedtest_completed', {
                  'download_mbps': downloadMbps,
                  'upload_mbps': uploadMbps,
                  'latency_ms': state.latency?.inMilliseconds,
                }),
          );
        },
      );

      await _activeTest?.future;
    } catch (error) {
      state = state.copyWith(
        status: OnboardingSpeedTestStatus.error,
        errorMessage: error.toString(),
        showUnavailableBanner: true,
      );
      _activeTest?.complete();
    } finally {
      _activeTest = null;
    }
  }

  Future<void> cancelTest() async {
    if (!state.isRunning) {
      return;
    }
    await _service.cancelTest();
    await _ref.read(analyticsServiceProvider).logEvent(
      'speedtest_skipped',
      {'method': 'cancel'},
    );
  }

  Future<void> markBannerDismissed() async {
    state = state.copyWith(showUnavailableBanner: false);
  }
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

final onboardingSpeedTestControllerProvider =
    StateNotifierProvider<OnboardingSpeedTestController, OnboardingSpeedTestState>((ref) {
  final service = ref.watch(speedTestServiceProvider);
  return OnboardingSpeedTestController(ref, service);
});
