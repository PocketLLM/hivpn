import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../vpn/vpn_provider.dart';
import '../vpn/vpn_port.dart';
import 'session_clock.dart';

final sessionClockProvider = Provider<SessionClock>((ref) {
  return SessionClock();
});
