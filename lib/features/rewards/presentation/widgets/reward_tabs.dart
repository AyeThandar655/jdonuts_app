import 'package:flutter/material.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Two pill tabs with an indicator that slides and resizes between them.
class RewardTabs extends StatelessWidget {
  const RewardTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  static const double _horizontalPadding = AppSpacing.xl;
  static const double _gap = AppSpacing.s;
  static const double _border = 3;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = Theme.of(context).textTheme.titleMedium!;
    final scaler = MediaQuery.textScalerOf(context);
    final widths = [
      for (final label in labels) _textWidth(label, style, scaler) + _horizontalPadding * 2,
    ];
    final height = scaler.scale(AppSizes.bottomNavPill);
    final left = [
      for (var i = 0; i < labels.length; i++)
        widths.take(i).fold<double>(0, (sum, w) => sum + w + _gap),
    ];
    return SizedBox(
      height: height,
      width: left.last + widths.last,
      child: Stack(
        children: [
          for (var i = 0; i < labels.length; i++)
            Positioned(
              left: left[i],
              width: widths[i],
              top: 0,
              bottom: 0,
              child: _pill(colors, colors.surface),
            ),
          AnimatedPositioned(
            duration: context.motion(AppDurations.medium),
            curve: AppCurves.emphasized,
            left: left[selected],
            width: widths[selected],
            top: 0,
            bottom: 0,
            child: _pill(colors, colors.primary),
          ),
          for (var i = 0; i < labels.length; i++)
            Positioned(
              left: left[i],
              width: widths[i],
              top: 0,
              bottom: 0,
              child: _TabLabel(
                key: Key('reward-tab-$i'),
                label: labels[i],
                selected: i == selected,
                style: style,
                onTap: () => onSelected(i),
              ),
            ),
        ],
      ),
    );
  }

  Widget _pill(AppColors colors, Color fill) => DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: colors.surface, width: _border),
        ),
      );

  double _textWidth(String text, TextStyle style, TextScaler scaler) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    super.key,
    required this.label,
    required this.selected,
    required this.style,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final TextStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: context.motion(AppDurations.medium),
            style: style.copyWith(
              color: selected ? colors.onPrimary : colors.textSecondary,
            ),
            child: Text(label, maxLines: 1),
          ),
        ),
      ),
    );
  }
}
