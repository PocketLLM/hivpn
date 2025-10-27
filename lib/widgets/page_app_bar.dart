import 'package:flutter/material.dart';

class HiVpnPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HiVpnPageAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
