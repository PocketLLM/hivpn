import 'package:flutter_test/flutter_test.dart';

import 'package:hivpn/core/utils/time.dart';

void main() {
  test('formatNotificationDuration formats mm:ss with leading zeros', () {
    expect(formatNotificationDuration(const Duration(minutes: 1, seconds: 5)), '01:05');
    expect(formatNotificationDuration(const Duration(seconds: 59)), '00:59');
  });

  test('formatNotificationDuration clamps negative durations', () {
    expect(formatNotificationDuration(const Duration(seconds: -30)), '00:00');
  });
}
