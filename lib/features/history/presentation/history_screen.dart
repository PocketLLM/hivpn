import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/connection_history_notifier.dart';
import '../domain/connection_record.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(connectionHistoryProvider);
    return historyAsync.when(
      data: (records) => _HistoryView(records: records),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Failed to load history: $err')),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView({required this.records});

  final List<ConnectionRecord> records;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(
        child: Text('No sessions yet. Connect to start your timeline.'),
      );
    }
    final theme = Theme.of(context);
    final totalBytes = records.fold<int>(
      0,
      (value, record) => value + record.bytesReceived + record.bytesSent,
    );
    final totalHours = records.fold<int>(
      0,
      (value, record) => value + record.durationSeconds,
    );
    final totalMb = (totalBytes / (1024 * 1024)).toStringAsFixed(1);
    final totalDuration = Duration(seconds: totalHours);
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: records.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _HistoryMetric(label: 'Total time', value: formatHistoryDuration(totalDuration)),
                _HistoryMetric(label: 'Data used', value: '$totalMb MB'),
              ],
            ),
          );
        }
        final record = records[index - 1];
        final duration = Duration(seconds: record.durationSeconds);
        final durationLabel =
            '${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}m ${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}s';
        final dataMb = ((record.bytesReceived + record.bytesSent) / (1024 * 1024))
            .toStringAsFixed(2);
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.serverName,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '${record.startedAt.toLocal()} — ${record.endedAt.toLocal()}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _HistoryMetric(label: 'Duration', value: durationLabel),
                  _HistoryMetric(label: 'Data', value: '$dataMb MB'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HistoryMetric extends StatelessWidget {
  const _HistoryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

String formatHistoryDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  return '${hours}h ${minutes}m';
}
