import 'package:flutter/material.dart';

/// Shared construction-education palette and Material theme.
class AppColors {
  static const Color orange = Color(0xFFD96A1C);
  static const Color orangeDark = Color(0xFFB45309);
  static const Color orangeSoft = Color(0xFFF3E4D4);
  static const Color orangeMuted = Color(0xFFE8D2B8);
  static const Color background = Color(0xFFF6F3EF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color charcoal = Color(0xFF2B2926);
  static const Color muted = Color(0xFF6B6560);
  static const Color border = Color(0xFFE4DED6);
  static const Color success = Color(0xFF3D6B4F);
  static const Color danger = Color(0xFFB42318);
}

class AppTheme {
  static const double radius = 14;
  static const double cardElevation = 1.2;

  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: AppColors.orange,
      onPrimary: Colors.white,
      secondary: AppColors.orangeDark,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.charcoal,
      error: AppColors.danger,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.charcoal,
        elevation: 0,
        scrolledUnderElevation: 0.4,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.charcoal,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: cardElevation,
        shadowColor: const Color(0x14000000),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.orangeMuted,
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          minimumSize: const Size.fromHeight(50),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.orangeDark,
          side: const BorderSide(color: AppColors.orange, width: 1.4),
          minimumSize: const Size.fromHeight(50),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.orangeDark,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(color: AppColors.muted),
        hintStyle: const TextStyle(color: AppColors.muted),
        prefixIconColor: AppColors.orangeDark,
        suffixIconColor: AppColors.muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.orange, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.charcoal,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.orange,
      ),
      dividerColor: AppColors.border,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AppColors.charcoal,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.charcoal,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.charcoal,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          height: 1.55,
          color: AppColors.charcoal,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: AppColors.muted,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.muted,
        ),
      ),
    );
  }
}
