import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/connection_quality.dart';
import '../domain/connection_quality_controller.dart';

class ConnectionQualityIndicator extends ConsumerWidget {
  const ConnectionQualityIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(connectionQualityControllerProvider);
    final l10n = AppLocalizations.of(context);

    final label = l10n.connectionQualityLabel(state.quality);

    final color = switch (state.quality) {
      ConnectionQuality.excellent => Colors.greenAccent,
      ConnectionQuality.good => Colors.green,
      ConnectionQuality.fair => Colors.orange,
      ConnectionQuality.poor => Colors.redAccent,
      ConnectionQuality.offline => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.connectionQualityTitle,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (state.downloadMbps != null || state.ping != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.connectionQualityMetrics(
                      download: state.downloadMbps ?? 0,
                      upload: state.uploadMbps ?? 0,
                      ping: state.ping?.inMilliseconds ?? 0,
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          if (state.isSwitching)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.connectionQualityRefresh,
              onPressed: () => ref
                  .read(connectionQualityControllerProvider.notifier)
                  .refresh(),
            ),
        ],
      ),
    );
  }
}
