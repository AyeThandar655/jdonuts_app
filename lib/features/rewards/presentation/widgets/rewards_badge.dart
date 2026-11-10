import 'package:flutter/material.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../l10n/app_localizations.dart';

/// Orange "Rewards (3)" pill flush with the right edge; pops in on entry.
class RewardsBadge extends StatelessWidget {
  const RewardsBadge({super.key, required this.count});

  final int count;

  static const double _counterSize = 24;
  static const Duration _entryDelay = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final delay = context.reduceMotion ? Duration.zero : _entryDelay;
    final total = context.motion(AppDurations.badgePop) + delay;
    final start = total == Duration.zero ? 0.0 : delay.inMicroseconds / total.inMicroseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: AppCurves.pop),
      builder: (context, t, child) => Transform.scale(
        scale: t,
        alignment: Alignment.centerRight,
        child: child,
      ),
      child: Pressable(
        onTap: () {},
        semanticLabel: AppLocalizations.of(context).rewardsBadge(count),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.s,
            AppSpacing.m,
            AppSpacing.s,
          ),
          decoration: BoxDecoration(
            color: colors.accentOrange,
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppRadii.pill)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context).rewardsBadgeLabel,
                style: textTheme.titleSmall?.copyWith(color: colors.onPrimary),
              ),
              const SizedBox(width: AppSpacing.s),
              Container(
                constraints: const BoxConstraints(minWidth: _counterSize, minHeight: _counterSize),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: colors.surface, shape: BoxShape.circle),
                child: Text(
                  '$count',
                  key: const Key('rewards-count'),
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
