import 'package:flutter_test/flutter_test.dart';

import 'package:hivpn/services/time/session_clock.dart';

class _FakeClock extends SessionClock {
  _FakeClock(this._now);

  DateTime _now;

  @override
  DateTime now() => _now;

  void advance(Duration duration) {
    _now = _now.add(duration);
  }
}

void main() {
  test('remaining clamps at zero when elapsed exceeds duration', () {
    final fakeClock = _FakeClock(DateTime.utc(2024, 1, 1));
    final start = fakeClock.now();
    final duration = const Duration(minutes: 10);

    fakeClock.advance(const Duration(minutes: 5));
    expect(fakeClock.remaining(start: start, duration: duration),
        const Duration(minutes: 5));

    fakeClock.advance(const Duration(minutes: 10));
    expect(fakeClock.remaining(start: start, duration: duration), Duration.zero);
  });
}
