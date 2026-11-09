import 'package:flutter/widgets.dart';

/// Every duration and curve used in the app, in one place.
abstract final class AppDurations {
  static const Duration instant = Duration(milliseconds: 90);
  static const Duration press = Duration(milliseconds: 120);
  static const Duration short = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 320);
  static const Duration long = Duration(milliseconds: 520);
  static const Duration page = Duration(milliseconds: 420);
  static const Duration stagger = Duration(milliseconds: 70);
  static const Duration entrance = Duration(milliseconds: 600);
  static const Duration onboardingDrift = Duration(milliseconds: 1100);
  static const Duration progressRing = Duration(milliseconds: 650);
  static const Duration ringToCheck = Duration(milliseconds: 380);
  static const Duration otpShake = Duration(milliseconds: 460);
  static const Duration shimmer = Duration(milliseconds: 1300);
  static const Duration carouselInterval = Duration(seconds: 4);
  static const Duration carouselSlide = Duration(milliseconds: 550);
  static const Duration pointsRing = Duration(milliseconds: 1600);
  static const Duration tierStep = Duration(milliseconds: 260);
  static const Duration tierLineFill = Duration(milliseconds: 700);
  static const Duration challengeArt = Duration(milliseconds: 900);
  static const Duration badgePop = Duration(milliseconds: 520);
  static const Duration earnPulse = Duration(milliseconds: 1100);
  static const Duration navPill = Duration(milliseconds: 360);
  static const Duration offlineBanner = Duration(milliseconds: 260);
}

abstract final class AppCurves {
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuart;
  static const Curve decelerate = Curves.decelerate;
  static const Curve spring = Curves.easeOutBack;
  static const Curve pop = Curves.elasticOut;
  static const Curve page = Curves.easeInOutCubic;
  static const Curve linear = Curves.linear;
}

/// Scale factors and offsets that shape motion (no magic numbers in widgets).
abstract final class AppMotionValues {
  static const double pressedScale = 0.96;
  static const double slideDistance = 0.12;
  static const double enterOffsetPx = 24;
  static const double shakeDistancePx = 10;
  static const int shakeCycles = 3;
  static const double reducedMotionFactor = 0;
}

extension MotionContext on BuildContext {
  /// True when the OS asks for reduced motion.
  bool get reduceMotion => MediaQuery.maybeDisableAnimationsOf(this) ?? false;

  /// Returns [duration], or [Duration.zero] when reduced motion is on.
  Duration motion(Duration duration) => reduceMotion ? Duration.zero : duration;

  /// A stagger delay for item [index], collapsed when reduced motion is on.
  Duration staggerDelay(int index, {Duration step = AppDurations.stagger}) =>
      reduceMotion ? Duration.zero : step * index;
}
