import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// MchongoFasta visual system — clean fintech UI, marketplace context.
class MfColors {
  static const primary = Color(0xFF2B6AFF);
  static const primaryDark = Color(0xFF1A2B56);
  static const primarySoft = Color(0xFF5B8CFF);
  static const background = Color(0xFFF2F4F7);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF0F172A);
  static const muted = Color(0xFF6B7280);
  static const line = Color(0xFFE5E7EB);
  static const warn = Color(0xFFF59E0B);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MfColors.primary,
        brightness: Brightness.light,
        primary: MfColors.primary,
        onPrimary: Colors.white,
        surface: MfColors.surface,
        onSurface: MfColors.ink,
      ),
    );

    final text = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
      bodyColor: MfColors.ink,
      displayColor: MfColors.ink,
    );

    return base.copyWith(
      scaffoldBackgroundColor: MfColors.background,
      textTheme: text,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: MfColors.background,
        foregroundColor: MfColors.ink,
        titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: MfColors.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        shadowColor: MfColors.ink.withValues(alpha: 0.06),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: MfColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MfColors.ink,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: MfColors.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        labelStyle: const TextStyle(color: MfColors.muted),
        hintStyle: const TextStyle(color: MfColors.muted),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFEEF2FF),
        selectedColor: MfColors.primary,
        labelStyle: text.labelLarge,
        secondaryLabelStyle: text.labelLarge?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: MfColors.surface,
        indicatorColor: MfColors.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStatePropertyAll(
          text.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      dividerColor: MfColors.line,
    );
  }

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MfColors.primary,
        brightness: Brightness.dark,
        primary: MfColors.primarySoft,
        onPrimary: Colors.white,
      ),
    );

    final text = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0B1220),
      textTheme: text,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF0B1220),
        titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF151C2C),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: MfColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF151C2C),
        indicatorColor: MfColors.primary.withValues(alpha: 0.2),
      ),
    );
  }
}
