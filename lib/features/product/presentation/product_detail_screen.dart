import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/section_states.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/widgets/auth_scaffold.dart';
import '../domain/cart_use_cases.dart';
import '../domain/product.dart';
import '../product_providers.dart';
import 'product_hero.dart';
import 'widgets/product_card.dart';
import 'widgets/product_description.dart';

/// Screen 9: product code, name, price, image, description, quantity and
/// "Add to cart" with the live total.
class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId, this.args});

  final String productId;
  final ProductRouteArgs? args;

  static const Key addToCartKey = Key('add-to-cart');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final heroTag = args?.heroTag;
    final live = ref.watch(productProvider(productId));
    final preview = args?.preview;
    // Until the database stream's first emission, render the tapped tile's
    // product so the hero image has a destination on the very first frame.
    final value = !live.hasValue && !live.hasError && preview != null
        ? AsyncData<Product?>(preview)
        : live;
    return Scaffold(
      backgroundColor: context.colors.surfaceMuted,
      body: SafeArea(
        child: AsyncView<Product?>(
          value: value,
          loading: () => const _DetailSkeleton(),
          error: (error) => _Centered(
            child: SectionError(
              error: error,
              onRetry: () => ref.invalidate(productProvider(productId)),
            ),
          ),
          data: (product) => product == null
              ? _Centered(child: SectionEmpty(message: l10n.productNotFound))
              : _ProductBody(
                  product: product,
                  heroTag: heroTag ?? productHeroTag(product.id),
                ),
        ),
      ),
    );
  }
}

class _ProductBody extends ConsumerStatefulWidget {
  const _ProductBody({required this.product, required this.heroTag});

  final Product product;
  final String heroTag;

  @override
  ConsumerState<_ProductBody> createState() => _ProductBodyState();
}

class _ProductBodyState extends ConsumerState<_ProductBody> {
  int _quantity = kMinQuantity;
  bool _adding = false;

  Future<void> _addToCart() async {
    if (_adding) return;
    setState(() => _adding = true);
    final result = await ref
        .read(addToCartProvider)
        .call(productId: widget.product.id, quantity: _quantity);
    if (!mounted) return;
    setState(() => _adding = false);
    final l10n = AppLocalizations.of(context);
    final message = result.isOk
        ? l10n.productAdded(_quantity, widget.product.name)
        : failureMessage(l10n, result.failureOrNull!);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final total = lineTotalMmk(
      unitPriceMmk: widget.product.priceMmk,
      quantity: _quantity,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.m),
          Align(
            alignment: Alignment.centerLeft,
            child: BackSquareButton(
              filled: false,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProductCard(
                    product: widget.product,
                    heroTag: widget.heroTag,
                    quantity: _quantity,
                    onQuantityChanged: (q) => setState(() => _quantity = clampQuantity(q)),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  ProductDescription(text: widget.product.description),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          PrimaryButton(
            key: ProductDetailScreen.addToCartKey,
            label: l10n.productAddToCart,
            trailing: formatMmk(total),
            isLoading: _adding,
            onPressed: _addToCart,
          ),
          const SizedBox(height: AppSpacing.l),
        ],
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: BackSquareButton(
                filled: false,
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
          Expanded(child: Center(child: child)),
        ],
      );
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  static const double _cardHeight = 360;

  @override
  Widget build(BuildContext context) => const Shimmer(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            children: [
              SizedBox(height: AppSpacing.huge),
              SkeletonBox(height: _cardHeight, radius: AppRadii.xl),
              SizedBox(height: AppSpacing.xxl),
              SkeletonBox(height: AppSpacing.huge * 2),
            ],
          ),
        ),
      );
}
