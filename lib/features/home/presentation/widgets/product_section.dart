import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../core/widgets/section_states.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../product/domain/product.dart';
import '../../../product/presentation/product_hero.dart';
import '../../domain/catalog.dart';

/// Tile geometry per layout, before text scaling.
final class _TileSize {
  const _TileSize(this.width, this.imageHeight);
  final double width;
  final double imageHeight;

  static _TileSize of(SectionLayout layout) => switch (layout) {
        SectionLayout.wide => const _TileSize(172, 112),
        SectionLayout.tall => const _TileSize(116, 168),
        SectionLayout.square => const _TileSize(116, 116),
      };
}

/// Lines reserved for a product name under a tile.
const int kTileCaptionLines = 2;
const double kTileCaptionLineHeight = 18;

/// A titled horizontal list of products.
class ProductSection extends StatelessWidget {
  const ProductSection({super.key, required this.section});

  final HomeSection section;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: section.title,
          emoji: section.emoji,
          onSeeAll: () => context.push(Routes.section(section.id)),
        ),
        if (section.products.isEmpty)
          SectionEmpty(message: l10n.homeSectionEmpty)
        else
          _ProductRow(section: section),
      ],
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.section});

  final HomeSection section;

  @override
  Widget build(BuildContext context) {
    final size = _TileSize.of(section.layout);
    final scaler = MediaQuery.textScalerOf(context);
    final captionHeight = scaler.scale(kTileCaptionLineHeight) * kTileCaptionLines;
    return SizedBox(
      height: size.imageHeight + AppSpacing.s + captionHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        itemCount: section.products.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.m),
        itemBuilder: (context, index) => ProductTile(
          product: section.products[index],
          layout: section.layout,
          heroTag: productHeroTag(section.products[index].id, scope: section.id),
          width: size.width,
          imageHeight: size.imageHeight,
        ),
      ),
    );
  }
}

/// One product card. Tapping opens Product detail with a hero image.
class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.product,
    required this.layout,
    required this.heroTag,
    required this.width,
    required this.imageHeight,
  });

  final Product product;
  final SectionLayout layout;
  final String heroTag;
  final double width;
  final double imageHeight;

  static const double _photoPadding = AppSpacing.s;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isPhoto = layout == SectionLayout.wide;
    return Pressable(
      semanticLabel: product.name,
      onTap: () => context.push(
        Routes.product(product.id),
        extra: ProductRouteArgs(heroTag: heroTag, preview: product),
      ),
      child: SizedBox(
        width: width,
        child: Column(
          key: Key('product-tile-${product.id}'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: imageHeight,
              width: width,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.m),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isPhoto ? 0 : _photoPadding),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(isPhoto ? AppRadii.m : 0),
                        child: Hero(
                          tag: heroTag,
                          child: AppImage(
                            product.image,
                            fit: isPhoto ? BoxFit.cover : BoxFit.contain,
                            semanticLabel: product.name,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (product.hasDiscount)
                    Positioned(
                      right: AppSpacing.s,
                      bottom: AppSpacing.s,
                      child: DiscountBadge(percent: product.discountPercent!),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              product.name,
              maxLines: kTileCaptionLines,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Orange "50% off" pill.
class DiscountBadge extends StatelessWidget {
  const DiscountBadge({super.key, required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: colors.accentOrange,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        AppLocalizations.of(context).homeDiscount(percent),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

/// "Seasonal specials  (>)".
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.emoji,
    this.onSeeAll,
  });

  final String title;
  final String? emoji;

  /// Opens the full section; the arrow is hidden when `null`.
  final VoidCallback? onSeeAll;

  static const double _arrowSize = 28;
  static const double _arrowIcon = 16;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = emoji == null ? title : '$title $emoji';
    return Padding(
      // The arrow's own padding makes up the rest of the gutter.
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
          if (onSeeAll != null)
            Pressable(
              key: Key('see-all-$title'),
              semanticLabel: title,
              onTap: onSeeAll,
              // Padding enlarges the touch target around the 28 px circle.
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s),
                child: Container(
                  width: _arrowSize,
                  height: _arrowSize,
                  decoration: BoxDecoration(color: colors.surface, shape: BoxShape.circle),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: _arrowIcon,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Loading placeholder for one section.
class ProductSectionSkeleton extends StatelessWidget {
  const ProductSectionSkeleton({super.key});

  static const int _tiles = 3;
  static const double _titleWidth = 140;
  static const double _titleHeight = 18;

  @override
  Widget build(BuildContext context) {
    final size = _TileSize.of(SectionLayout.wide);
    return Shimmer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.xxl, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: _titleWidth, height: _titleHeight),
            const SizedBox(height: AppSpacing.m),
            SizedBox(
              height: size.imageHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tiles,
                separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.m),
                itemBuilder: (_, _) => SkeletonBox(width: size.width, height: size.imageHeight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
