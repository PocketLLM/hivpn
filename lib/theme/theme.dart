import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

ThemeData buildHiVpnTheme() {
  final colorScheme = const ColorScheme.dark(
    primary: HiVpnColors.primary,
    onPrimary: HiVpnColors.onPrimary,
    primaryContainer: HiVpnColors.primaryContainer,
    secondary: HiVpnColors.accent,
    onSecondary: HiVpnColors.background,
    background: HiVpnColors.background,
    onBackground: HiVpnColors.onSurface,
    surface: HiVpnColors.surface,
    onSurface: HiVpnColors.onSurface,
    error: HiVpnColors.error,
    onError: HiVpnColors.onPrimary,
  );

  final textTheme = GoogleFonts.interTextTheme(
    ThemeData.dark().textTheme,
  ).apply(
    bodyColor: colorScheme.onSurface,
    displayColor: colorScheme.onSurface,
  );

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: colorScheme.background,
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A2140),
      foregroundColor: HiVpnColors.onSurface,
      elevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colorScheme.surface,
      contentTextStyle: TextStyle(color: colorScheme.onSurface),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: colorScheme.surface,
      titleTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: TextStyle(
        color: colorScheme.onSurface.withOpacity(0.9),
        fontSize: 14,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
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
