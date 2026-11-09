import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../../core/widgets/section_states.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../l10n/app_localizations.dart';
import '../../member/domain/member.dart';
import '../../member/member_providers.dart';
import '../../shell/presentation/main_shell.dart';
import 'widgets/points_ring.dart';
import 'widgets/reward_lists.dart';
import 'widgets/reward_tabs.dart';
import 'widgets/rewards_badge.dart';
import 'widgets/tier_ladder.dart';

/// Screen 10. Reads the same member record as Home.
class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  int _tab = 0;

  /// Bumped each time the tab is opened, so the entrance animations replay.
  int _visit = 0;

  static const double _bottomInset = AppSizes.bottomNavHeight + AppSpacing.xxxl;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(memberStatusProvider);
    ref.listen<int>(shellTabProvider, (previous, next) {
      if (next == ShellTab.rewards && previous != next) setState(() => _visit++);
    });
    return ColoredBox(
      color: colors.surfaceMuted,
      child: Column(
        children: [
          ColoredBox(
            color: colors.surface,
            child: const SafeArea(bottom: false, child: OfflineBanner()),
          ),
          Expanded(
            child: CustomScrollView(
              key: ValueKey(_visit),
              slivers: [
                SliverToBoxAdapter(
                  child: AsyncView<MemberStatus>(
                    value: status,
                    loading: () => const _TopSkeleton(),
                    error: (error) => Padding(
                      padding: const EdgeInsets.all(AppSpacing.l),
                      child: SectionError(
                        error: error,
                        onRetry: () => ref.invalidate(memberStatusProvider),
                      ),
                    ),
                    data: (s) => _Top(status: s),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _TabsBar(
                    labels: [l10n.rewardsTabEarn, l10n.rewardsTabGift],
                    selected: _tab,
                    onSelected: (i) => setState(() => _tab = i),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.gutter,
                    AppSpacing.l,
                    AppSpacing.gutter,
                    _bottomInset,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: AnimatedSwitcher(
                      duration: context.motion(AppDurations.medium),
                      switchInCurve: AppCurves.standard,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween(
                            begin: const Offset(0, AppMotionValues.slideDistance),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      layoutBuilder: (current, previous) => Stack(
                        alignment: Alignment.topCenter,
                        children: [...previous, ?current],
                      ),
                      child: _tab == 0
                          ? const ChallengeList(key: ValueKey('earn'))
                          : GiftList(
                              key: const ValueKey('gift'),
                              points: status.value?.member.totalPoints ?? 0,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// White top: title, Rewards badge, tier ladder and points ring.
class _Top extends StatelessWidget {
  const _Top({required this.status});

  final MemberStatus status;

  /// The ring is wider than its column and bleeds off the right edge.
  static const double _ringWidthFraction = 0.62;
  static const double _ringBleed = 0.1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final ringSize = width * _ringWidthFraction;
    return ColoredBox(
      color: context.colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              const SizedBox(width: AppSpacing.gutter),
              Expanded(
                child: Text(l10n.rewardsTitle, style: Theme.of(context).textTheme.headlineMedium),
              ),
              RewardsBadge(count: status.member.rewardsCount),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            height: MediaQuery.textScalerOf(context).scale(TierLadder.rowHeight) * status.tiers.length,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  left: AppSpacing.gutter,
                  top: 0,
                  bottom: 0,
                  width: width - ringSize * (1 - _ringBleed) - AppSpacing.gutter,
                  child: TierLadder(status: status),
                ),
                Positioned(
                  right: -ringSize * _ringBleed,
                  top: 0,
                  width: ringSize,
                  height: ringSize,
                  child: PointsRing(
                    progress: status.progressToNextTier,
                    totalPoints: status.member.totalPoints,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tabs sit on the white/grey boundary, like the design.
class _TabsBar extends StatelessWidget {
  const _TabsBar({
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: AppSizes.bottomNavPill / 2,
          child: ColoredBox(color: colors.surface),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: RewardTabs(
                labels: labels,
                selected: selected,
                onSelected: onSelected,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopSkeleton extends StatelessWidget {
  const _TopSkeleton();

  static const double _height = 360;

  @override
  Widget build(BuildContext context) => const Shimmer(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.gutter),
          child: SkeletonBox(height: _height, radius: AppRadii.xl),
        ),
      );
}
