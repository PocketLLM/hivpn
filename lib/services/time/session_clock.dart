import 'dart:async';

class SessionClock {
  const SessionClock();

  DateTime now() => DateTime.now().toUtc();

  Duration remaining({required DateTime start, required Duration duration}) {
    final elapsed = now().difference(start);
    final remaining = duration - elapsed;
    if (remaining.isNegative) {
      return Duration.zero;
    }
    return remaining;
  }

  Stream<Duration> countdownStream({
    required DateTime start,
    required Duration duration,
    Duration tick = const Duration(seconds: 1),
  }) async* {
    while (true) {
      yield remaining(start: start, duration: duration);
      await Future<void>.delayed(tick);
    }
  }
}
