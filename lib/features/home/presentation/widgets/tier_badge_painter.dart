import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Faint hexagon-with-star watermark behind the Home member header.
class TierBadgePainter extends CustomPainter {
  const TierBadgePainter({required this.color});

  final Color color;

  static const int _hexSides = 6;
  static const int _starPoints = 5;
  static const double _hexOpacity = 0.45;
  static const double _starOpacity = 0.7;
  static const double _starOuter = 0.32;
  static const double _starInner = 0.14;
  static const double _cornerRadius = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final hex = _polygon(center, radius, _hexSides, math.pi / _hexSides);
    canvas.drawPath(
      hex,
      Paint()
        ..color = color.withValues(alpha: _hexOpacity)
        ..style = PaintingStyle.fill
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = _cornerRadius,
    );
    canvas.drawPath(
      _star(center, radius * _starOuter * 2, radius * _starInner * 2),
      Paint()..color = color.withValues(alpha: _starOpacity),
    );
  }

  Path _polygon(Offset c, double r, int sides, double rotation) {
    final path = Path();
    for (var i = 0; i < sides; i++) {
      final a = rotation + 2 * math.pi * i / sides;
      final p = c + Offset(math.cos(a), math.sin(a)) * r;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  Path _star(Offset c, double outer, double inner) {
    final path = Path();
    for (var i = 0; i < _starPoints * 2; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + math.pi * i / _starPoints;
      final p = c + Offset(math.cos(a), math.sin(a)) * r;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(TierBadgePainter old) => old.color != color;
}
