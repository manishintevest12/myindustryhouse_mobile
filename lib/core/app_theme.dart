import 'package:flutter/material.dart';

/// Theme tokens mirrored from the web platform so the app feels like the
/// same product, tuned for mobile touch targets (min 48dp) and dark-first
/// industrial look.
class AppPalette {
  AppPalette._();

  // Brand accents (match web: amber primary, emerald success, rose danger)
  static const Color primary = Color(0xFFF59E0B); // amber-500
  static const Color primaryDark = Color(0xFFD97706); // amber-600
  static const Color success = Color(0xFF10B981); // emerald-500
  static const Color danger = Color(0xFFE11D48); // rose-600
  static const Color buyerAccent = Color(0xFF0EA5E9); // sky-500
  static const Color sellerAccent = Color(0xFF8B5CF6); // violet-500

  // Surfaces (web slate scale)
  static const Color surface = Color(0xFF0F172A); // slate-900
  static const Color surfaceAlt = Color(0xFF1E293B); // slate-800
  static const Color border = Color(0xFF334155); // slate-700
  static const Color textPrimary = Color(0xFFF8FAFC); // slate-50
  static const Color textMuted = Color(0xFF94A3B8); // slate-400
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppPalette.primary,
          onPrimary: const Color(0xFF1C1917),
          secondary: AppPalette.sellerAccent,
          surface: AppPalette.surface,
          error: AppPalette.danger,
        ),
        scaffoldBackgroundColor: AppPalette.surface,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppPalette.surfaceAlt,
          foregroundColor: AppPalette.textPrimary,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: const CardThemeData(
          color: AppPalette.surfaceAlt,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: AppPalette.border),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppPalette.surfaceAlt,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppPalette.border),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(64, 48), // mobile touch target
            backgroundColor: AppPalette.primary,
            foregroundColor: const Color(0xFF1C1917),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppPalette.surfaceAlt,
          indicatorColor: AppPalette.primary.withValues(alpha: 0.18),
          labelTextStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
        dividerColor: AppPalette.border,
      );
}
