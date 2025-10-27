import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.onFinishedBuilder});

  /// Builder that provides the next page once the splash animation completes.
  final WidgetBuilder? onFinishedBuilder;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _hiOpacity;
  late final Animation<Offset> _hiOffset;
  late final Animation<double> _vpnOpacity;
  late final Animation<double> _vpnLetterSpacing;
  late final Animation<double> _shimmerProgress;

  Timer? _navigationTimer;
  bool _navigationScheduled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _hiOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _hiOffset = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _vpnOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.9, curve: Curves.easeOut),
    );
    _vpnLetterSpacing = Tween<double>(begin: 6, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _shimmerProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    );

    _controller.forward();

    if (widget.onFinishedBuilder != null) {
      _scheduleNavigation();
    }
  }

  @override
  void didUpdateWidget(covariant SplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_navigationScheduled && widget.onFinishedBuilder != null) {
      _scheduleNavigation();
    }
  }

  void _scheduleNavigation() {
    _navigationScheduled = true;

    if (_controller.isAnimating) {
      _controller.forward(from: 0);
    } else {
      _controller.forward(from: 0);
    }

    final duration = _controller.duration ?? const Duration(milliseconds: 1300);
    _navigationTimer?.cancel();
    _navigationTimer = Timer(duration + const Duration(milliseconds: 50), () {
      if (!mounted) return;
      final builder = widget.onFinishedBuilder;
      if (builder == null) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = isDark ? const Color(0xFF0F1115) : const Color(0xFFF6F7FA);
    final hiColor = isDark ? Colors.white : const Color(0xFF0E1116);
    final vpnColor = const Color(0xFF2E7CF6);

    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FadeTransition(
                  opacity: _hiOpacity,
                  child: SlideTransition(
                    position: _hiOffset,
                    child: Text(
                      'hi',
                      style: theme.textTheme.displaySmall?.copyWith(
                            fontSize: 44,
                            fontWeight: FontWeight.w700,
                            color: hiColor,
                            letterSpacing: 0.2,
                            height: 1,
                          ) ??
                          TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w700,
                            color: hiColor,
                            letterSpacing: 0.2,
                            height: 1,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Opacity(
                  opacity: _vpnOpacity.value,
                  child: _ShimmerText(
                    text: 'VPN',
                    baseColor: vpnColor,
                    highlight: Colors.white.withOpacity(0.75),
                    progress: _shimmerProgress.value,
                    style: theme.textTheme.displaySmall?.copyWith(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          letterSpacing: _vpnLetterSpacing.value,
                          height: 1,
                        ) ??
                        TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          letterSpacing: _vpnLetterSpacing.value,
                          height: 1,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                _PulseDot(progress: _controller.value, color: vpnColor),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ShimmerText extends StatelessWidget {
  const _ShimmerText({
    required this.text,
    required this.style,
    required this.baseColor,
    required this.highlight,
    required this.progress,
  });

  final String text;
  final TextStyle style;
  final Color baseColor;
  final Color highlight;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final dx = -1.0 + (progress * 3.0);
    return ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(
          begin: Alignment(-1 + dx, 0),
          end: Alignment(1 + dx, 0),
          colors: [baseColor, highlight, baseColor],
          stops: const [0.35, 0.5, 0.65],
        ).createShader(rect);
      },
      blendMode: BlendMode.srcATop,
      child: Text(text, style: style.copyWith(color: baseColor)),
    );
  }
}

class _PulseDot extends StatelessWidget {
  const _PulseDot({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final normalized = progress.clamp(0.0, 1.0);
    final scale = normalized < 0.8
        ? 1 + (0.08 * Curves.easeOut.transform(normalized / 0.8))
        : 1.08;
    final opacity = normalized < 0.8 ? (0.5 + 0.5 * normalized / 0.8) : 1.0;

    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.45),
                blurRadius: 14,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
