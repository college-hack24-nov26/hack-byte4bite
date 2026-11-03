import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  static TextTheme createTextTheme({required bool isDark}) {
    final primaryColor =
        isDark ? AppColors.textLightPrimary : AppColors.textDarkPrimary;
    final secondaryColor =
        isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary;

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: primaryColor,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: primaryColor,
        height: 1.25,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        color: primaryColor,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: primaryColor,
        height: 1.3,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: primaryColor,
        height: 1.35,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: primaryColor,
        height: 1.35,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: primaryColor,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: secondaryColor,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: primaryColor,
        height: 1.2,
      ),
    );
  }
}

