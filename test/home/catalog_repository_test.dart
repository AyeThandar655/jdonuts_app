import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/database/json_rows.dart';
import 'package:jdonuts/core/domain/failure.dart';
import 'package:jdonuts/core/domain/result.dart';
import 'package:jdonuts/features/home/data/catalog_remote_data_source.dart';
import 'package:jdonuts/features/home/data/drift_catalog_repository.dart';
import 'package:jdonuts/features/home/domain/catalog.dart';
import 'package:jdonuts/features/home/domain/catalog_repository.dart';

import '../helpers/test_database.dart';

class _StubRemote implements CatalogRemoteDataSource {
  _StubRemote(this.result);
  final Result<CatalogPayload> result;
  int calls = 0;

  @override
  Future<Result<CatalogPayload>> fetchCatalog() async {
    calls++;
    return result;
  }
}

class _CountingRepository implements CatalogRepository {
  int refreshes = 0;

  @override
  Future<Result<RefreshOutcome>> refresh() async {
    refreshes++;
    return const Result.ok(RefreshOutcome.updated);
  }

  @override
  Stream<List<PromoBanner>> watchBanners() => const Stream.empty();
  @override
  Stream<List<HomeSection>> watchSections() => const Stream.empty();
  @override
  Stream<List<Shop>> watchShops() => const Stream.empty();
}

JsonMap _product(String id, String name) => {
      'id': id,
      'code': 'JD000001',
      'name': name,
      'priceMmk': 1000,
      'isNew': false,
      'discountPercent': null,
      'imageAsset': 'assets/images/donut_matcha.png',
      'imageUrl': null,
      'description': 'd',
    };

void main() {
  group('first launch', () {
    test('seeds every section from the bundled JSON, in order', () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final sections = await DriftCatalogRepository(db).watchSections().first;
      expect(sections.map((s) => s.title), ['Seasonal specials', 'Popular', 'Order again']);
      expect(sections.first.products.first.name, 'Mistletoe Romance box');
      expect(sections.first.products.first.discountPercent, 50);
    });

    test('seeds banners and the four nearby shops', () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final repo = DriftCatalogRepository(db);
      expect((await repo.watchBanners().first).first.title, 'We are now at Central Boulevard');
      expect(await repo.watchShops().first, hasLength(4));
    });
  });

  group('refresh', () {
    test('without a server it reports local-only and changes nothing', () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final result = await DriftCatalogRepository(db).refresh();
      expect(result.valueOrNull, RefreshOutcome.localOnly);
    });

    test('writes server data into the database, which re-emits to the UI', () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final remote = _StubRemote(
        Result.ok(
          CatalogPayload(
            products: [_product('p_coconut', 'Coconut Donut v2'), _product('p_new', 'Brand new')],
            banners: const [],
            sections: [
              {
                'id': 's_popular',
                'title': 'Popular',
                'emoji': '🔥',
                'layout': 'tall',
                'productIds': ['p_new', 'p_coconut'],
              },
            ],
            shops: const [],
          ),
        ),
      );
      final repo = DriftCatalogRepository(db, remote: remote);
      expect((await repo.refresh()).valueOrNull, RefreshOutcome.updated);

      final sections = await repo.watchSections().first;
      final popular = sections.firstWhere((s) => s.id == 's_popular');
      expect(popular.products.map((p) => p.name), ['Brand new', 'Coconut Donut v2']);
    });

    test('a network failure is returned typed and local data stays intact', () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final repo = DriftCatalogRepository(
        db,
        remote: _StubRemote(const Result.err(NetworkFailure())),
      );
      expect((await repo.refresh()).failureOrNull, isA<NetworkFailure>());
      expect(await repo.watchSections().first, hasLength(3));
    });
  });

  group('RefreshCatalog use case', () {
    test('skips the network entirely while offline', () async {
      final repo = _CountingRepository();
      final result = await RefreshCatalog(repo, () async => false)();
      expect(result.valueOrNull, RefreshOutcome.localOnly);
      expect(repo.refreshes, 0);
    });

    test('refreshes when online', () async {
      final repo = _CountingRepository();
      await RefreshCatalog(repo, () async => true)();
      expect(repo.refreshes, 1);
    });
  });
}
