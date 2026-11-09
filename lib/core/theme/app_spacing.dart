/// Spacing scale (logical pixels). Use these instead of literal paddings.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;

  /// Horizontal page gutter used by every screen.
  static const double gutter = 24;
}

/// Corner radii.
abstract final class AppRadii {
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double pill = 999;
}

/// Fixed component sizes from the design.
abstract final class AppSizes {
  static const double buttonHeight = 52;
  static const double inputHeight = 56;
  static const double iconButton = 40;
  static const double progressRing = 28;
  static const double otpBoxHeight = 56;
  static const double avatar = 56;
  static const double bottomNavHeight = 68;
  static const double bottomNavPill = 44;
  static const double maxTextScale = 1.3;
}
