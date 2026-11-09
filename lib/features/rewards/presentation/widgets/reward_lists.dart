import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/section_states.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/rewards.dart';
import '../../rewards_providers.dart';
import 'challenge_card.dart';

/// "Eat more earn more" cards, entering one after another.
class ChallengeList extends ConsumerWidget {
  const ChallengeList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncView<List<Challenge>>(
      value: ref.watch(challengesProvider),
      loading: () => const _CardsSkeleton(),
      error: (error) => SectionError(
        error: error,
        onRetry: () => ref.invalidate(challengesProvider),
      ),
      data: (challenges) => challenges.isEmpty
          ? SectionEmpty(message: AppLocalizations.of(context).rewardsChallengesEmpty)
          : _Staggered(
              children: [
                for (final c in challenges)
                  ChallengeCard(key: Key('challenge-${c.id}'), challenge: c),
              ],
            ),
    );
  }
}

/// Gift tab cards; affordable gifts get the active button.
class GiftList extends ConsumerWidget {
  const GiftList({super.key, required this.points});

  final int points;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncView<List<Gift>>(
      value: ref.watch(giftsProvider),
      loading: () => const _CardsSkeleton(),
      error: (error) => SectionError(
        error: error,
        onRetry: () => ref.invalidate(giftsProvider),
      ),
      data: (gifts) => gifts.isEmpty
          ? SectionEmpty(message: AppLocalizations.of(context).rewardsGiftsEmpty)
          : _Staggered(
              children: [
                for (final g in gifts)
                  GiftCard(gift: g, affordable: points >= g.pointsCost),
              ],
            ),
    );
  }
}

class _Staggered extends StatelessWidget {
  const _Staggered({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.l),
            child: FadeSlideIn(
              delay: context.staggerDelay(i, step: AppDurations.stagger * 2),
              child: children[i],
            ),
          ),
      ],
    );
  }
}

class _CardsSkeleton extends StatelessWidget {
  const _CardsSkeleton();

  static const int _count = 3;
  static const double _height = 150;

  @override
  Widget build(BuildContext context) => Shimmer(
        child: Column(
          children: [
            for (var i = 0; i < _count; i++)
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.l),
                child: SkeletonBox(height: _height, radius: AppRadii.xl),
              ),
          ],
        ),
      );
}
