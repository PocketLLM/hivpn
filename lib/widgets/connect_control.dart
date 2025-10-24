import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/colors.dart';

class ConnectControl extends StatefulWidget {
  const ConnectControl({
    super.key,
    required this.enabled,
    required this.onTap,
    required this.label,
    this.isActive = false,
    this.isLoading = false,
    this.statusText,
  });

  final bool enabled;
  final VoidCallback? onTap;
  final String label;
  final bool isActive;
  final bool isLoading;
  final String? statusText;

  @override
  State<ConnectControl> createState() => _ConnectControlState();
}

class _ConnectControlState extends State<ConnectControl>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = !widget.enabled || widget.isLoading;
    final double size = 180;

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final pulse = widget.isActive
              ? (0.9 + 0.1 * sin(_controller.value * 2 * pi))
              : 1.0;
          return Transform.scale(
            scale: pulse,
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    HiVpnColors.primary.withOpacity(widget.isActive ? 0.45 : 0.25),
                    Colors.transparent,
                  ],
                  radius: 0.95,
                ),
              ),
            ),
            Container(
              width: size - 12,
              height: size - 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A2140), Color(0xFF2B2D7C)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: HiVpnColors.primary.withOpacity(widget.isActive ? 0.45 : 0.2),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(160),
                onTap: isDisabled ? null : widget.onTap,
                child: Container(
                  width: size - 28,
                  height: size - 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        HiVpnColors.primary.withOpacity(0.9),
                        HiVpnColors.accent.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.label,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: HiVpnColors.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.statusText != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.statusText!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: HiVpnColors.onPrimary.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
