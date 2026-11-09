import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Number of registration steps tracked by the ring.
const int kRegistrationSteps = 4;

/// The small ring at the top right of each registration step.
///
/// It animates from the previous step's fill to this step's fill
/// (25 -> 50 -> 75 -> 100 %); on the last step it then morphs into a check.
class RegistrationProgressRing extends StatefulWidget {
  const RegistrationProgressRing({super.key, required this.step});

  /// 1-based step number.
  final int step;

  static const String heroTag = 'registration-progress-ring';

  @override
  State<RegistrationProgressRing> createState() =>
      _RegistrationProgressRingState();
}

class _RegistrationProgressRingState extends State<RegistrationProgressRing> {
  bool _showCheck = false;

  bool get _isLastStep => widget.step >= kRegistrationSteps;

  void _onFillDone() {
    if (!_isLastStep) return;
    // Deferred: with reduced motion the fill ends during the first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _showCheck = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final from = (widget.step - 1) / kRegistrationSteps;
    final to = widget.step / kRegistrationSteps;
    return Hero(
      tag: RegistrationProgressRing.heroTag,
      child: SizedBox.square(
        dimension: AppSizes.progressRing,
        child: AnimatedSwitcher(
          duration: context.motion(AppDurations.ringToCheck),
          switchInCurve: AppCurves.spring,
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: _showCheck
              ? const _CheckBadge(key: ValueKey('check'))
              : TweenAnimationBuilder<double>(
                  key: const ValueKey('ring'),
                  tween: Tween(begin: from, end: to),
                  duration: context.motion(AppDurations.progressRing),
                  curve: AppCurves.emphasized,
                  onEnd: _onFillDone,
                  // SizedBox.expand: a child-less CustomPaint would get the
                  // switcher's loose constraints and size itself to 0x0.
                  builder: (context, value, _) => SizedBox.expand(
                    child: CustomPaint(
                      painter: _RingPainter(
                        progress: value,
                        track: context.colors.ringTrack,
                        fill: context.colors.accentPink,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _CheckBadge extends StatelessWidget {
  const _CheckBadge({super.key});

  static const double _iconSize = 18;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.accentPink, shape: BoxShape.circle),
      child: Center(
        child: Icon(Icons.check_rounded, size: _iconSize, color: colors.onPrimary),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.track,
    required this.fill,
  });

  final double progress;
  final Color track;
  final Color fill;

  static const double _strokeFraction = 0.24;
  static const double _startAngle = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * _strokeFraction;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    final fillPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt
      ..color = fill;
    canvas.drawArc(arcRect, 0, math.pi * 2, false, trackPaint);
    canvas.drawArc(arcRect, _startAngle, math.pi * 2 * progress, false, fillPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.track != track || old.fill != fill;
}
