import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';

/// The big frosted-donut ring: sweeps from 0 to [progress] while the total
/// in the middle counts up to [totalPoints].
class PointsRing extends StatelessWidget {
  const PointsRing({
    super.key,
    required this.progress,
    required this.totalPoints,
  });

  final double progress;
  final int totalPoints;

  static const Key totalKey = Key('points-total');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: context.motion(AppDurations.pointsRing),
      curve: AppCurves.emphasized,
      builder: (context, t, _) => CustomPaint(
        painter: PointsRingPainter(
          progress: progress * t,
          track: colors.ringTrackAlt,
          frosting: colors.accentPink,
          sprinkle: colors.surface,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.rewardsTotalPoints,
                style: textTheme.labelMedium?.copyWith(color: colors.accentPink),
              ),
              FittedBox(
                child: Text(
                  formatThousands((totalPoints * t).round()),
                  key: totalKey,
                  style: textTheme.headlineMedium?.copyWith(color: colors.accentPink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws a grey track and a pink frosting arc with sprinkles.
class PointsRingPainter extends CustomPainter {
  const PointsRingPainter({
    required this.progress,
    required this.track,
    required this.frosting,
    required this.sprinkle,
  });

  final double progress;
  final Color track;
  final Color frosting;
  final Color sprinkle;

  /// Arc starts at the lower left, like the design.
  static const double _startAngle = math.pi * 0.62;
  static const double _strokeFraction = 0.36;
  static const double _sprinkleSpacing = math.pi / 9;
  static const double _sprinkleLength = 0.09;
  static const double _sprinkleWidth = 0.022;
  static const double _sprinkleOpacity = 0.75;
  static const double _shadeOpacity = 0.25;
  static const double _highlightOpacity = 0.35;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2;
    final stroke = radius * _strokeFraction;
    final center = size.center(Offset.zero);
    final arcRect = Rect.fromCircle(center: center, radius: radius - stroke / 2);
    canvas.drawArc(arcRect, 0, math.pi * 2, false, _stroke(stroke, track));
    final sweep = math.pi * 2 * progress.clamp(0.0, 1.0);
    if (sweep <= 0) return;
    _drawFrosting(canvas, arcRect, stroke, sweep);
    _drawSprinkles(canvas, center, radius - stroke / 2, stroke, sweep);
  }

  Paint _stroke(double width, Color color) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..color = color;

  void _drawFrosting(Canvas canvas, Rect arcRect, double stroke, double sweep) {
    canvas.drawArc(arcRect, _startAngle, sweep, false, _stroke(stroke, frosting));
    final shade = Color.lerp(frosting, track, _shadeOpacity)!;
    canvas.drawArc(
      arcRect.deflate(stroke * 0.3),
      _startAngle,
      sweep,
      false,
      _stroke(stroke * 0.25, shade.withValues(alpha: _highlightOpacity)),
    );
  }

  void _drawSprinkles(
    Canvas canvas,
    Offset center,
    double midRadius,
    double stroke,
    double sweep,
  ) {
    final paint = Paint()
      ..color = sprinkle.withValues(alpha: _sprinkleOpacity)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = midRadius * 2 * _sprinkleWidth;
    final length = midRadius * 2 * _sprinkleLength / 2;
    var i = 0;
    for (var a = _sprinkleSpacing / 2; a < sweep; a += _sprinkleSpacing, i++) {
      final angle = _startAngle + a;
      final offsetRadius = midRadius + (i.isEven ? stroke * 0.18 : -stroke * 0.2);
      final c = center + Offset(math.cos(angle), math.sin(angle)) * offsetRadius;
      final tilt = angle + (i.isEven ? 0.9 : -0.6);
      final d = Offset(math.cos(tilt), math.sin(tilt)) * length;
      canvas.drawLine(c - d, c + d, paint);
    }
  }

  @override
  bool shouldRepaint(PointsRingPainter old) =>
      old.progress != progress ||
      old.track != track ||
      old.frosting != frosting ||
      old.sprinkle != sprinkle;
}
