import '../../../core/database/app_database.dart';
import '../../../core/database/storage_errors.dart';
import '../../../core/domain/image_ref.dart';
import '../../../core/domain/result.dart';
import '../domain/product.dart';
import '../domain/product_repository.dart';

final class DriftProductRepository implements ProductRepository {
  DriftProductRepository(this._db);
  final AppDatabase _db;

  @override
  Stream<Product?> watchProduct(String id) {
    final query = _db.select(_db.products)..where((p) => p.id.equals(id));
    return query
        .watchSingleOrNull()
        .map((row) => row == null ? null : productFromRow(row))
        .mapStorageErrors();
  }

  @override
  Future<Result<void>> addToCart({
    required String productId,
    required int quantity,
  }) =>
      guardStorage(
        () => _db.transaction(() async {
          final existing = await (_db.select(_db.cartItems)
                ..where((c) => c.productId.equals(productId)))
              .getSingleOrNull();
          await _db.into(_db.cartItems).insertOnConflictUpdate(
                CartItemsCompanion.insert(
                  productId: productId,
                  quantity: (existing?.quantity ?? 0) + quantity,
                  updatedAt: DateTime.now(),
                ),
              );
        }),
      );

  @override
  Stream<int> watchCartCount() => _db
      .select(_db.cartItems)
      .watch()
      .map((rows) => rows.fold<int>(0, (sum, row) => sum + row.quantity))
      .mapStorageErrors();
}

/// Shared row -> entity mapping (also used by the home catalog).
Product productFromRow(ProductRow row) => Product(
      id: row.id,
      code: row.code,
      name: row.name,
      priceMmk: row.priceMmk,
      isNew: row.isNew,
      discountPercent: row.discountPercent,
      image: ImageRef(asset: row.imageAsset, url: row.imageUrl),
      description: row.description,
    );
