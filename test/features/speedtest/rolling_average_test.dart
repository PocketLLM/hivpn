import 'package:flutter_test/flutter_test.dart';

import 'package:hivpn/features/speedtest/domain/speedtest_controller.dart';

void main() {
  test('rollingAverage uses last five samples when available', () {
    final samples = <double>[10, 20, 30, 40, 50, 60];
    final average = rollingAverage(samples);
    expect(average, closeTo((20 + 30 + 40 + 50 + 60) / 5, 0.001));
  });

  test('rollingAverage returns mean of available samples when fewer than window', () {
    final samples = <double>[12, 18];
    final average = rollingAverage(samples);
    expect(average, closeTo(15, 0.001));
  });
}
