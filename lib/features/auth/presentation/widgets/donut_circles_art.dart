import 'package:flutter/material.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_colors.dart';
import 'donut_assets.dart';

/// Onboarding hero: coloured circles holding donuts that drift in from the
/// edges, then fade into the background at the bottom.
class DonutCirclesArt extends StatelessWidget {
  const DonutCirclesArt({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final circles = [
      _CircleSpec(0.50, 0.36, 0.60, colors.tilePink, DonutAssets.pinkSprinkle, Offset.zero),
      _CircleSpec(0.02, 0.02, 0.40, colors.tileBlue, DonutAssets.purpleGlaze, const Offset(-1, -1)),
      _CircleSpec(0.98, 0.04, 0.38, colors.tilePink, DonutAssets.chocoDrizzle, const Offset(1, -1)),
      _CircleSpec(-0.02, 0.66, 0.42, colors.tileBlue, DonutAssets.purpleGlaze, const Offset(-1, 0)),
      _CircleSpec(1.02, 0.64, 0.42, colors.tileBlue, DonutAssets.matcha, const Offset(1, 0)),
      _CircleSpec(0.50, 0.98, 0.46, colors.tileYellow, DonutAssets.whiteSprinkle, const Offset(0, 1)),
    ];
    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              for (var i = 0; i < circles.length; i++)
                _DriftingCircle(spec: circles[i], width: width, index: i),
              const Positioned.fill(child: _BottomFade()),
            ],
          );
        },
      ),
    );
  }
}

class _CircleSpec {
  const _CircleSpec(this.x, this.y, this.diameter, this.color, this.asset, this.from);

  /// Centre and diameter as fractions of the art width.
  final double x;
  final double y;
  final double diameter;
  final Color color;
  final String asset;

  /// Direction the circle drifts in from.
  final Offset from;
}

class _DriftingCircle extends StatelessWidget {
  const _DriftingCircle({
    required this.spec,
    required this.width,
    required this.index,
  });

  final _CircleSpec spec;
  final double width;
  final int index;

  static const double _donutScale = 0.74;
  static const double _driftDistance = 60;
  static const double _startScale = 0.82;

  @override
  Widget build(BuildContext context) {
    final size = spec.diameter * width;
    return Positioned(
      left: spec.x * width - size / 2,
      top: spec.y * width - size / 2,
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: context.motion(AppDurations.onboardingDrift) +
            context.staggerDelay(index),
        curve: Interval(
          index * 0.06,
          1,
          curve: AppCurves.emphasized,
        ),
        builder: (context, t, child) => Opacity(
          opacity: t,
          child: Transform.translate(
            offset: spec.from * _driftDistance * (1 - t),
            child: Transform.scale(scale: _startScale + (1 - _startScale) * t, child: child),
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(color: spec.color, shape: BoxShape.circle),
          child: Center(
            child: Image.asset(spec.asset, width: size * _donutScale),
          ),
        ),
      ),
    );
  }
}

class _BottomFade extends StatelessWidget {
  const _BottomFade();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.55, 1],
            colors: [colors.authGradientBottom.withValues(alpha: 0), colors.authGradientBottom],
          ),
        ),
      ),
    );
  }
}
