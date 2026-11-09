import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/placeholder_sheet.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../core/widgets/section_states.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../member/domain/member.dart';
import '../../../member/member_providers.dart';
import 'tier_badge_painter.dart';

/// Member name and photo, tier, points to the next tier and the bell.
class MemberHeader extends ConsumerWidget {
  const MemberHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncView<MemberStatus>(
      value: ref.watch(memberStatusProvider),
      data: (status) => _Header(status: status),
      loading: () => const _HeaderSkeleton(),
      error: (error) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
        child: SectionError(
          error: error,
          onRetry: () => ref.invalidate(memberStatusProvider),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.status});

  final MemberStatus status;

  static const double _badgeSize = 150;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final member = status.member;
    final textTheme = Theme.of(context).textTheme;
    final next = status.nextTier;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          right: -AppSpacing.xxl,
          top: -AppSpacing.l,
          child: SizedBox.square(
            dimension: _badgeSize,
            child: CustomPaint(painter: TierBadgePainter(color: context.colors.surface)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Avatar(member: member),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member.displayName, style: textTheme.headlineMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(l10n.homeTierMember(status.currentTier.name), style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                  _Bell(count: member.notificationCount),
                ],
              ),
              if (next != null) ...[
                const SizedBox(height: AppSpacing.m),
                _PointsPill(text: l10n.homePointsToNext(formatThousands(status.pointsToNextTier), next.name)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.member});

  final Member member;

  static const double _border = 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.avatar,
      height: AppSizes.avatar,
      padding: const EdgeInsets.all(_border),
      decoration: BoxDecoration(color: context.colors.surface, shape: BoxShape.circle),
      child: ClipOval(child: AppImage(member.photo, fit: BoxFit.cover)),
    );
  }
}

class _Bell extends StatelessWidget {
  const _Bell({required this.count});

  final int count;

  static const double _iconSize = 20;
  static const double _badgeSize = 18;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Pressable(
      semanticLabel: l10n.homeNotifications(count),
      onTap: () => showPlaceholderSheet(context, title: l10n.homeNotifications(count)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
        decoration: BoxDecoration(
          color: colors.accentOrange,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none_rounded, size: _iconSize, color: colors.onPrimary),
            if (count > 0) ...[
              const SizedBox(width: AppSpacing.xs),
              Container(
                constraints: const BoxConstraints(minWidth: _badgeSize, minHeight: _badgeSize),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: colors.surface, shape: BoxShape.circle),
                child: Text(
                  '$count',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.accentOrange,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PointsPill extends StatelessWidget {
  const _PointsPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.colors.textPrimary)),
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  static const double _nameWidth = 120;
  static const double _lineHeight = 14;
  static const double _pillWidth = 200;

  @override
  Widget build(BuildContext context) {
    return const Shimmer(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonBox(width: AppSizes.avatar, height: AppSizes.avatar, radius: AppRadii.pill),
                SizedBox(width: AppSpacing.m),
                SkeletonBox(width: _nameWidth, height: _lineHeight * 2),
              ],
            ),
            SizedBox(height: AppSpacing.m),
            SkeletonBox(width: _pillWidth, height: _lineHeight),
          ],
        ),
      ),
    );
  }
}
