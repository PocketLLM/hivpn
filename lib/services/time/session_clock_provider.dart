import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_clock.dart';

final sessionClockProvider = Provider<SessionClock>((ref) {
  return const SessionClock();
});
