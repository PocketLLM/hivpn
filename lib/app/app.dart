import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/home/home_screen.dart';
import '../features/onboarding/presentation/onboarding_flow.dart';
import '../features/splash/presentation/splash_screen.dart';
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
    final ready = ref.watch(preferencesReadyProvider);
    final preferences = ref.watch(preferencesControllerProvider);
    final localeCode = preferences.localeCode;
    final navigatorKey = ref.watch(navigatorKeyProvider);
    final home = ready.when<Widget>(
      data: (_) {
        return SplashScreen(
          onFinishedBuilder: (_) => preferences.onboardingCompleted
              ? const HomeScreen()
              : const OnboardingFlow(),
        );
      },
      loading: () => const SplashScreen(),
      error: (error, stack) => _AppError(message: error.toString()),
    );
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
      home: home,
    );
  }
}

class _AppError extends StatelessWidget {
  const _AppError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Failed to load preferences.\n$message',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
