import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get darkTheme {
    final textTheme = AppTypography.createTextTheme(isDark: true);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.navyDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.warmWhite,
        onPrimary: AppColors.navyDark,
        secondary: AppColors.highContrastFocus,
        onSecondary: AppColors.navyDark,
        surface: AppColors.cardDark,
        onSurface: AppColors.textLightPrimary,
        error: AppColors.error,
        onError: AppColors.warmWhite,
        outline: AppColors.navyBorder,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.navyBorder, width: 2),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.warmWhite,
          foregroundColor: AppColors.navyDark,
          minimumSize: const Size.fromHeight(60),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.warmWhite,
          minimumSize: const Size.fromHeight(60),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          side: const BorderSide(color: AppColors.warmWhite, width: 2.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navyDark,
        foregroundColor: AppColors.warmWhite,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(
          color: AppColors.warmWhite,
          size: 28,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.navyBorder,
        thickness: 2,
      ),
    );
  }

  static ThemeData get lightTheme {
    final textTheme = AppTypography.createTextTheme(isDark: false);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.warmWhite,
      colorScheme: const ColorScheme.light(
        primary: AppColors.navyDark,
        onPrimary: AppColors.warmWhite,
        secondary: AppColors.accessibleBlue,
        onSecondary: AppColors.warmWhite,
        surface: AppColors.cardLight,
        onSurface: AppColors.textDarkPrimary,
        error: AppColors.error,
        onError: AppColors.warmWhite,
        outline: AppColors.warmWhiteSecondary,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.warmWhiteSecondary, width: 2),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navyDark,
          foregroundColor: AppColors.warmWhite,
          minimumSize: const Size.fromHeight(60),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navyDark,
          minimumSize: const Size.fromHeight(60),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          side: const BorderSide(color: AppColors.navyDark, width: 2.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.warmWhite,
        foregroundColor: AppColors.navyDark,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(
          color: AppColors.navyDark,
          size: 28,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.warmWhiteSecondary,
        thickness: 2,
      ),
    );
  }
}
