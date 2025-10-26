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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.08),
            theme.colorScheme.secondary.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.data_usage_rounded, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsUsage,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.settingsUsageSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (progress != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.colorScheme.surface.withOpacity(0.5),
              ),
            )
          else
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.4),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            limitGb != null
                ? '${usedGb.toStringAsFixed(2)} GB / ${limitGb.toStringAsFixed(2)} GB'
                : '${usedGb.toStringAsFixed(2)} GB',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.tonal(
                onPressed: () {
                  unawaited(onSetLimit());
                },
                child: Text(l10n.settingsSetLimit),
              ),
              OutlinedButton(
                onPressed: () {
                  unawaited(onReset());
                },
                child: Text(l10n.settingsResetUsage),
              ),
              if (usage.limitExceeded)
                Chip(
                  backgroundColor: theme.colorScheme.error.withOpacity(0.12),
                  label: Text(
                    '${((progress ?? 1) * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
