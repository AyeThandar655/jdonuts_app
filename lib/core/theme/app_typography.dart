import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type scale. Widgets use `Theme.of(context).textTheme` slots so sizes stay
/// in one place.
abstract final class AppTypography {
  static const String fontFamily = 'Poppins';

  static TextTheme textTheme(AppColors colors) => TextTheme(
        // Screen titles: "Enter your phone number", "Coconut Donut".
        headlineLarge: TextStyle(
          fontSize: 28,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
          letterSpacing: -0.4,
        ),
        // Onboarding / welcome hero lines.
        headlineMedium: TextStyle(
          fontSize: 26,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
          letterSpacing: -0.3,
        ),
        // Section headers: "Seasonal specials", member name.
        titleLarge: TextStyle(
          fontSize: 20,
          height: 1.25,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          height: 1.3,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        // Tile captions: product names under cards.
        titleSmall: TextStyle(
          fontSize: 13,
          height: 1.3,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.4,
          fontWeight: FontWeight.w400,
          color: colors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.45,
          fontWeight: FontWeight.w400,
          color: colors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          height: 1.4,
          fontWeight: FontWeight.w400,
          color: colors.textSecondary,
        ),
        // Button labels: "CONTINUE", "LET'S GET STARTED".
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: colors.onPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          height: 1.4,
          fontWeight: FontWeight.w500,
          color: colors.textMuted,
        ),
      );
}
