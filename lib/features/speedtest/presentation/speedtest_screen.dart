import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/colors.dart';
import '../../../theme/theme.dart';
import '../domain/speedtest_controller.dart';
import '../domain/speedtest_state.dart';

class SpeedTestScreen extends ConsumerWidget {
  const SpeedTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(speedTestControllerProvider);
    final controller = ref.read(speedTestControllerProvider.notifier);
    final theme = Theme.of(context);
    final surface = theme.pastelCard(theme.colorScheme.primaryContainer, opacity: 0.12);
    final accentSurface = theme.pastelCard(theme.colorScheme.secondary, opacity: 0.16);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Speed Test',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          SpeedGauge(
            value: state.gaugeValue,
            label: state.status == SpeedTestStatus.running ? 'Testing…' : 'Normal',
            speed: state.downloadMbps,
            status: state.status,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _MetricCard(
                title: 'Download',
                value: state.downloadMbps > 0 ? '${state.downloadMbps.toStringAsFixed(1)} Mbps' : '--',
                icon: Icons.download_rounded,
                background: accentSurface,
              ),
              _MetricCard(
                title: 'Upload',
                value: state.uploadSeries.isEmpty
                    ? 'Pending'
                    : '${state.uploadMbps.toStringAsFixed(1)} Mbps',
                icon: Icons.upload_rounded,
                background: surface,
              ),
              _MetricCard(
                title: 'Ping',
                value: state.ping != null
                    ? '${state.ping!.inMilliseconds} ms'
                    : (state.status == SpeedTestStatus.idle ? '--' : 'Measuring'),
                icon: Icons.podcasts,
                background: surface,
              ),
              _MetricCard(
                title: 'IP',
                value: state.ip ?? 'Detecting…',
                icon: Icons.language,
                background: surface,
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (state.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: HiVpnColors.error.withOpacity(0.16),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                state.errorMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(color: HiVpnColors.error),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: state.status == SpeedTestStatus.running ? null : () => controller.run(),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(state.status == SpeedTestStatus.running ? 'Running…' : 'Try Again'),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.background,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.onSurface.withOpacity(0.7)),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
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

class SpeedGauge extends StatelessWidget {
  const SpeedGauge({
    super.key,
    required this.value,
    required this.label,
    required this.speed,
    required this.status,
    this.maxMbps = 200,
  });

  final double value;
  final double speed;
  final double maxMbps;
  final String label;
  final SpeedTestStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  HiVpnColors.primary.withOpacity(0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value),
            duration: const Duration(milliseconds: 600),
            builder: (context, animated, child) {
              return CustomPaint(
                size: const Size.square(220),
                painter: _GaugePainter(animated),
              );
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                speed > 0 ? speed.toStringAsFixed(1) : '--',
                style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text('Mbps', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: HiVpnColors.surface.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              if (status == SpeedTestStatus.complete && speed <= 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Run test to get values',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final backgroundPaint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final progressPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: -3.14 / 2,
        endAngle: 3.14 / 2,
        colors: [HiVpnColors.primary, HiVpnColors.accent],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final startAngle = -3.14 * 0.75;
    final sweep = 3.14 * 1.5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      backgroundPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep * value.clamp(0, 1),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) => oldDelegate.value != value;
}
