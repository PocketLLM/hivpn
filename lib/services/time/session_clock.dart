import 'dart:async';

class SessionClock {
  const SessionClock(this._elapsedRealtimeProvider);

  final Future<int> Function() _elapsedRealtimeProvider;

  Future<int> elapsedRealtime() => _elapsedRealtimeProvider();

  Future<Duration> remaining({
    required int startElapsedMs,
    required Duration duration,
  }) async {
    final nowMs = await elapsedRealtime();
    final elapsedMs = nowMs - startElapsedMs;
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
    var remainingDuration = await remaining(
      startElapsedMs: startElapsedMs,
      duration: duration,
    );
    yield remainingDuration;
    while (remainingDuration > Duration.zero) {
      await Future<void>.delayed(tick);
      remainingDuration = await remaining(
        startElapsedMs: startElapsedMs,
        duration: duration,
      );
      yield remainingDuration;
    }
  }
}
