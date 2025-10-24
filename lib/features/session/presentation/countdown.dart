import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/time.dart';
import '../domain/session_controller.dart';
import '../domain/session_status.dart';
import '../domain/session_state.dart';
import '../../../services/time/session_clock_provider.dart';

final sessionCountdownProvider = StreamProvider.autoDispose<Duration>((ref) {
  final state = ref.watch(sessionControllerProvider);
  if (state.status != SessionStatus.connected ||
      state.startElapsedMs == null ||
      state.duration == null) {
    return Stream<Duration>.value(Duration.zero);
  }
  final clock = ref.watch(sessionClockProvider);
  return clock.countdownStream(
    startElapsedMs: state.startElapsedMs!,
    duration: state.duration!,
  );
});

class SessionCountdown extends ConsumerWidget {
  const SessionCountdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionControllerProvider);
    final countdownAsync = ref.watch(sessionCountdownProvider);

    return countdownAsync.when(
      data: (duration) => Text(
        state.status == SessionStatus.connected
            ? formatCountdown(duration)
            : '00:00',
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text('00:00'),
    );
  }
}
