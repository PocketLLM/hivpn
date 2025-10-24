import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/connection/domain/connection_quality_controller.dart';
import '../features/session/domain/session_controller.dart';
import '../features/session/domain/session_state.dart';
import '../features/session/domain/session_status.dart';
import '../l10n/app_localizations.dart';

class HomeStatusWidget extends ConsumerWidget {
  const HomeStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final quality = ref.watch(connectionQualityControllerProvider);
    final l10n = AppLocalizations.of(context);

    late final String statusText;
    switch (session.status) {
      case SessionStatus.connected:
        statusText = l10n.statusConnected;
        break;
      case SessionStatus.connecting:
        statusText = l10n.statusConnecting;
        break;
      case SessionStatus.preparing:
        statusText = l10n.statusPreparing;
        break;
      case SessionStatus.error:
        statusText = l10n.statusError;
        break;
      case SessionStatus.disconnected:
        statusText = l10n.statusDisconnected;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.homeWidgetTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
          const SizedBox(height: 8),
          Text(statusText, style: Theme.of(context).textTheme.bodyLarge),
          if (session.duration != null && session.start != null) ...[
            const SizedBox(height: 4),
            Text(
              l10n.homeWidgetSessionRemaining(
                _remaining(session),
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 12),
          Text(
            l10n.homeWidgetQualitySummary(
              l10n.connectionQualityLabel(quality.quality),
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _remaining(SessionState state) {
    if (state.start == null || state.duration == null) {
      return '--:--';
    }
    final end = state.start!.add(state.duration!);
    final remaining = end.difference(DateTime.now());
    final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${remaining.inHours}:$minutes:$seconds';
  }
}
