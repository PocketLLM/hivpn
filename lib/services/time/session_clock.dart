import 'dart:async';

import 'package:flutter/services.dart';

class SessionClock {
  SessionClock({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('com.example.vpn/VpnChannel');

  final MethodChannel _channel;

  Future<int> elapsedRealtime() async {
    try {
      final result = await _channel.invokeMethod<int>('elapsedRealtime');
      if (result != null) {
        return result;
      }
    } catch (_) {
      // ignore and fall through to wall clock fallback
    }
    return DateTime.now().millisecondsSinceEpoch;
  }

  Future<Duration> remaining({
    required int startElapsedMs,
    required Duration duration,
  }) async {
    final now = await elapsedRealtime();
    final elapsedMs = now - startElapsedMs;
    final remainingMs = duration.inMilliseconds - elapsedMs;
    if (remainingMs <= 0) {
      return Duration.zero;
    }
    return Duration(milliseconds: remainingMs);
  }

  Stream<Duration> countdownStream({
    required int startElapsedMs,
    required Duration duration,
    Duration tick = const Duration(seconds: 1),
  }) async* {
    while (true) {
      final remainingDuration =
          await remaining(startElapsedMs: startElapsedMs, duration: duration);
      yield remainingDuration;
      if (remainingDuration <= Duration.zero) {
        break;
      }
      await Future<void>.delayed(tick);
    }
  }
}
