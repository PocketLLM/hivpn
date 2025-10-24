import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../data_usage_controller.dart';

class DataUsageCard extends ConsumerWidget {
  const DataUsageCard({
    super.key,
    required this.onSetLimit,
    required this.onReset,
  });

  final Future<void> Function() onSetLimit;
  final Future<void> Function() onReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usage = ref.watch(dataUsageControllerProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final usedGb = usage.usedBytes / (1024 * 1024 * 1024);
    final limitGb = usage.monthlyLimitBytes != null
        ? usage.monthlyLimitBytes! / (1024 * 1024 * 1024)
        : null;
    final progress = usage.hasLimit ? usage.utilization.clamp(0, 1).toDouble() : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsUsage,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.settingsUsageSubtitle,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          if (progress != null)
            LinearProgressIndicator(value: progress)
          else
            const SizedBox.shrink(),
          const SizedBox(height: 8),
          Text(
            limitGb != null
                ? '${usedGb.toStringAsFixed(2)} GB / ${limitGb.toStringAsFixed(2)} GB'
                : '${usedGb.toStringAsFixed(2)} GB',
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  unawaited(onSetLimit());
                },
                child: Text(l10n.settingsSetLimit),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {
                  unawaited(onReset());
                },
                child: Text(l10n.settingsResetUsage),
              ),
              if (usage.limitExceeded)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Chip(
                    label: Text(
                      '${((progress ?? 1) * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondary,
                      ),
                    ),
                    backgroundColor: theme.colorScheme.error,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
