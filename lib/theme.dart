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

  // Dark mode specific tokens
  static const backgroundDark = Color(0xFF0B1220);
  static const surfaceDark = Color(0xFF151C2C);
  static const surfaceDarkElevated = Color(0xFF1E293B);
  static const lineDark = Color(0xFF243048);
  static const mutedDark = Color(0xFF94A3B8);
}

class AppTheme {
  static ThemeData get light {
    final outfitFont = GoogleFonts.outfit().fontFamily;
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: outfitFont,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MfColors.primary,
        brightness: Brightness.light,
        primary: MfColors.primary,
        onPrimary: Colors.white,
        surface: MfColors.surface,
        onSurface: MfColors.ink,
      ),
    );

    final outfitText = GoogleFonts.outfitTextTheme(base.textTheme);
    final text = outfitText.copyWith(
      bodyLarge: outfitText.bodyLarge?.copyWith(color: MfColors.ink),
      bodyMedium: outfitText.bodyMedium?.copyWith(color: MfColors.ink),
      bodySmall: outfitText.bodySmall?.copyWith(color: MfColors.muted),
      titleLarge: outfitText.titleLarge?.copyWith(color: MfColors.ink, fontWeight: FontWeight.w700),
      titleMedium: outfitText.titleMedium?.copyWith(color: MfColors.ink, fontWeight: FontWeight.w700),
      titleSmall: outfitText.titleSmall?.copyWith(color: MfColors.ink, fontWeight: FontWeight.w600),
      labelLarge: outfitText.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      labelMedium: outfitText.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      labelSmall: outfitText.labelSmall?.copyWith(fontWeight: FontWeight.w500),
      headlineMedium: outfitText.headlineMedium?.copyWith(color: MfColors.ink, fontWeight: FontWeight.w700),
      headlineSmall: outfitText.headlineSmall?.copyWith(color: MfColors.ink, fontWeight: FontWeight.w700),
    );

    return base.copyWith(
      scaffoldBackgroundColor: MfColors.background,
      textTheme: text,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
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
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: MfColors.primary, width: 1.8),
        ),
        labelStyle: const TextStyle(color: MfColors.muted),
        hintStyle: const TextStyle(color: MfColors.muted),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFEEF2FF),
        selectedColor: MfColors.primary,
        checkmarkColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        labelStyle: text.labelLarge?.copyWith(color: MfColors.ink),
        secondaryLabelStyle: text.labelLarge?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
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
    final outfitFont = GoogleFonts.outfit().fontFamily;
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: outfitFont,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MfColors.primary,
        brightness: Brightness.dark,
        primary: MfColors.primarySoft,
        onPrimary: Colors.white,
        surface: MfColors.surfaceDark,
        onSurface: Colors.white,
      ),
    );

    final outfitText = GoogleFonts.outfitTextTheme(base.textTheme);
    final text = outfitText.copyWith(
      bodyLarge: outfitText.bodyLarge?.copyWith(color: Colors.white),
      bodyMedium: outfitText.bodyMedium?.copyWith(color: Colors.white),
      bodySmall: outfitText.bodySmall?.copyWith(color: MfColors.mutedDark),
      titleLarge: outfitText.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
      titleMedium: outfitText.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
      titleSmall: outfitText.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
      labelLarge: outfitText.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
      labelMedium: outfitText.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
      labelSmall: outfitText.labelSmall?.copyWith(fontWeight: FontWeight.w500, color: MfColors.mutedDark),
      headlineMedium: outfitText.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
      headlineSmall: outfitText.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
    );

    return base.copyWith(
      scaffoldBackgroundColor: MfColors.backgroundDark,
      textTheme: text,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: MfColors.backgroundDark,
        foregroundColor: Colors.white,
        titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: MfColors.surfaceDark,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        shadowColor: Colors.black.withValues(alpha: 0.3),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: MfColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: MfColors.lineDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MfColors.surfaceDarkElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: MfColors.lineDark, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: MfColors.lineDark, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: MfColors.primarySoft, width: 1.8),
        ),
        labelStyle: const TextStyle(color: MfColors.mutedDark),
        hintStyle: const TextStyle(color: MfColors.mutedDark),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: MfColors.surfaceDarkElevated,
        selectedColor: MfColors.primary,
        checkmarkColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        labelStyle: text.labelLarge?.copyWith(color: Colors.white),
        secondaryLabelStyle: text.labelLarge?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
        side: BorderSide.none,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: MfColors.surfaceDark,
        indicatorColor: MfColors.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStatePropertyAll(
          text.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      dividerColor: MfColors.lineDark,
    );
  }
}

