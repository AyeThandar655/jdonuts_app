import 'package:flutter/material.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/rewards.dart';
import 'challenge_art.dart';

const double _artSize = 112;

/// "Eat 4 Coco donuts  4/4  [EARN] 100 pts".
class ChallengeCard extends StatelessWidget {
  const ChallengeCard({super.key, required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _RewardCardFrame(
      art: ChallengeArt(challenge: challenge, size: _artSize),
      title: challenge.title,
      detail: l10n.rewardsProgress(challenge.progress, challenge.goal),
      button: EarnButton(active: challenge.isComplete, label: l10n.rewardsEarn),
      points: l10n.rewardsPoints(formatThousands(challenge.rewardPoints)),
    );
  }
}

/// A reward in the Gift tab.
class GiftCard extends StatelessWidget {
  const GiftCard({super.key, required this.gift, required this.affordable});

  final Gift gift;
  final bool affordable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _RewardCardFrame(
      art: SizedBox.square(dimension: _artSize, child: AppImage(gift.image)),
      title: gift.title,
      detail: l10n.rewardsGiftDetail,
      button: EarnButton(active: affordable, label: l10n.rewardsRedeem, pulse: false),
      points: l10n.rewardsPoints(formatThousands(gift.pointsCost)),
    );
  }
}

class _RewardCardFrame extends StatelessWidget {
  const _RewardCardFrame({
    required this.art,
    required this.title,
    required this.detail,
    required this.button,
    required this.points,
  });

  final Widget art;
  final String title;
  final String detail;
  final Widget button;
  final String points;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: Row(
        children: [
          art,
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(detail, style: textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.m),
                Wrap(
                  spacing: AppSpacing.m,
                  runSpacing: AppSpacing.s,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [button, Text(points, style: textTheme.bodyMedium)],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Blue when the reward can be claimed (with a few attention pulses), grey
/// otherwise. Press feedback only; no action.
class EarnButton extends StatefulWidget {
  const EarnButton({
    super.key,
    required this.active,
    required this.label,
    this.pulse = true,
  });

  final bool active;
  final String label;
  final bool pulse;

  @override
  State<EarnButton> createState() => _EarnButtonState();
}

class _EarnButtonState extends State<EarnButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: AppDurations.earnPulse);
  int _cycles = 0;

  /// The cue pulses a few times, then rests (keeps frames idle).
  static const int _maxCycles = 4;
  static const double _pulseScale = 0.08;

  @override
  void initState() {
    super.initState();
    _pulse.addStatusListener(_onStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.active && widget.pulse && !context.reduceMotion && _cycles == 0) {
      _pulse.forward();
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _cycles++;
    if (_cycles < _maxCycles && mounted) _pulse.forward(from: 0);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = Theme.of(context).textTheme.labelLarge;
    return Pressable(
      onTap: () {},
      semanticLabel: widget.label,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final wave = Curves.easeInOut.transform(1 - (2 * _pulse.value - 1).abs());
          return Transform.scale(scale: 1 + _pulseScale * wave, child: child);
        },
        child: AnimatedContainer(
          duration: context.motion(AppDurations.medium),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.m),
          decoration: BoxDecoration(
            color: widget.active ? colors.primary : colors.disabled,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Text(widget.label.toUpperCase(), style: style),
        ),
      ),
    );
  }
}
