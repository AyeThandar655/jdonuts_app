import 'package:flutter/material.dart';

import '../motion/app_motion.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'pressable.dart';

/// The blue pill button ("CONTINUE", "LET'S GET STARTED").
///
/// While [isLoading] the pill morphs into a circle with a spinner and ignores
/// taps, so a double tap can never send a second request.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.trailing,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? trailing;
  final Color? color;

  static const double _spinnerSize = 22;
  static const double _spinnerStroke = 2.6;
  static const double _disabledOpacity = 0.45;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null && !isLoading;
    final duration = context.motion(AppDurations.medium);
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = MediaQuery.textScalerOf(context)
            .scale(AppSizes.buttonHeight)
            .clamp(AppSizes.buttonHeight, AppSizes.buttonHeight * 1.3);
        final width = isLoading ? height : constraints.maxWidth;
        return Center(
          child: Pressable(
            onTap: enabled ? onPressed : null,
            semanticLabel: label,
            child: AnimatedOpacity(
              opacity: onPressed == null && !isLoading ? _disabledOpacity : 1,
              duration: duration,
              child: AnimatedContainer(
                duration: duration,
                curve: AppCurves.emphasized,
                width: width,
                height: height,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color ?? colors.primary,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: AnimatedSwitcher(
                  duration: context.motion(AppDurations.short),
                  child: isLoading
                      ? SizedBox.square(
                          key: const ValueKey('loading'),
                          dimension: _spinnerSize,
                          child: CircularProgressIndicator(
                            strokeWidth: _spinnerStroke,
                            color: colors.onPrimary,
                          ),
                        )
                      : _Label(label: label, trailing: trailing),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.label, this.trailing});

  final String label;
  final String? trailing;

  static const double _dividerHeight = 18;
  static const double _dividerWidth = 1.2;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge;
    final colors = context.colors;
    final text = Text(
      label.toUpperCase(),
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    if (trailing == null) return text;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: text),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            width: _dividerWidth,
            height: _dividerHeight,
            color: colors.onPrimary,
          ),
          Text(trailing!, style: style, maxLines: 1),
        ],
      ),
    );
  }
}
