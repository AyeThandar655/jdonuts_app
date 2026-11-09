import 'package:flutter/material.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../member/domain/member.dart';
import 'tier_shield.dart';

/// Silver -> Gold -> Platinum. Tiers appear in order, the current one is
/// highlighted, and the line to the next tier fills to show progress.
class TierLadder extends StatelessWidget {
  const TierLadder({super.key, required this.status});

  final MemberStatus status;

  static const double rowHeight = 112;
  static const double shieldSize = 44;
  static const double _lineWidth = 3;

  @override
  Widget build(BuildContext context) {
    final tiers = status.tiers;
    final current = status.currentTierIndex;
    final rowExtent = MediaQuery.textScalerOf(context).scale(rowHeight);
    final lineDelay = context.staggerDelay(tiers.length, step: AppDurations.tierStep);
    return Stack(
      children: [
        Positioned(
          left: shieldSize / 2 - _lineWidth / 2,
          top: shieldSize * TierShield.aspectRatio,
          bottom: rowExtent,
          width: _lineWidth,
          child: _LadderLine(
            filledFraction: _lineFraction(current, tiers.length),
            delay: lineDelay,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < tiers.length; i++)
              SizedBox(
                height: rowExtent,
                child: FadeSlideIn(
                  delay: context.staggerDelay(i, step: AppDurations.tierStep),
                  offset: const Offset(-AppMotionValues.enterOffsetPx, 0),
                  child: _TierRow(
                    tier: tiers[i],
                    index: i,
                    currentIndex: current,
                    status: status,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// How much of the whole line is filled: every segment below the current
  /// tier, plus the progress inside the current segment.
  double _lineFraction(int current, int count) {
    final segments = count - 1;
    if (segments <= 0) return 0;
    return ((current + status.progressToNextTier) / segments).clamp(0.0, 1.0);
  }
}

class _LadderLine extends StatelessWidget {
  const _LadderLine({required this.filledFraction, required this.delay});

  final double filledFraction;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.border,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: FadeSlideIn(
        delay: delay,
        offset: Offset.zero,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: filledFraction),
          duration: context.motion(AppDurations.tierLineFill) + delay,
          curve: Interval(
            _delayFraction(context, delay),
            1,
            curve: AppCurves.standard,
          ),
          builder: (context, value, _) => Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              heightFactor: value,
              widthFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.textSecondary,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _delayFraction(BuildContext context, Duration delay) {
    final total = context.motion(AppDurations.tierLineFill) + delay;
    if (total == Duration.zero) return 0;
    return delay.inMicroseconds / total.inMicroseconds;
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({
    required this.tier,
    required this.index,
    required this.currentIndex,
    required this.status,
  });

  final Tier tier;
  final int index;
  final int currentIndex;
  final MemberStatus status;

  static const double _dimmedOpacity = 0.75;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final isCurrent = index == currentIndex;
    final subtitle = switch (index - currentIndex) {
      0 => l10n.rewardsTierCurrent,
      1 => l10n.rewardsTierRemaining(formatThousands(status.pointsToNextTier), tier.name),
      > 1 => l10n.rewardsTierSoon,
      _ => l10n.rewardsTierUnlocked,
    };
    return Opacity(
      opacity: isCurrent ? 1 : _dimmedOpacity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TierShield(
            tierIndex: index,
            size: TierLadder.shieldSize,
            highlighted: isCurrent,
            letter: tier.name.isEmpty ? '' : tier.name[0],
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tier.name, style: textTheme.titleMedium),
                Text(subtitle, style: textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
