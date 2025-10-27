import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/colors.dart';

enum ConnectButtonVisualState { idle, connecting, active }

class ConnectControl extends StatefulWidget {
  const ConnectControl({
    super.key,
    required this.enabled,
    required this.onTap,
    required this.label,
    this.isActive = false,
    this.isLoading = false,
    this.statusText,
    this.visualState = ConnectButtonVisualState.idle,
  });

  final bool enabled;
  final Future<void> Function()? onTap;
  final String label;
  final bool isActive;
  final bool isLoading;
  final String? statusText;
  final ConnectButtonVisualState visualState;

  @override
  State<ConnectControl> createState() => _ConnectControlState();
}

class _ConnectControlColors {
  const _ConnectControlColors({
    required this.primary,
    required this.secondary,
    required this.halo,
  });

  final Color primary;
  final Color secondary;
  final Color halo;
}

class _ConnectControlState extends State<ConnectControl>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  _ConnectControlColors _resolveColors(ThemeData theme) {
    switch (widget.visualState) {
      case ConnectButtonVisualState.connecting:
        const warning = HiVpnColors.warning;
        return _ConnectControlColors(
          primary: warning,
          secondary: _lighten(warning, 0.2),
          halo: warning,
        );
      case ConnectButtonVisualState.active:
        final primary = theme.colorScheme.primary;
        final secondary = theme.colorScheme.secondary;
        return _ConnectControlColors(
          primary: primary,
          secondary: secondary,
          halo: primary,
        );
      case ConnectButtonVisualState.idle:
      default:
        final primary = theme.colorScheme.primary;
        final secondary = theme.colorScheme.secondary;
        return _ConnectControlColors(
          primary: primary,
          secondary: secondary,
          halo: primary,
        );
    }
  }

  Color _lighten(Color color, [double amount = 0.2]) {
    return Color.lerp(color, Colors.white, amount) ?? color;
  }

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
    final isDisabled = !widget.enabled;
    final double size = 180;
    final colors = _resolveColors(theme);
    final primary = colors.primary;
    final secondary = colors.secondary;
    final halo = colors.halo;
    final onPrimary = theme.colorScheme.onPrimary;

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final pulse = widget.isActive
              ? (0.92 + 0.08 * sin(_controller.value * 2 * pi))
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
                    halo.withOpacity(widget.isActive ? 0.35 : 0.18),
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
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primary.withOpacity(0.12),
                    secondary.withOpacity(0.08),
                  ],
                ),
                border: Border.all(color: primary.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: halo.withOpacity(widget.isActive ? 0.25 : 0.12),
                    blurRadius: 32,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(160),
                onTap: isDisabled
                    ? null
                    : () async {
                        await widget.onTap?.call();
                      },
                child: Container(
                  width: size - 28,
                  height: size - 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: widget.isActive
                          ? [secondary, primary]
                          : [primary, secondary.withOpacity(0.9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(widget.isActive ? 0.35 : 0.22),
                        blurRadius: 30,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: widget.isLoading
                      ? SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(onPrimary),
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.label,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.statusText != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.statusText!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: onPrimary.withOpacity(0.92),
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
