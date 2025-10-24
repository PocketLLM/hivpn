import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class SpeedTestService {
  SpeedTestService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<Duration> ping(Uri endpoint, {Duration timeout = const Duration(seconds: 3)}) async {
    final stopwatch = Stopwatch()..start();
    final port = endpoint.hasPort ? endpoint.port : (endpoint.scheme == 'https' ? 443 : 80);
    final socket = await Socket.connect(endpoint.host, port, timeout: timeout);
    stopwatch.stop();
    socket.destroy();
    return stopwatch.elapsed;
  }

  Stream<double> download(Uri endpoint) {
    late StreamController<double> controller;
    controller = StreamController<double>(onListen: () async {
      final response = await _dio.getUri<ResponseBody>(
        endpoint,
        options: Options(responseType: ResponseType.stream, followRedirects: true),
      );
      final stopwatch = Stopwatch()..start();
      int receivedBytes = 0;
      Timer? timer;

      void emit() {
        final seconds = max(stopwatch.elapsedMilliseconds / 1000, 0.001);
        final mbps = (receivedBytes * 8) / (seconds * 1000000);
        if (!controller.isClosed) {
          controller.add(mbps);
        }
      }

      timer = Timer.periodic(const Duration(milliseconds: 500), (_) => emit());

      response.data.stream.listen(
        (chunk) {
          receivedBytes += (chunk as List<int>).length;
        },
        onDone: () {
          timer?.cancel();
          emit();
          stopwatch.stop();
          controller.close();
        },
        onError: (Object error, StackTrace stackTrace) {
          timer?.cancel();
          stopwatch.stop();
          controller.addError(error, stackTrace);
          controller.close();
        },
        cancelOnError: true,
      );
    });
    return controller.stream;
  }

  Stream<double> upload(Uri endpoint, {int bytes = 8 * 1024 * 1024}) {
    late StreamController<double> controller;
    controller = StreamController<double>(onListen: () async {
      final stopwatch = Stopwatch()..start();
      final payload = Uint8List(bytes);
      final random = Random();
      for (var i = 0; i < payload.length; i++) {
        payload[i] = random.nextInt(256);
      }
      int sentBytes = 0;
      Timer? timer;

      void emit() {
        final seconds = max(stopwatch.elapsedMilliseconds / 1000, 0.001);
        final mbps = (sentBytes * 8) / (seconds * 1000000);
        if (!controller.isClosed) {
          controller.add(mbps);
        }
      }

      timer = Timer.periodic(const Duration(milliseconds: 500), (_) => emit());

      final chunkCount = 64;
      final chunkSize = bytes ~/ chunkCount;
      final stream = Stream<List<int>>.fromIterable(
        List<List<int>>.generate(
          chunkCount,
          (index) {
            final start = chunkSize * index;
            final end = index == chunkCount - 1 ? payload.length : start + chunkSize;
            final chunk = payload.sublist(start, end);
            sentBytes += chunk.length;
            return chunk;
          },
        ),
      );

      try {
        await _dio.postUri(
          endpoint,
          data: stream,
          options: Options(headers: {'Content-Length': payload.length.toString()}),
        );
        emit();
      } catch (error, stackTrace) {
        timer?.cancel();
        stopwatch.stop();
        controller.addError(error, stackTrace);
        controller.close();
        return;
      }

      timer?.cancel();
      stopwatch.stop();
      controller.close();
    });
    return controller.stream;
  }

  Future<String> externalIp(Uri endpoint) async {
    final response = await _dio.getUri<String>(endpoint);
    return response.data?.trim() ?? '';
  }
}
