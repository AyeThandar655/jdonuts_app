import '../../../core/domain/result.dart';
import 'product.dart';

abstract interface class ProductRepository {
  /// Emits the product (or `null` if it does not exist) and later changes.
  Stream<Product?> watchProduct(String id);

  /// Adds [quantity] of the product to the persistent cart.
  Future<Result<void>> addToCart({
    required String productId,
    required int quantity,
  });

  /// Total number of items in the cart.
  Stream<int> watchCartCount();
}
