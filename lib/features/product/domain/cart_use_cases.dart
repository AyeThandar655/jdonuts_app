import '../../../core/domain/failure.dart';
import '../../../core/domain/result.dart';
import 'product_repository.dart';

/// The quantity stepper never goes below this.
const int kMinQuantity = 1;

/// A sensible upper bound for one cart line.
const int kMaxQuantity = 99;

/// Keeps a quantity within [kMinQuantity]..[kMaxQuantity].
int clampQuantity(int quantity) => quantity.clamp(kMinQuantity, kMaxQuantity);

/// Live total shown on "Add to cart": quantity × unit price.
int lineTotalMmk({required int unitPriceMmk, required int quantity}) =>
    unitPriceMmk * clampQuantity(quantity);

/// Use case: validates the quantity, then adds the line to the cart.
class AddToCart {
  const AddToCart(this._products);
  final ProductRepository _products;

  Future<Result<void>> call({
    required String productId,
    required int quantity,
  }) {
    if (quantity < kMinQuantity || quantity > kMaxQuantity) {
      return Future.value(
        Result.err(UnexpectedFailure('quantity $quantity out of range')),
      );
    }
    return _products.addToCart(productId: productId, quantity: quantity);
  }
}
