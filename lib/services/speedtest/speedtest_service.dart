import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_speed_test_plus/flutter_speed_test_plus.dart';

class SpeedTestService {
  SpeedTestService({Dio? dio, FlutterInternetSpeedTest? tester})
      : _dio = dio ?? Dio(),
        _tester = tester ?? FlutterInternetSpeedTest();

  final Dio _dio;
  final FlutterInternetSpeedTest _tester;

  Future<Duration> ping(Uri endpoint, {Duration timeout = const Duration(seconds: 3)}) async {
    final stopwatch = Stopwatch()..start();
    final port = endpoint.hasPort ? endpoint.port : (endpoint.scheme == 'https' ? 443 : 80);
    final socket = await Socket.connect(endpoint.host, port, timeout: timeout);
    stopwatch.stop();
    socket.destroy();
    return stopwatch.elapsed;
  }

  Future<void> startTest({
    required void Function(TestResult download, TestResult upload) onCompleted,
    void Function()? onStarted,
    void Function(TestResult data)? onDownloadComplete,
    void Function(TestResult data)? onUploadComplete,
    void Function(double percent, TestResult data)? onProgress,
    void Function()? onDefaultServerSelectionInProgress,
    void Function(Client? client)? onDefaultServerSelectionDone,
    void Function(String errorMessage, String speedTestError)? onError,
    void Function()? onCancel,
    String? downloadTestServer,
    String? uploadTestServer,
    int? fileSizeBytes,
    bool useFastApi = true,
  }) {
    return _tester.startTesting(
      onCompleted: onCompleted,
      onStarted: onStarted,
      onDownloadComplete: onDownloadComplete,
      onUploadComplete: onUploadComplete,
      onProgress: onProgress,
      onDefaultServerSelectionInProgress: onDefaultServerSelectionInProgress,
      onDefaultServerSelectionDone: onDefaultServerSelectionDone,
      onError: onError,
      onCancel: onCancel,
      downloadTestServer: downloadTestServer,
      uploadTestServer: uploadTestServer,
      fileSizeInBytes: fileSizeBytes ?? _defaultFileSizeBytes,
      useFastApi: useFastApi,
    );
  }

  Future<String> externalIp(Uri endpoint) async {
    final response = await _dio.getUri<String>(endpoint);
    return response.data?.trim() ?? '';
  }

  bool get isTestInProgress => _tester.isTestInProgress();

  Future<bool> cancelTest() => _tester.cancelTest();

  static const int _defaultFileSizeBytes = 10 * 1024 * 1024;
}
