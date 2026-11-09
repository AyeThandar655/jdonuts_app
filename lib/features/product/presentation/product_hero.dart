import '../domain/product.dart';

/// Hero tag shared by a product tile and Product detail.
///
/// [scope] keeps tags unique when the same product shows in two sections.
String productHeroTag(String productId, {String scope = 'detail'}) =>
    'product-image-$scope-$productId';

/// Optional navigation extras for `/product/:id`.
///
/// [preview] is only a first-frame stand-in for the hero flight; the screen
/// switches to the live database record as soon as it arrives.
final class ProductRouteArgs {
  const ProductRouteArgs({required this.heroTag, this.preview});

  final String heroTag;
  final Product? preview;
}
