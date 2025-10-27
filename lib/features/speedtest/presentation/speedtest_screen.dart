import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/colors.dart';
import '../domain/speedtest_controller.dart';
import '../domain/speedtest_state.dart';
import 'widgets/speed_gauge.dart';

class SpeedTestScreen extends ConsumerWidget {
  const SpeedTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(speedTestControllerProvider);
    final controller = ref.read(speedTestControllerProvider.notifier);
    final theme = Theme.of(context);

    final buttonInfo = _PrimaryButtonInfo.fromState(state);
    final statusMessage = _statusDescription(state);
    final gaugeLabel = _gaugeLabel(state);

    final gradients = _MetricGradients(theme);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 160),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Speed Test',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        statusMessage,
                        key: ValueKey<int>(state.status.index),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.65),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _GaugePanel(
                      state: state,
                      gaugeLabel: gaugeLabel,
                      buttonInfo: buttonInfo,
                      onRun: buttonInfo.enabled ? () => controller.run() : null,
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 20),
                      _ErrorBanner(message: state.errorMessage!),
                    ],
                    const SizedBox(height: 28),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: state.isBusy ? 0.6 : 1,
                      child: _MetricGrid(
                        gradients: gradients,
                        state: state,
                      ),
                    ),
                    const SizedBox(height: 32),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: state.hasResult
                          ? _InsightsView(
                              key: ValueKey(state.lastRun ?? state.downloadMbps),
                              state: state,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugePanel extends StatelessWidget {
  const _GaugePanel({
    required this.state,
    required this.gaugeLabel,
    required this.buttonInfo,
    this.onRun,
  });

  final SpeedTestState state;
  final String gaugeLabel;
  final _PrimaryButtonInfo buttonInfo;
  final VoidCallback? onRun;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.08),
            theme.colorScheme.primary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: SpeedGauge(
              speed: state.downloadMbps,
              statusLabel: gaugeLabel,
              title: 'Download',
              maxValue: 100,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onRun,
              icon: Icon(buttonInfo.icon),
              label: Text(buttonInfo.label),
            ),
          ),
          if (state.status == SpeedTestStatus.preparing) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Checking latency and allocating servers…',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (state.status == SpeedTestStatus.running) ...[
            const SizedBox(height: 14),
            Text(
              'Collecting download and upload samples…',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ] else if (state.status == SpeedTestStatus.complete && state.downloadMbps <= 0) ...[
            const SizedBox(height: 14),
            Text(
              'Run test to get values',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.gradients, required this.state});

  final _MetricGradients gradients;
  final SpeedTestState state;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isTwoColumn = maxWidth >= 460;
        final itemWidth = isTwoColumn ? (maxWidth - 16) / 2 : maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            SizedBox(
              width: itemWidth,
              child: _MetricCard(
                title: 'Download',
                value: state.downloadMbps > 0
                    ? '${state.downloadMbps.toStringAsFixed(1)} Mbps'
                    : (state.isBusy ? 'Measuring…' : '--'),
                icon: Icons.download_rounded,
                gradient: gradients.primary,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _MetricCard(
                title: 'Upload',
                value: state.uploadSeries.isEmpty && !state.hasResult
                    ? (state.isBusy ? 'Pending…' : '--')
                    : '${state.uploadMbps.toStringAsFixed(1)} Mbps',
                icon: Icons.upload_rounded,
                gradient: gradients.secondary,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _MetricCard(
                title: 'Ping',
                value: state.ping != null
                    ? '${state.ping!.inMilliseconds} ms'
                    : (state.isBusy ? 'Measuring…' : '--'),
                icon: Icons.podcasts,
                gradient: gradients.tertiary,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _MetricCard(
                title: 'IP',
                value: state.ip != null && state.ip!.isNotEmpty
                    ? state.ip!
                    : (state.isBusy ? 'Detecting…' : 'Not available'),
                icon: Icons.language,
                gradient: gradients.quaternary,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MetricGradients {
  _MetricGradients(ThemeData theme)
      : primary = LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.18),
            theme.colorScheme.secondary.withOpacity(0.12),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        secondary = LinearGradient(
          colors: [
            HiVpnColors.accent.withOpacity(0.16),
            theme.colorScheme.primary.withOpacity(0.06),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        tertiary = LinearGradient(
          colors: [
            HiVpnColors.info.withOpacity(0.16),
            HiVpnColors.primary.withOpacity(0.05),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        quaternary = LinearGradient(
          colors: [
            theme.colorScheme.secondary.withOpacity(0.14),
            theme.colorScheme.primary.withOpacity(0.05),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

  final Gradient primary;
  final Gradient secondary;
  final Gradient tertiary;
  final Gradient quaternary;
}

String _statusDescription(SpeedTestState state) {
  switch (state.status) {
    case SpeedTestStatus.preparing:
      return 'Preparing your secure tunnel for an accurate reading…';
    case SpeedTestStatus.running:
      return 'Benchmarking your secure tunnel…';
    case SpeedTestStatus.complete:
      return 'Here\'s how your connection performed in the latest run.';
    case SpeedTestStatus.error:
      return 'We hit a snag while testing. Review the details below and try again.';
    case SpeedTestStatus.idle:
    default:
      return 'Measure download, upload, and latency instantly.';
  }
}

String _gaugeLabel(SpeedTestState state) {
  switch (state.status) {
    case SpeedTestStatus.preparing:
      return 'Preparing…';
    case SpeedTestStatus.running:
      return 'Testing…';
    case SpeedTestStatus.complete:
      return state.hasResult ? 'Result' : 'Completed';
    case SpeedTestStatus.error:
      return 'Tap retry';
    case SpeedTestStatus.idle:
    default:
      return 'Ready';
  }
}

class _PrimaryButtonInfo {
  const _PrimaryButtonInfo({
    required this.label,
    required this.icon,
    required this.enabled,
  });

  final String label;
  final IconData icon;
  final bool enabled;

  factory _PrimaryButtonInfo.fromState(SpeedTestState state) {
    switch (state.status) {
      case SpeedTestStatus.preparing:
        return const _PrimaryButtonInfo(
          label: 'Preparing…',
          icon: Icons.hourglass_top_rounded,
          enabled: false,
        );
      case SpeedTestStatus.running:
        return const _PrimaryButtonInfo(
          label: 'Testing…',
          icon: Icons.speed,
          enabled: false,
        );
      case SpeedTestStatus.complete:
        return const _PrimaryButtonInfo(
          label: 'Run Again',
          icon: Icons.replay_rounded,
          enabled: true,
        );
      case SpeedTestStatus.error:
        return const _PrimaryButtonInfo(
          label: 'Retry Test',
          icon: Icons.refresh_rounded,
          enabled: true,
        );
      case SpeedTestStatus.idle:
      default:
        return const _PrimaryButtonInfo(
          label: 'Start Test',
          icon: Icons.play_arrow_rounded,
          enabled: true,
        );
    }
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HiVpnColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HiVpnColors.error.withOpacity(0.2)),
      ),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(color: HiVpnColors.error),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _InsightsView extends StatelessWidget {
  const _InsightsView({required this.state, super.key});

  final SpeedTestState state;

  @override
  Widget build(BuildContext context) {
    final insights = _SpeedInsights.fromState(state);
    final theme = Theme.of(context);

    if (!insights.hasInsights) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Results overview',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            'We could not capture enough data. Try running the test again.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Results overview',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (insights.positives.isNotEmpty)
          _InsightGroup(
            title: 'What looks good',
            icon: Icons.check_circle,
            color: HiVpnColors.success,
            items: insights.positives,
          ),
        if (insights.positives.isNotEmpty && insights.improvements.isNotEmpty)
          const SizedBox(height: 16),
        if (insights.improvements.isNotEmpty)
          _InsightGroup(
            title: 'Could be better',
            icon: Icons.info_outline,
            color: HiVpnColors.warning,
            items: insights.improvements,
          ),
      ],
    );
  }
}

class _InsightGroup extends StatelessWidget {
  const _InsightGroup({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SpeedInsights {
  const _SpeedInsights({
    required this.positives,
    required this.improvements,
  });

  final List<String> positives;
  final List<String> improvements;

  bool get hasInsights => positives.isNotEmpty || improvements.isNotEmpty;

  factory _SpeedInsights.fromState(SpeedTestState state) {
    final positives = <String>[];
    final improvements = <String>[];

    final download = state.downloadMbps;
    if (download >= 80) {
      positives.add('Download speed is excellent for ultra-high-definition streaming.');
    } else if (download >= 35) {
      positives.add('Download speed is ready for smooth HD streaming and browsing.');
    } else if (download > 0) {
      improvements.add('Download speed may struggle with HD streaming and large downloads.');
    }

    final upload = state.uploadMbps;
    if (upload >= 20) {
      positives.add('Upload speed supports clear video calls and quick backups.');
    } else if (upload > 0) {
      improvements.add('Upload speed could impact live streaming or cloud backups.');
    }

    final pingMs = state.ping?.inMilliseconds;
    if (pingMs != null) {
      if (pingMs <= 40) {
        positives.add('Latency is low enough for responsive gaming and calls.');
      } else if (pingMs <= 80) {
        positives.add('Latency is reasonable for everyday browsing and streaming.');
      } else {
        improvements.add('High latency might cause lag during gaming or video calls.');
      }
    }

    if (state.ip != null && state.ip!.isNotEmpty) {
      positives.add('Public IP detected: ${state.ip}.');
    } else {
      improvements.add('Public IP could not be detected during this run.');
    }

    return _SpeedInsights(
      positives: positives,
      improvements: improvements,
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    this.gradient,
  });

  final String title;
  final String value;
  final IconData icon;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? theme.colorScheme.surface : null,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.18),
                  theme.colorScheme.primary.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.onPrimary, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

