import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/speedtest/ndt7_models.dart';
import '../services/speedtest/ndt7_service.dart';

class SpeedTestCard extends StatefulWidget {
  const SpeedTestCard({
    super.key,
    required this.service,
    this.warmup = const Duration(seconds: 3),
    this.measure = const Duration(seconds: 10),
  });

  final Ndt7Service service;
  final Duration warmup;
  final Duration measure;

  @override
  State<SpeedTestCard> createState() => _SpeedTestCardState();
}

class _SpeedTestCardState extends State<SpeedTestCard> {
  late StreamSubscription<Ndt7Progress> _subscription;
  Ndt7Progress _progress = const Ndt7Progress.idle();
  TestSummary? _summary;
  Ndt7Exception? _error;
  double? _currentMbps;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _subscription = widget.service.progressStream.listen(_handleProgress);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _startTest() async {
    setState(() {
      _running = true;
      _summary = null;
      _error = null;
      _currentMbps = null;
      _progress = Ndt7Progress.locating();
    });
    try {
      final summary = await widget.service.runTest(
        warmup: widget.warmup,
        measure: widget.measure,
      );
      setState(() {
        _summary = summary;
        _running = false;
      });
    } on Ndt7Exception catch (error) {
      setState(() {
        _error = error;
        _running = false;
      });
    } catch (error) {
      setState(() {
        _error = Ndt7Exception(Ndt7ErrorCode.network, error.toString());
        _running = false;
      });
    }
  }

  void _handleProgress(Ndt7Progress progress) {
    setState(() {
      _progress = progress;
      if (progress.mbps != null) {
        _currentMbps = progress.mbps;
      }
      if (progress.summary != null) {
        _summary = progress.summary;
        _running = false;
        _error = null;
      }
      if (progress.error != null) {
        _error = progress.error;
        _running = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final summary = _summary;
    final error = _error;

    final statusText = _statusText(l10n, _progress);
    final buttonLabel = _running
        ? l10n.speedTestCardTesting
        : summary != null
            ? l10n.speedTestCardRetest
            : l10n.speedTestCardStart;

    final currentMbps = _currentMbps;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.speedTestCardTitle,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              statusText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            if (currentMbps != null) ...[
              const SizedBox(height: 12),
              Text(
                '${currentMbps.toStringAsFixed(1)} Mbps',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Text(
                summary == null ? l10n.runSpeedTest : l10n.speedTestCardComplete,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _running ? null : _startTest,
              child: Text(buttonLabel),
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              _ErrorBanner(message: _errorMessage(l10n, error)),
            ],
            if (summary != null) ...[
              const SizedBox(height: 16),
              _MetricGrid(summary: summary),
            ],
          ],
        ),
      ),
    );
  }

  String _statusText(AppLocalizations l10n, Ndt7Progress progress) {
    switch (progress.phase) {
      case Ndt7ProgressPhase.locating:
        return l10n.speedTestCardLocating;
      case Ndt7ProgressPhase.downloadWarmup:
        return l10n.speedTestCardDownloadWarmup;
      case Ndt7ProgressPhase.download:
        return l10n.speedTestCardDownloadMeasure;
      case Ndt7ProgressPhase.uploadWarmup:
        return l10n.speedTestCardUploadWarmup;
      case Ndt7ProgressPhase.upload:
        return l10n.speedTestCardUploadMeasure;
      case Ndt7ProgressPhase.complete:
        return l10n.speedTestCardComplete;
      case Ndt7ProgressPhase.error:
        return l10n.speedTestCardError;
      case Ndt7ProgressPhase.idle:
      default:
        return l10n.runSpeedTest;
    }
  }

  String _errorMessage(AppLocalizations l10n, Ndt7Exception error) {
    switch (error.code) {
      case Ndt7ErrorCode.timeout:
        return l10n.speedTestErrorTimeout;
      case Ndt7ErrorCode.invalidToken:
        return l10n.speedTestErrorToken;
      case Ndt7ErrorCode.tlsFailure:
        return l10n.speedTestErrorTls;
      case Ndt7ErrorCode.noResult:
        return l10n.speedTestErrorNoResult;
      case Ndt7ErrorCode.network:
      default:
        return l10n.speedTestErrorGeneric;
    }
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.summary});

  final TestSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final loss = summary.lossRate;
    final lossText =
        loss != null ? '${(loss * 100).toStringAsFixed(2)}%' : '--';
    final latency = summary.minRttMs;
    final latencyText = latency != null
        ? '${latency.toStringAsFixed(1)} ms'
        : '--';
    final serverLocation =
        [summary.serverCity, summary.serverCountry].where((e) => e.trim().isNotEmpty).join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetricRow(
          label: l10n.speedTestCardDownloadLabel,
          value: '${summary.downloadMbps.toStringAsFixed(2)} Mbps',
        ),
        _MetricRow(
          label: l10n.speedTestCardUploadLabel,
          value: '${summary.uploadMbps.toStringAsFixed(2)} Mbps',
        ),
        _MetricRow(
          label: l10n.speedTestCardLatencyLabel,
          value: latencyText,
        ),
        _MetricRow(
          label: l10n.speedTestCardLossLabel,
          value: lossText,
        ),
        _MetricRow(
          label: l10n.speedTestCardServerLabel,
          value: serverLocation.isEmpty ? '--' : serverLocation,
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
