import 'package:flutter/material.dart';

/// Rolling hills and clouds behind the nearby-shops cards.
class HillsPainter extends CustomPainter {
  const HillsPainter({
    required this.hill,
    required this.hillDark,
    required this.cloud,
  });

  final Color hill;
  final Color hillDark;
  final Color cloud;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cloudPaint = Paint()..color = cloud;
    canvas
      ..drawCircle(Offset(w * 0.86, h * 0.08), h * 0.22, cloudPaint)
      ..drawCircle(Offset(w * 0.98, h * 0.14), h * 0.26, cloudPaint)
      ..drawCircle(Offset(w * 0.06, h * 0.22), h * 0.18, cloudPaint);
    final back = Path()
      ..moveTo(0, h * 0.55)
      ..quadraticBezierTo(w * 0.25, h * 0.25, w * 0.55, h * 0.5)
      ..quadraticBezierTo(w * 0.8, h * 0.7, w, h * 0.4)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(back, Paint()..color = hill);
    final front = Path()
      ..moveTo(0, h * 0.8)
      ..quadraticBezierTo(w * 0.35, h * 0.55, w * 0.7, h * 0.78)
      ..quadraticBezierTo(w * 0.88, h * 0.9, w, h * 0.7)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(front, Paint()..color = hillDark);
  }

  @override
  bool shouldRepaint(HillsPainter old) =>
      old.hill != hill || old.hillDark != hillDark || old.cloud != cloud;
}
