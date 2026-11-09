import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/catalog.dart';
import 'hills_painter.dart';

/// "There are 4 J'Donut shops near you" with shop cards. Display only.
class ShopsSection extends StatelessWidget {
  const ShopsSection({super.key, required this.shops});

  final List<Shop> shops;

  static const double _cardWidth = 196;
  static const double _cardImageHeight = 104;
  static const double _hillsHeight = 140;
  static const double _cardTextHeight = 92;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final scaler = MediaQuery.textScalerOf(context);
    final listHeight = _cardImageHeight + scaler.scale(_cardTextHeight) + AppSpacing.l * 2;
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xxxl),
      decoration: BoxDecoration(
        color: colors.shopsBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xxl)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _hillsHeight,
            child: CustomPaint(
              painter: HillsPainter(
                hill: colors.shopsHill,
                hillDark: colors.shopsHillDark,
                cloud: colors.shopsCloud,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  AppSpacing.xxl,
                  AppSpacing.gutter,
                  AppSpacing.l,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeShopsTitle(shops.length),
                      style: textTheme.titleLarge?.copyWith(color: colors.onPrimary),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    const _ExploreButton(),
                  ],
                ),
              ),
              SizedBox(
                height: listHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.gutter,
                    0,
                    AppSpacing.gutter,
                    AppSpacing.l,
                  ),
                  itemCount: shops.length,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.m),
                  itemBuilder: (context, index) => _ShopCard(
                    shop: shops[index],
                    width: _cardWidth,
                    imageHeight: _cardImageHeight,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExploreButton extends StatelessWidget {
  const _ExploreButton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        AppLocalizations.of(context).homeExploreNow.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors.primary,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({
    required this.shop,
    required this.width,
    required this.imageHeight,
  });

  final Shop shop;
  final double width;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: width,
      padding: const EdgeInsets.all(AppSpacing.s),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.l),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.m),
            child: SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: AppImage(shop.image, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(shop.name, style: textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppSpacing.xxs),
          Text(shop.address, style: textTheme.labelSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
          const Spacer(),
          Text(
            AppLocalizations.of(context).homeOrderOnline,
            style: textTheme.labelMedium?.copyWith(color: colors.accentPink),
          ),
        ],
      ),
    );
  }
}
