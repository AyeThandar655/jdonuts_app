import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_colors.dart';

/// Shield badge with the tier initial and one star per tier level.
class TierShield extends StatelessWidget {
  const TierShield({
    super.key,
    required this.tierIndex,
    required this.size,
    required this.letter,
    this.highlighted = false,
  });

  final int tierIndex;
  final double size;
  final String letter;
  final bool highlighted;

  static const double _highlightScale = 1.12;

  /// Height / width of the shield.
  static const double aspectRatio = 1.15;

  Color _color(AppColors colors) => switch (tierIndex) {
        0 => colors.tierSilver,
        1 => colors.tierGold,
        _ => colors.tierPlatinum,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedScale(
      scale: highlighted ? _highlightScale : 1,
      duration: context.motion(AppDurations.medium),
      curve: AppCurves.spring,
      child: CustomPaint(
        size: Size(size, size * aspectRatio),
        painter: _ShieldPainter(
          color: _color(colors),
          ink: colors.textSecondary,
          glow: highlighted ? colors.accentPink : null,
          stars: tierIndex + 1,
          letter: letter,
          letterStyle: Theme.of(context).textTheme.titleMedium!,
        ),
      ),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  const _ShieldPainter({
    required this.color,
    required this.ink,
    required this.stars,
    required this.letter,
    required this.letterStyle,
    this.glow,
  });

  final Color color;
  final Color ink;
  final Color? glow;
  final int stars;
  final String letter;
  final TextStyle letterStyle;

  static const double _glowWidth = 3;
  static const double _shadeAmount = 0.25;
  static const double _starRadius = 0.07;
  static const double _starRow = 0.24;
  static const double _letterRow = 0.58;
  static const double _inkOpacity = 0.7;

  @override
  void paint(Canvas canvas, Size size) {
    final shield = _shieldPath(size);
    final darker = Color.lerp(color, ink, _shadeAmount)!;
    canvas.drawPath(
      shield,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, darker],
        ).createShader(Offset.zero & size),
    );
    final glowColor = glow;
    if (glowColor != null) {
      canvas.drawPath(
        shield,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _glowWidth
          ..color = glowColor,
      );
    }
    _drawStars(canvas, size);
    _drawLetter(canvas, size);
  }

  Path _shieldPath(Size s) => Path()
    ..moveTo(s.width * 0.5, 0)
    ..lineTo(s.width, s.height * 0.16)
    ..lineTo(s.width, s.height * 0.55)
    ..quadraticBezierTo(s.width, s.height * 0.85, s.width * 0.5, s.height)
    ..quadraticBezierTo(0, s.height * 0.85, 0, s.height * 0.55)
    ..lineTo(0, s.height * 0.16)
    ..close();

  void _drawStars(Canvas canvas, Size size) {
    final paint = Paint()..color = ink.withValues(alpha: _inkOpacity);
    final r = size.width * _starRadius;
    final y = size.height * _starRow;
    for (var i = 0; i < stars; i++) {
      final x = size.width * 0.5 + (i - (stars - 1) / 2) * r * 2.6;
      canvas.drawPath(_star(Offset(x, y), r), paint);
    }
  }

  Path _star(Offset c, double r) {
    const points = 5;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final radius = i.isEven ? r : r * 0.45;
      final a = -math.pi / 2 + math.pi * i / points;
      final p = c + Offset(math.cos(a), math.sin(a)) * radius;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  void _drawLetter(Canvas canvas, Size size) {
    final painter = TextPainter(
      text: TextSpan(
        text: letter,
        style: letterStyle.copyWith(color: ink.withValues(alpha: _inkOpacity)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final offset = Offset(
      (size.width - painter.width) / 2,
      size.height * _letterRow - painter.height / 2,
    );
    painter.paint(canvas, offset);
    painter.dispose();
  }

  @override
  bool shouldRepaint(_ShieldPainter old) =>
      old.color != color ||
      old.glow != glow ||
      old.stars != stars ||
      old.letter != letter;
}
