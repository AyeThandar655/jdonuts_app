import 'package:flutter/material.dart';

/// Every colour the app uses. Widgets read these through `context.colors`;
/// no widget hard-codes a colour value.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.accentPink,
    required this.accentOrange,
    required this.accentPurple,
    required this.accentGreen,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.surface,
    required this.surfaceMuted,
    required this.scaffold,
    required this.border,
    required this.error,
    required this.authGradientTop,
    required this.authGradientBottom,
    required this.homeHeader,
    required this.ringTrack,
    required this.ringTrackAlt,
    required this.tileBlue,
    required this.tilePink,
    required this.tilePeach,
    required this.tileYellow,
    required this.tierSilver,
    required this.tierGold,
    required this.tierPlatinum,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.shopsBackground,
    required this.shopsHill,
    required this.shopsHillDark,
    required this.shopsCloud,
    required this.offlineBanner,
    required this.disabled,
    required this.shadow,
    required this.brandGoogleBlue,
    required this.brandFacebook,
  });

  final Color primary;
  final Color onPrimary;
  final Color accentPink;
  final Color accentOrange;
  final Color accentPurple;
  final Color accentGreen;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color surface;
  final Color surfaceMuted;
  final Color scaffold;
  final Color border;
  final Color error;
  final Color authGradientTop;
  final Color authGradientBottom;
  final Color homeHeader;
  final Color ringTrack;
  final Color ringTrackAlt;
  final Color tileBlue;
  final Color tilePink;
  final Color tilePeach;
  final Color tileYellow;
  final Color tierSilver;
  final Color tierGold;
  final Color tierPlatinum;
  final Color skeletonBase;
  final Color skeletonHighlight;
  final Color shopsBackground;
  final Color shopsHill;
  final Color shopsHillDark;
  final Color shopsCloud;
  final Color offlineBanner;
  final Color disabled;
  final Color shadow;
  final Color brandGoogleBlue;
  final Color brandFacebook;

  static const AppColors light = AppColors(
    primary: Color(0xFF5BCDEA),
    onPrimary: Color(0xFFFFFFFF),
    accentPink: Color(0xFFEE4D96),
    accentOrange: Color(0xFFFF7A1F),
    accentPurple: Color(0xFF6A58D3),
    accentGreen: Color(0xFF4CC36B),
    textPrimary: Color(0xFF1F1D2B),
    textSecondary: Color(0xFF4A4858),
    textMuted: Color(0xFF9A98A6),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF0F1F3),
    scaffold: Color(0xFFF0F1F3),
    border: Color(0xFFE6E6EC),
    error: Color(0xFFE5484D),
    authGradientTop: Color(0xFFFDE6EE),
    authGradientBottom: Color(0xFFFFF7FA),
    homeHeader: Color(0xFFFFE8DC),
    ringTrack: Color(0xFFBFE9F5),
    ringTrackAlt: Color(0xFFEDEEF1),
    tileBlue: Color(0xFFC7E6F6),
    tilePink: Color(0xFFF9CCD9),
    tilePeach: Color(0xFFF8DCCD),
    tileYellow: Color(0xFFFDB227),
    tierSilver: Color(0xFFB9BCC4),
    tierGold: Color(0xFFF1CF63),
    tierPlatinum: Color(0xFFAEE3F4),
    skeletonBase: Color(0xFFE4E5EA),
    skeletonHighlight: Color(0xFFF5F5F8),
    shopsBackground: Color(0xFF5BCDEA),
    shopsHill: Color(0xFF8CCB5E),
    shopsHillDark: Color(0xFF5EA847),
    shopsCloud: Color(0xFFFFF4E6),
    offlineBanner: Color(0xFF2F2D3A),
    disabled: Color(0xFFE2E2E6),
    shadow: Color(0x1A1F1D2B),
    brandGoogleBlue: Color(0xFF4285F4),
    brandFacebook: Color(0xFF1877F2),
  );

  @override
  AppColors copyWith({Color? primary, Color? accentPink}) => AppColors(
        primary: primary ?? this.primary,
        onPrimary: onPrimary,
        accentPink: accentPink ?? this.accentPink,
        accentOrange: accentOrange,
        accentPurple: accentPurple,
        accentGreen: accentGreen,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        textMuted: textMuted,
        surface: surface,
        surfaceMuted: surfaceMuted,
        scaffold: scaffold,
        border: border,
        error: error,
        authGradientTop: authGradientTop,
        authGradientBottom: authGradientBottom,
        homeHeader: homeHeader,
        ringTrack: ringTrack,
        ringTrackAlt: ringTrackAlt,
        tileBlue: tileBlue,
        tilePink: tilePink,
        tilePeach: tilePeach,
        tileYellow: tileYellow,
        tierSilver: tierSilver,
        tierGold: tierGold,
        tierPlatinum: tierPlatinum,
        skeletonBase: skeletonBase,
        skeletonHighlight: skeletonHighlight,
        shopsBackground: shopsBackground,
        shopsHill: shopsHill,
        shopsHillDark: shopsHillDark,
        shopsCloud: shopsCloud,
        offlineBanner: offlineBanner,
        disabled: disabled,
        shadow: shadow,
        brandGoogleBlue: brandGoogleBlue,
        brandFacebook: brandFacebook,
      );

  /// Single light theme; interpolation snaps rather than blending tokens.
  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) =>
      other is AppColors && t >= 0.5 ? other : this;
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>() ?? AppColors.light;
}

/// Parses `#RRGGBB` colours that arrive as data (e.g. banner backgrounds).
Color colorFromHex(String hex, {required Color fallback}) {
  final cleaned = hex.replaceFirst('#', '');
  final value = int.tryParse(cleaned, radix: 16);
  if (value == null || cleaned.length != 6) return fallback;
  const opaqueAlpha = 0xFF000000;
  return Color(opaqueAlpha | value);
}
