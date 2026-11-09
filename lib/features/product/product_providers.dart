import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/core_providers.dart';
import 'data/drift_product_repository.dart';
import 'domain/cart_use_cases.dart';
import 'domain/product.dart';
import 'domain/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => DriftProductRepository(ref.watch(appDatabaseProvider)),
);

final productProvider = StreamProvider.autoDispose.family<Product?, String>(
  (ref, id) => ref.watch(productRepositoryProvider).watchProduct(id),
);

final addToCartProvider = Provider<AddToCart>(
  (ref) => AddToCart(ref.watch(productRepositoryProvider)),
);

final cartCountProvider = StreamProvider<int>(
  (ref) => ref.watch(productRepositoryProvider).watchCartCount(),
);
