import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static TextStyle get _baseFont => GoogleFonts.notoSansDevanagari();

  /// Fallback fonts for Tamil, Telugu, Kannada, Bengali, Gujarati (loaded in main).
  static const List<String> _fontFallbacks = [
    'Noto Sans Tamil',
    'Noto Sans Telugu',
    'Noto Sans Kannada',
    'Noto Sans Bengali',
    'Noto Sans Gujarati',
  ];

  static ThemeData get light {
    final baseTextTheme = GoogleFonts.notoSansDevanagariTextTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: _baseFont.fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: _baseFont.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: _baseFont.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: AppColors.primary.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: _baseFont.copyWith(
          color: AppColors.textHint,
          fontFamilyFallback: _fontFallbacks,
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: baseTextTheme.headlineLarge!.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          fontFamilyFallback: _fontFallbacks,
        ),
        headlineMedium: baseTextTheme.headlineMedium!.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          fontFamilyFallback: _fontFallbacks,
        ),
        titleLarge: baseTextTheme.titleLarge!.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          fontFamilyFallback: _fontFallbacks,
        ),
        titleMedium: baseTextTheme.titleMedium!.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          fontFamilyFallback: _fontFallbacks,
        ),
        bodyLarge: baseTextTheme.bodyLarge!.copyWith(
          fontSize: 16,
          color: AppColors.textPrimary,
          fontFamilyFallback: _fontFallbacks,
        ),
        bodyMedium: baseTextTheme.bodyMedium!.copyWith(
          fontSize: 14,
          color: AppColors.textSecondary,
          fontFamilyFallback: _fontFallbacks,
        ),
      ),
    );
  }
}
