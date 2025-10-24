import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/home/home_screen.dart';
import '../features/settings/domain/preferences_controller.dart';
import '../l10n/app_localizations.dart';
import '../theme/theme.dart';

class HiVpnApp extends ConsumerWidget {
  const HiVpnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesControllerProvider);
    final localeCode = preferences.localeCode;
    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      theme: buildHiVpnTheme(),
      debugShowCheckedModeBanner: false,
      locale: localeCode != null ? Locale(localeCode) : null,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeScreen(),
    );
  }
}
