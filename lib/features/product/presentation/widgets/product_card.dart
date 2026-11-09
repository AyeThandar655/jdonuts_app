import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/product.dart';
import 'quantity_stepper.dart';

/// White card with code, New badge, name, price and the hero image; the
/// quantity stepper overlaps its bottom edge.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.heroTag,
    required this.quantity,
    required this.onQuantityChanged,
  });

  final Product product;
  final String heroTag;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  static const double _imageHeight = 220;
  static const double _stepperOverlap = 24;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: _stepperOverlap),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.xxxl + AppSpacing.s,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.xl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(product.code, style: textTheme.labelSmall)),
                  if (product.isNew) const _NewBadge(),
                ],
              ),
              FadeSlideIn(
                child: Text(product.name, style: textTheme.headlineLarge),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                formatMmk(product.priceMmk),
                style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.l),
              SizedBox(
                height: _imageHeight,
                width: double.infinity,
                child: Hero(
                  tag: heroTag,
                  child: AppImage(product.image, semanticLabel: product.name),
                ),
              ),
            ],
          ),
        ),
        QuantityStepper(quantity: quantity, onChanged: onQuantityChanged),
      ],
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: colors.accentOrange,
        borderRadius: BorderRadius.circular(AppRadii.s),
      ),
      child: Text(
        AppLocalizations.of(context).productNew,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
