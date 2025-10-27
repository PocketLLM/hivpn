import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/time.dart';
import '../../../widgets/page_app_bar.dart';
import '../domain/connection_history_notifier.dart';
import '../domain/connection_record.dart';
import '../domain/speed_test_history_notifier.dart';
import '../domain/speed_test_record.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionAsync = ref.watch(connectionHistoryProvider);
    final speedAsync = ref.watch(speedTestHistoryProvider);

    final isLoading = connectionAsync is AsyncLoading || speedAsync is AsyncLoading;
    final Object? error = connectionAsync is AsyncError
        ? connectionAsync.error
        : speedAsync is AsyncError
            ? speedAsync.error
            : null;

    return Scaffold(
      appBar: const HiVpnPageAppBar(title: 'History'),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (error != null) {
              return _ErrorView(
                message: 'Failed to load history. Please try again.',
                onRetry: () => _refresh(ref),
              );
            }

            final connections = connectionAsync.requireValue;
            final speedTests = speedAsync.requireValue;

            if (connections.isEmpty && speedTests.isEmpty) {
              return _EmptyHistoryView(onRefresh: () => _refresh(ref));
            }

            return RefreshIndicator(
              onRefresh: () => _refresh(ref),
              child: _HistoryList(
                connectionRecords: connections,
                speedTestRecords: speedTests,
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<void> _refresh(WidgetRef ref) async {
  await Future.wait([
    ref.read(connectionHistoryProvider.notifier).refresh(),
    ref.read(speedTestHistoryProvider.notifier).refresh(),
  ]);
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({
    required this.connectionRecords,
    required this.speedTestRecords,
  });

  final List<ConnectionRecord> connectionRecords;
  final List<SpeedTestRecord> speedTestRecords;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    children.add(const SizedBox(height: 8));
    children.add(_SectionHeader(label: 'Speed Tests'));
    children.add(const SizedBox(height: 12));

    if (speedTestRecords.isEmpty) {
      children.add(const _SectionPlaceholder(message: 'No speed tests yet. Run a test to see results here.'));
    } else {
      for (final record in speedTestRecords) {
        children
          ..add(_SpeedTestCard(record: record))
          ..add(const SizedBox(height: 12));
      }
    }

    children.add(const SizedBox(height: 12));
    children.add(_SectionHeader(label: 'Connections'));
    children.add(const SizedBox(height: 12));

    if (connectionRecords.isEmpty) {
      children.add(const _SectionPlaceholder(message: 'No VPN sessions yet. Connect to a server to build your history.'));
    } else {
      final totalBytes = connectionRecords.fold<int>(0, (value, record) => value + record.bytesReceived + record.bytesSent);
      final totalDurationSeconds = connectionRecords.fold<int>(0, (value, record) => value + record.durationSeconds);
      children
        ..add(_ConnectionSummaryCard(
          totalBytes: totalBytes,
          totalDuration: Duration(seconds: totalDurationSeconds),
        ))
        ..add(const SizedBox(height: 12));

      for (final record in connectionRecords) {
        children
          ..add(_ConnectionRecordCard(record: record))
          ..add(const SizedBox(height: 12));
      }
    }

    children.add(const SizedBox(height: 120));

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: children,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _SectionPlaceholder extends StatelessWidget {
  const _SectionPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.08)),
      ),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }
}

class _ConnectionSummaryCard extends StatelessWidget {
  const _ConnectionSummaryCard({
    required this.totalBytes,
    required this.totalDuration,
  });

  final int totalBytes;
  final Duration totalDuration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryMetric(
              label: 'Total time',
              value: formatHistoryDuration(totalDuration),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _SummaryMetric(
              label: 'Data used',
              value: _formatDataVolume(totalBytes),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

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
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _SpeedTestCard extends StatelessWidget {
  const _SpeedTestCard({required this.record});

  final SpeedTestRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timestamp = formatDateTime(record.timestamp);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Speed Test',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                timestamp,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoTag(label: 'Download', value: '${record.downloadMbps.toStringAsFixed(1)} Mbps'),
              _InfoTag(label: 'Upload', value: '${record.uploadMbps.toStringAsFixed(1)} Mbps'),
              if (record.pingMs != null)
                _InfoTag(label: 'Ping', value: '${record.pingMs} ms'),
              if ((record.ip ?? '').isNotEmpty)
                _InfoTag(label: 'IP', value: record.ip!),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConnectionRecordCard extends StatelessWidget {
  const _ConnectionRecordCard({required this.record});

  final ConnectionRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final started = formatDateTime(record.startedAt);
    final duration = Duration(seconds: record.durationSeconds);
    final serverSpeed = _serverSpeedLabel(record);
    final tags = <Widget>[
      _InfoTag(label: 'Started', value: started),
      _InfoTag(label: 'Duration', value: formatHistoryDuration(duration)),
      _InfoTag(label: 'Data', value: _formatDataVolume(record.bytesReceived + record.bytesSent)),
    ];
    if ((record.publicIp ?? '').isNotEmpty) {
      tags.add(_InfoTag(label: 'Assigned IP', value: record.publicIp!));
    }
    if ((record.serverIp ?? '').isNotEmpty) {
      tags.add(_InfoTag(label: 'Server IP', value: record.serverIp!));
    }
    if ((record.serverLocation ?? '').isNotEmpty) {
      tags.add(_InfoTag(label: 'Location', value: record.serverLocation!));
    }
    if (serverSpeed != null) {
      tags.add(_InfoTag(label: 'Server speed', value: serverSpeed));
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.vpn_lock, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.serverName,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if ((record.serverLocation ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          record.serverLocation!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.65),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              _StatusChip(status: record.status),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: tags,
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color) = switch (status) {
      ConnectionStatus.success => ('Connected', theme.colorScheme.primary),
      ConnectionStatus.failure => ('Failed', theme.colorScheme.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == ConnectionStatus.success ? Icons.check_circle : Icons.error,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  const _InfoTag({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistoryView extends StatelessWidget {
  const _EmptyHistoryView({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
        children: [
          Icon(Icons.history, size: 48, color: theme.colorScheme.primary.withOpacity(0.6)),
          const SizedBox(height: 16),
          Text(
            'Your VPN and speed test activity will appear here.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Run a speed test or connect to a server to start building history.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => unawaited(onRetry()),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

String formatHistoryDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  return '${hours}h ${minutes}m';
}

String _formatDataVolume(int bytes) {
  if (bytes <= 0) {
    return '0 MB';
  }
  final mb = bytes / (1024 * 1024);
  if (mb >= 1024) {
    final gb = mb / 1024;
    return '${gb.toStringAsFixed(gb >= 10 ? 1 : 2)} GB';
  }
  return '${mb.toStringAsFixed(mb >= 10 ? 1 : 2)} MB';
}

String? _serverSpeedLabel(ConnectionRecord record) {
  final download = record.serverDownloadSpeed;
  final upload = record.serverUploadSpeed;
  if (download != null && upload != null && download > 0 && upload > 0) {
    return '${download}↓ / ${upload}↑ Mbps';
  }
  final bandwidth = record.serverBandwidth;
  if (bandwidth != null && bandwidth > 0) {
    return '$bandwidth Mbps';
  }
  return null;
}
