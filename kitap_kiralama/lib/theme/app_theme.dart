import 'package:flutter/material.dart';
import 'package:kitap_kiralama/theme/app_palette.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppPalette.background,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: AppPalette.forest,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppPalette.forest,
          secondary: AppPalette.accent,
          surface: AppPalette.surface,
        ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.05,
        color: AppPalette.ink,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppPalette.ink,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppPalette.ink,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppPalette.ink,
      ),
      bodyLarge: TextStyle(fontSize: 15, height: 1.55, color: AppPalette.ink),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: AppPalette.muted),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppPalette.ink,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
