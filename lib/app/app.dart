import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/home/home_screen.dart';
import '../features/settings/domain/preferences_controller.dart';
import '../l10n/app_localizations.dart';
import '../platform/android/extend_intent_handler.dart';
import '../theme/theme.dart';

final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});

class HiVpnApp extends ConsumerWidget {
  const HiVpnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(extendIntentHandlerProvider);
    final preferences = ref.watch(preferencesControllerProvider);
    final localeCode = preferences.localeCode;
    final navigatorKey = ref.watch(navigatorKeyProvider);
    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      theme: buildHiVpnTheme(),
      debugShowCheckedModeBanner: false,
      locale: localeCode != null ? Locale(localeCode) : null,
      navigatorKey: navigatorKey,
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
