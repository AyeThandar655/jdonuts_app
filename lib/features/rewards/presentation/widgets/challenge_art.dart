import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_image.dart';
import '../../domain/rewards.dart';

/// Shows a challenge's progress inside its own artwork.
class ChallengeArt extends StatelessWidget {
  const ChallengeArt({super.key, required this.challenge, required this.size});

  final Challenge challenge;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: challenge.fraction),
        duration: context.motion(AppDurations.challengeArt),
        curve: AppCurves.emphasized,
        builder: (context, value, _) => switch (challenge.artwork) {
          ChallengeArtwork.donut => _DonutQuarters(challenge: challenge, fraction: value),
          ChallengeArtwork.coffee => _CoffeeArc(challenge: challenge, fraction: value),
        },
      ),
    );
  }
}

/// The donut is grey and colours in clockwise, one quarter per step.
class _DonutQuarters extends StatelessWidget {
  const _DonutQuarters({required this.challenge, required this.fraction});

  final Challenge challenge;
  final double fraction;

  /// Luminance-preserving greyscale matrix.
  static const List<double> _greyscale = [
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0, //
  ];
  static const double _greyLift = 0.35;

  @override
  Widget build(BuildContext context) {
    final image = AppImage(challenge.image);
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: 1 - _greyLift,
          child: ColorFiltered(
            colorFilter: const ColorFilter.matrix(_greyscale),
            child: image,
          ),
        ),
        ClipPath(clipper: _SectorClipper(fraction), child: image),
      ],
    );
  }
}

class _SectorClipper extends CustomClipper<Path> {
  const _SectorClipper(this.fraction);

  final double fraction;

  @override
  Path getClip(Size size) {
    final center = size.center(Offset.zero);
    final radius = size.longestSide;
    if (fraction >= 1) return Path()..addRect(Offset.zero & size);
    return Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi * 2 * fraction,
        false,
      )
      ..close();
  }

  @override
  bool shouldReclip(_SectorClipper old) => old.fraction != fraction;
}

/// An arc fills over the coffee cup.
class _CoffeeArc extends StatelessWidget {
  const _CoffeeArc({required this.challenge, required this.fraction});

  final Challenge challenge;
  final double fraction;

  static const double _cupScale = 0.72;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CustomPaint(
      painter: _ArcPainter(
        fraction: fraction,
        track: colors.ringTrackAlt,
        fill: colors.accentOrange,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          widthFactor: _cupScale,
          heightFactor: _cupScale,
          child: AppImage(challenge.image),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({
    required this.fraction,
    required this.track,
    required this.fill,
  });

  final double fraction;
  final Color track;
  final Color fill;

  static const double _strokeFraction = 0.1;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * _strokeFraction;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    Paint paint(Color color) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = color;
    canvas.drawArc(rect, math.pi, math.pi, false, paint(track));
    if (fraction > 0) {
      canvas.drawArc(rect, math.pi, math.pi * fraction, false, paint(fill));
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.fraction != fraction || old.track != track || old.fill != fill;
}
