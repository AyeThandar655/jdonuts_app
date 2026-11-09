import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/json_rows.dart';
import '../../../core/database/storage_errors.dart';
import '../../../core/domain/failure.dart';
import '../../../core/domain/image_ref.dart';
import '../../../core/domain/result.dart';
import '../../product/data/drift_product_repository.dart';
import '../../product/domain/product.dart';
import '../domain/catalog.dart';
import '../domain/catalog_repository.dart';
import 'catalog_remote_data_source.dart';

/// Offline-first catalog: the UI watches Drift; [refresh] writes into it.
final class DriftCatalogRepository implements CatalogRepository {
  DriftCatalogRepository(this._db, {CatalogRemoteDataSource? remote})
      : _remote = remote;

  final AppDatabase _db;
  final CatalogRemoteDataSource? _remote;

  @override
  Stream<List<PromoBanner>> watchBanners() {
    final query = _db.select(_db.banners)
      ..orderBy([(b) => OrderingTerm.asc(b.sortOrder)]);
    return query
        .watch()
        .map((rows) => rows.map(_toBanner).toList())
        .mapStorageErrors();
  }

  @override
  Stream<List<Shop>> watchShops() {
    final query = _db.select(_db.shops)
      ..orderBy([(s) => OrderingTerm.asc(s.sortOrder)]);
    return query
        .watch()
        .map((rows) => rows.map(_toShop).toList())
        .mapStorageErrors();
  }

  /// One joined query, so a product update re-emits every section using it.
  @override
  Stream<List<HomeSection>> watchSections() {
    final query = _db.select(_db.homeSections).join([
      leftOuterJoin(
        _db.sectionProducts,
        _db.sectionProducts.sectionId.equalsExp(_db.homeSections.id),
      ),
      leftOuterJoin(
        _db.products,
        _db.products.id.equalsExp(_db.sectionProducts.productId),
      ),
    ])
      ..orderBy([
        OrderingTerm.asc(_db.homeSections.sortOrder),
        OrderingTerm.asc(_db.sectionProducts.sortOrder),
      ]);
    return query.watch().map(_groupSections).mapStorageErrors();
  }

  List<HomeSection> _groupSections(List<TypedResult> rows) {
    final sections = <String, HomeSectionRow>{};
    final products = <String, List<Product>>{};
    for (final row in rows) {
      final section = row.readTable(_db.homeSections);
      sections.putIfAbsent(section.id, () => section);
      final bucket = products.putIfAbsent(section.id, () => []);
      final product = row.readTableOrNull(_db.products);
      if (product != null) bucket.add(productFromRow(product));
    }
    return [
      for (final section in sections.values)
        HomeSection(
          id: section.id,
          title: section.title,
          emoji: section.emoji,
          layout: SectionLayout.fromName(section.layout),
          products: products[section.id] ?? const [],
        ),
    ];
  }

  @override
  Future<Result<RefreshOutcome>> refresh() async {
    final remote = _remote;
    if (remote == null) return const Result.ok(RefreshOutcome.localOnly);
    final result = await remote.fetchCatalog();
    switch (result) {
      case Err(:final failure):
        return Result.err(failure);
      case Ok(:final value):
        return _write(value);
    }
  }

  Future<Result<RefreshOutcome>> _write(CatalogPayload payload) async {
    try {
      await _db.transaction(() async {
        await _db.batch((b) {
          b.insertAllOnConflictUpdate(
            _db.products,
            payload.products.map(productFromJson).toList(),
          );
          b.insertAllOnConflictUpdate(
            _db.banners,
            indexedRows(payload.banners, bannerFromJson),
          );
          b.insertAllOnConflictUpdate(
            _db.shops,
            indexedRows(payload.shops, shopFromJson),
          );
          b.insertAllOnConflictUpdate(
            _db.homeSections,
            indexedRows(payload.sections, sectionFromJson),
          );
          b.deleteWhere(_db.sectionProducts, (_) => const Constant(true));
          b.insertAll(
            _db.sectionProducts,
            payload.sections.expand(sectionProductsFromJson).toList(),
          );
        });
      });
      return const Result.ok(RefreshOutcome.updated);
    } on TypeError catch (e) {
      return Result.err(ServerFailure('unexpected payload: $e'));
    } on Exception catch (e) {
      return Result.err(StorageFailure(e.toString()));
    }
  }

  PromoBanner _toBanner(BannerRow row) => PromoBanner(
        id: row.id,
        title: row.title,
        tag: row.tag,
        backgroundHex: row.backgroundHex,
        image: ImageRef(asset: row.imageAsset, url: row.imageUrl),
      );

  Shop _toShop(ShopRow row) => Shop(
        id: row.id,
        name: row.name,
        address: row.address,
        image: ImageRef(asset: row.imageAsset, url: row.imageUrl),
      );
}
