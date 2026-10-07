import 'package:flutter/material.dart';

/// Theme tokens mirrored 1:1 from the web platform (light slate UI with
/// amber brand accent, indigo secondary, emerald success) so the app is
/// visually the same product as myindustryhouse.com.
class AppPalette {
  AppPalette._();

  // Brand accents (same values the web UI uses)
  static const Color primary = Color(0xFFF59E0B); // amber-500 buttons
  static const Color primaryDark = Color(0xFFD97706); // amber-600
  static const Color secondary = Color(0xFF4F46E5); // indigo-600
  static const Color success = Color(0xFF10B981); // emerald-500/600
  static const Color danger = Color(0xFFE11D48); // rose-600
  static const Color buyerAccent = Color(0xFF0EA5E9); // sky-500
  static const Color sellerAccent = Color(0xFF4F46E5); // indigo-600

  // Surfaces - web light theme: slate-50 page, white cards, slate-200 borders
  static const Color page = Color(0xFFF8FAFC); // slate-50 (web bg-[#F8FAFC])
  static const Color surface = Color(0xFFFFFFFF); // white cards
  static const Color border = Color(0xFFE2E8F0); // slate-200
  static const Color textPrimary = Color(0xFF0F172A); // slate-900
  static const Color textMuted = Color(0xFF64748B); // slate-500
  static const Color footerDark = Color(0xFF0F172A); // web footer slate-900
}

class AppTheme {
  AppTheme._();

  static const String fontFamily = 'PlusJakartaSans'; // web: Plus Jakarta Sans

  static ThemeData get light => ThemeData(
        fontFamily: fontFamily,
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppPalette.primary,
          onPrimary: Color(0xFF451A03), // amber-950 text on amber buttons
          secondary: AppPalette.secondary,
          onSecondary: Colors.white,
          surface: AppPalette.surface,
          onSurface: AppPalette.textPrimary,
          error: AppPalette.danger,
        ),
        scaffoldBackgroundColor: AppPalette.page,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppPalette.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppPalette.textPrimary,
          ),
        ),
        cardTheme: const CardThemeData(
          color: AppPalette.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: AppPalette.border),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppPalette.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppPalette.border),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(64, 48),
            backgroundColor: AppPalette.primary,
            foregroundColor: const Color(0xFF451A03),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: AppPalette.primary.withValues(alpha: 0.18),
          labelTextStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
        dividerColor: AppPalette.border,
        snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      );
}
