import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/domain/failure.dart';
import 'package:jdonuts/core/utils/formatters.dart';
import 'package:jdonuts/features/product/data/drift_product_repository.dart';
import 'package:jdonuts/features/product/domain/cart_use_cases.dart';

import '../helpers/test_database.dart';

void main() {
  group('lineTotalMmk', () {
    test('is quantity × unit price', () {
      expect(lineTotalMmk(unitPriceMmk: 3200, quantity: 3), 9600);
    });

    test('never goes below one item', () {
      expect(lineTotalMmk(unitPriceMmk: 3200, quantity: 0), 3200);
    });
  });

  test('prices format with thousands separators', () {
    expect(formatMmk(3200), '3,200 MMK');
    expect(formatThousands(680000), '680,000');
  });

  group('AddToCart', () {
    test('adds to the persistent cart and accumulates quantities', () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final repo = DriftProductRepository(db);
      final addToCart = AddToCart(repo);

      expect((await addToCart(productId: 'p_coconut', quantity: 2)).isOk, isTrue);
      expect((await addToCart(productId: 'p_coconut', quantity: 1)).isOk, isTrue);
      expect(await repo.watchCartCount().first, 3);
    });

    test('rejects a quantity below the minimum', () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final result = await AddToCart(DriftProductRepository(db))(productId: 'p_coconut', quantity: 0);
      expect(result.failureOrNull, isA<UnexpectedFailure>());
    });
  });
}
