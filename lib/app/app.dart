import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/home/home_screen.dart';
import '../features/settings/domain/settings_controller.dart';
import '../theme/theme.dart';

class HiVpnApp extends ConsumerWidget {
  const HiVpnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    return MaterialApp(
      title: 'HiVPN',
      theme: buildHiVpnTheme(accentSeed: settings.accentSeed),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
