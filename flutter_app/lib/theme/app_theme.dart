import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFFFAF8F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceTint = Color(0xFFFDF2F5);

  static const Color primary = Color(0xFF9E4761);
  static const Color primaryDark = Color(0xFF7A3248);
  static const Color primarySoft = Color(0xFFF9E6EC);
  static const Color champagne = Color(0xFFFDE8D7);

  static const Color sage = Color(0xFF4D7C68);
  static const Color sageSoft = Color(0xFFEBF3EF);

  static const Color fridgeDark = Color(0xFF1E293B);
  static const Color fridgeDeep = Color(0xFF0F172A);
  static const Color iceAccent = Color(0xFF38BDF8);

  static const Color textPrimary = Color(0xFF1E1B1E);
  static const Color textSecondary = Color(0xFF57535A);
  static const Color borderSubtle = Color(0xFFE7E2E0);
  static const Color success = Color(0xFF2E7D5B);
  static const Color error = Color(0xFFDC2626);

  static const Color darkBackground = Color(0xFF121113);
  static const Color darkSurface = Color(0xFF1C1A1E);
  static const Color darkTextPrimary = Color(0xFFF5F3F5);
  static const Color darkTextSecondary = Color(0xFFB5AEB8);
  static const Color darkBorder = Color(0xFF2E2A32);
}

class AppTheme {
  static ThemeData buildTheme({required bool darkMode, required bool highContrast}) {
    final baseText = GoogleFonts.plusJakartaSansTextTheme();
    final bg = highContrast
        ? (darkMode ? Colors.black : Colors.white)
        : (darkMode ? AppColors.darkBackground : AppColors.background);
    final surf = highContrast
        ? (darkMode ? const Color(0xFF0D0D0D) : Colors.white)
        : (darkMode ? AppColors.darkSurface : AppColors.surface);
    final txtP = darkMode ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final txtS = highContrast ? txtP : (darkMode ? AppColors.darkTextSecondary : AppColors.textSecondary);
    final border = highContrast
        ? (darkMode ? Colors.white : Colors.black)
        : (darkMode ? AppColors.darkBorder : AppColors.borderSubtle);

    return ThemeData(
      useMaterial3: true,
      brightness: darkMode ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        brightness: darkMode ? Brightness.dark : Brightness.light,
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: surf,
      ),
      textTheme: baseText.copyWith(
        headlineMedium: baseText.headlineMedium?.copyWith(fontSize: 26, fontWeight: FontWeight.w800, color: txtP),
        headlineSmall: baseText.headlineSmall?.copyWith(fontSize: 22, fontWeight: FontWeight.w800, color: txtP),
        titleMedium: baseText.titleMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w700, color: txtP),
        bodyLarge: baseText.bodyLarge?.copyWith(fontSize: 15.5, color: txtP, height: 1.5),
        bodyMedium: baseText.bodyMedium?.copyWith(fontSize: 14.5, color: txtS, height: 1.5),
      ),
      appBarTheme: AppBarTheme(backgroundColor: bg, elevation: 0, scrolledUnderElevation: 0),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surf,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.8)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
