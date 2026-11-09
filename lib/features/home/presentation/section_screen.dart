import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/section_states.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/widgets/auth_scaffold.dart';
import '../../product/presentation/product_hero.dart';
import '../domain/catalog.dart';
import '../home_providers.dart';
import 'widgets/product_section.dart';

/// "See all" for one Home section (the arrow next to its title): every
/// product of the section in a two-column grid, read from the same local data.
class SectionScreen extends ConsumerWidget {
  const SectionScreen({super.key, required this.sectionId});

  final String sectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final sections = ref.watch(sectionsProvider);
    final section = sections.value?.where((s) => s.id == sectionId).firstOrNull;
    final title = section == null
        ? ''
        : section.emoji == null
            ? section.title
            : '${section.title} ${section.emoji}';
    return Scaffold(
      backgroundColor: colors.scaffold,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.m,
                AppSpacing.gutter,
                AppSpacing.l,
              ),
              child: Row(
                children: [
                  BackSquareButton(onTap: () => Navigator.of(context).maybePop()),
                  const SizedBox(width: AppSpacing.l),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AsyncView<List<HomeSection>>(
                value: sections,
                loading: () => const _GridSkeleton(),
                error: (error) => SectionError(
                  error: error,
                  onRetry: () => ref.invalidate(sectionsProvider),
                ),
                data: (_) {
                  if (section == null) {
                    return SectionEmpty(message: l10n.errorNotFound);
                  }
                  if (section.products.isEmpty) {
                    return SectionEmpty(message: l10n.homeSectionEmpty);
                  }
                  return _ProductGrid(section: section);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.section});

  final HomeSection section;

  static const int _columns = 2;

  /// Landscape photo tiles keep their Home proportions; others are square.
  static const double _wideImageRatio = 0.65;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth -
                AppSpacing.gutter * 2 -
                AppSpacing.m * (_columns - 1)) /
            _columns;
        final imageHeight = section.layout == SectionLayout.wide
            ? tileWidth * _wideImageRatio
            : tileWidth;
        final captionHeight = scaler.scale(kTileCaptionLineHeight) * kTileCaptionLines;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            0,
            AppSpacing.gutter,
            AppSpacing.xxxl,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _columns,
            crossAxisSpacing: AppSpacing.m,
            mainAxisSpacing: AppSpacing.l,
            mainAxisExtent: imageHeight + AppSpacing.s + captionHeight,
          ),
          itemCount: section.products.length,
          itemBuilder: (context, index) {
            final product = section.products[index];
            return FadeSlideIn(
              delay: context.staggerDelay(index),
              child: ProductTile(
                product: product,
                layout: section.layout,
                heroTag: productHeroTag(product.id, scope: 'grid-${section.id}'),
                width: tileWidth,
                imageHeight: imageHeight,
              ),
            );
          },
        );
      },
    );
  }
}

class _GridSkeleton extends StatelessWidget {
  const _GridSkeleton();

  static const int _tiles = 4;
  static const double _tileHeight = 160;

  @override
  Widget build(BuildContext context) => Shimmer(
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          crossAxisSpacing: AppSpacing.m,
          mainAxisSpacing: AppSpacing.l,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (var i = 0; i < _tiles; i++)
              const SkeletonBox(height: _tileHeight),
          ],
        ),
      );
}
