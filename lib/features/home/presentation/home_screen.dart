import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../../core/widgets/section_states.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/catalog.dart';
import '../home_providers.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/member_header.dart';
import 'widgets/product_section.dart';
import 'widgets/shops_section.dart';

/// Screen 8. Every section reads the local database and has its own loading,
/// empty and error state; pull-to-refresh syncs from the server if any.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const Key scrollKey = Key('home-scroll');

  /// Leaves room for the floating bottom navigation bar.
  static const double _bottomInset = AppSizes.bottomNavHeight + AppSpacing.xxxl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    ref.watch(catalogSyncProvider);
    return ColoredBox(
      color: colors.scaffold,
      child: Column(
        children: [
          ColoredBox(
            color: colors.homeHeader,
            child: const SafeArea(bottom: false, child: OfflineBanner()),
          ),
          Expanded(
            child: RefreshIndicator(
              color: colors.accentPink,
              onRefresh: () => ref.read(catalogSyncProvider.notifier).refresh(),
              child: CustomScrollView(
                key: scrollKey,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: _HeaderWithBanners()),
                  const SliverToBoxAdapter(child: _Sections()),
                  const SliverToBoxAdapter(child: _Shops()),
                  SliverToBoxAdapter(
                    child: ColoredBox(
                      color: colors.shopsBackground,
                      child: const SizedBox(height: _bottomInset),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Peach header with the carousel overlapping into the grey page.
class _HeaderWithBanners extends ConsumerWidget {
  const _HeaderWithBanners();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final overlap = MediaQuery.textScalerOf(context).scale(kBannerHeight) / 2;
    return Stack(
      children: [
        Positioned.fill(
          bottom: overlap,
          child: ColoredBox(color: colors.homeHeader),
        ),
        Column(
          children: [
            const MemberHeader(),
            AsyncView<List<PromoBanner>>(
              value: ref.watch(bannersProvider),
              loading: () => const BannerCarouselSkeleton(),
              error: (error) => SectionError(
                error: error,
                onRetry: () => ref.invalidate(bannersProvider),
              ),
              data: (banners) => banners.isEmpty
                  ? SectionEmpty(message: AppLocalizations.of(context).homeBannersEmpty)
                  : BannerCarousel(banners: banners),
            ),
          ],
        ),
      ],
    );
  }
}

class _Sections extends ConsumerWidget {
  const _Sections();

  static const int _skeletonCount = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AsyncView<List<HomeSection>>(
      value: ref.watch(sectionsProvider),
      loading: () => Column(
        children: [
          for (var i = 0; i < _skeletonCount; i++) const ProductSectionSkeleton(),
        ],
      ),
      error: (error) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xxl),
        child: SectionError(error: error, onRetry: () => ref.invalidate(sectionsProvider)),
      ),
      data: (sections) => sections.isEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxl),
              child: SectionEmpty(message: l10n.homeSectionsEmpty),
            )
          : Column(
              children: [
                for (var i = 0; i < sections.length; i++)
                  FadeSlideIn(
                    delay: context.staggerDelay(i + 1, step: AppDurations.stagger * 2),
                    child: ProductSection(section: sections[i]),
                  ),
              ],
            ),
    );
  }
}

class _Shops extends ConsumerWidget {
  const _Shops();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AsyncView<List<Shop>>(
      value: ref.watch(shopsProvider),
      loading: () => const SizedBox.shrink(),
      error: (error) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xxl),
        child: SectionError(error: error, onRetry: () => ref.invalidate(shopsProvider)),
      ),
      data: (shops) => shops.isEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxl),
              child: SectionEmpty(message: l10n.homeShopsEmpty),
            )
          : FadeSlideIn(
              delay: context.staggerDelay(4, step: AppDurations.stagger * 2),
              child: ShopsSection(shops: shops),
            ),
    );
  }
}
