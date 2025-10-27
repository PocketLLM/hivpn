import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hivpn/theme/colors.dart';

const List<double> _defaultTickValues = [0, 10, 20, 25, 30, 35, 40, 50, 100];

class SpeedGauge extends StatefulWidget {
  const SpeedGauge({
    super.key,
    required this.speed,
    required this.statusLabel,
    this.title,
    this.maxValue = 100,
    this.unit = 'Mbps',
    this.tickValues = _defaultTickValues,
  });

  final double speed;
  final double maxValue;
  final String statusLabel;
  final String? title;
  final String unit;
  final List<double> tickValues;

  @override
  State<SpeedGauge> createState() => _SpeedGaugeState();
}

class _SpeedGaugeState extends State<SpeedGauge> {
  double _previousSpeed = 0;

  @override
  void initState() {
    super.initState();
    _previousSpeed = widget.speed;
  }

  @override
  void didUpdateWidget(covariant SpeedGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    _previousSpeed = oldWidget.speed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedSpeed = (widget.speed / widget.maxValue).clamp(0, 1).toDouble();
    final previousNormalized = (_previousSpeed / widget.maxValue).clamp(0, 1).toDouble();
    final safeMax = widget.maxValue <= 0 ? 1 : widget.maxValue;

    return SizedBox(
      width: 260,
      height: 260,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: previousNormalized, end: normalizedSpeed),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, animatedProgress, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.18),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
              CustomPaint(
                size: const Size.square(240),
                painter: _GaugePainter(
                  progress: animatedProgress,
                  maxValue: safeMax,
                  tickValues: widget.tickValues,
                  textStyle: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ) ??
                      const TextStyle(fontSize: 11),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.title != null) ...[
                    Text(
                      widget.title!,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: _previousSpeed, end: widget.speed),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedSpeed, child) {
                      final display = animatedSpeed <= 0
                          ? '--'
                          : animatedSpeed.clamp(0, widget.maxValue).toStringAsFixed(1);
                      return Text(
                        display,
                        style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(widget.unit, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: HiVpnColors.surface.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        widget.statusLabel,
                        key: ValueKey(widget.statusLabel),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.progress,
    required this.tickValues,
    required this.maxValue,
    required this.textStyle,
  });

  final double progress;
  final List<double> tickValues;
  final double maxValue;
  final TextStyle textStyle;

  static const double _startAngle = -3 * math.pi / 4;
  static const double _sweepAngle = 3 * math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    final backgroundPaint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final progressPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: _startAngle,
        endAngle: _startAngle + _sweepAngle,
        colors: [HiVpnColors.primary, HiVpnColors.accent],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final tickPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final arcRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(arcRect, _startAngle, _sweepAngle, false, backgroundPaint);
    canvas.drawArc(arcRect, _startAngle, _sweepAngle * progress.clamp(0, 1), false, progressPaint);

    final labelRadius = radius + 22;
    final tickInnerRadius = radius - 8;
    for (final tick in tickValues) {
      final normalized = (tick / maxValue).clamp(0, 1).toDouble();
      final angle = _startAngle + _sweepAngle * normalized;
      final tickStart = Offset(
        center.dx + tickInnerRadius * math.cos(angle),
        center.dy + tickInnerRadius * math.sin(angle),
      );
      final tickEnd = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(tickStart, tickEnd, tickPaint);

      final label = tick % 1 == 0 ? tick.toInt().toString() : tick.toStringAsFixed(1);
      final textPainter = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final labelOffset = Offset(
        center.dx + labelRadius * math.cos(angle) - textPainter.width / 2,
        center.dy + labelRadius * math.sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, labelOffset);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.tickValues != tickValues ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.textStyle != textStyle;
  }
}
