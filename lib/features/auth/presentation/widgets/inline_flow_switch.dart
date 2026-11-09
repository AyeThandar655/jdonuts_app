import 'package:flutter/material.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/fade_slide_in.dart';

/// Inline server message under a field, optionally with a link
/// ("This number isn't registered. Register now").
class InlineFlowSwitch extends StatelessWidget {
  const InlineFlowSwitch({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  static const double _iconSize = 18;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return FadeSlideIn(
      duration: AppDurations.medium,
      child: Container(
        margin: const EdgeInsets.only(top: AppSpacing.m),
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.m),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, size: _iconSize, color: colors.error),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message, style: textTheme.bodySmall),
                  if (actionLabel != null)
                    GestureDetector(
                      onTap: onAction,
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          actionLabel!,
                          style: textTheme.labelMedium
                              ?.copyWith(color: colors.accentPink),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
