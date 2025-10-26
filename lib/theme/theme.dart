import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

ThemeData buildHiVpnTheme({String accentSeed = 'lavender'}) {
  final accent = _accentFromSeed(accentSeed);
  final baseScheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: Brightness.light,
  );

  final colorScheme = baseScheme.copyWith(
    primary: HiVpnColors.primary,
    onPrimary: HiVpnColors.onPrimary,
    primaryContainer: HiVpnColors.primaryContainer,
    onPrimaryContainer: HiVpnColors.primary,
    secondary: accent,
    onSecondary: HiVpnColors.onPrimary,
    background: HiVpnColors.background,
    onBackground: HiVpnColors.onSurface,
    surface: HiVpnColors.surface,
    onSurface: HiVpnColors.onSurface,
    surfaceVariant: const Color(0xFFE8EDFF),
    onSurfaceVariant: const Color(0xFF475569),
    outline: const Color(0xFFD6DBF5),
    error: HiVpnColors.error,
    onError: HiVpnColors.onPrimary,
  );

  final textTheme = GoogleFonts.interTextTheme(
    ThemeData.light().textTheme,
  ).apply(
    bodyColor: colorScheme.onSurface,
    displayColor: colorScheme.onSurface,
  );

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: colorScheme.background,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colorScheme.onSurface,
      contentTextStyle: TextStyle(color: colorScheme.onPrimary),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surface,
      titleTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: TextStyle(
        color: colorScheme.onSurface.withOpacity(0.8),
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: colorScheme.outline),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: EdgeInsets.zero,
    ),
  );
}

extension HiVpnThemeX on ThemeData {
  Color get elevatedSurface => Color.alphaBlend(
        colorScheme.onSurface.withOpacity(0.08),
        colorScheme.surface,
      );

  Color pastelCard(Color accent, {double opacity = 0.18}) {
    return Color.alphaBlend(accent.withOpacity(opacity), colorScheme.surface);
  }
}

Color _accentFromSeed(String seed) {
  switch (seed) {
    case 'aqua':
      return const Color(0xFF38BDF8);
    case 'sunrise':
      return const Color(0xFFF59E0B);
    case 'forest':
      return const Color(0xFF22C55E);
    case 'lavender':
    default:
      return HiVpnColors.accent;
  }
}
