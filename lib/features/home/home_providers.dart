import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/core_providers.dart';
import '../../core/domain/failure.dart';
import 'data/catalog_remote_data_source.dart';
import 'data/drift_catalog_repository.dart';
import 'domain/catalog.dart';
import 'domain/catalog_repository.dart';

final catalogRemoteDataSourceProvider = Provider<CatalogRemoteDataSource?>((ref) {
  final dio = ref.watch(dioProvider);
  return dio == null ? null : DioCatalogRemoteDataSource(dio);
});

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => DriftCatalogRepository(
    ref.watch(appDatabaseProvider),
    remote: ref.watch(catalogRemoteDataSourceProvider),
  ),
);

final refreshCatalogProvider = Provider<RefreshCatalog>((ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  return RefreshCatalog(ref.watch(catalogRepositoryProvider), connectivity.isOnline);
});

final bannersProvider = StreamProvider<List<PromoBanner>>(
  (ref) => ref.watch(catalogRepositoryProvider).watchBanners(),
);

final sectionsProvider = StreamProvider<List<HomeSection>>(
  (ref) => ref.watch(catalogRepositoryProvider).watchSections(),
);

final shopsProvider = StreamProvider<List<Shop>>(
  (ref) => ref.watch(catalogRepositoryProvider).watchShops(),
);

final class SyncState {
  const SyncState({this.isRefreshing = false, this.lastFailure});

  final bool isRefreshing;
  final Failure? lastFailure;
}

final catalogSyncProvider = NotifierProvider<CatalogSyncController, SyncState>(
  CatalogSyncController.new,
);

/// Refreshes the catalog in the background: once at start-up, whenever the
/// network comes back, and on pull-to-refresh.
class CatalogSyncController extends Notifier<SyncState> {
  @override
  SyncState build() {
    ref.listen<AsyncValue<bool>>(isOnlineProvider, (previous, next) {
      final wasOnline = previous?.value ?? false;
      final isOnline = next.value ?? false;
      if (isOnline && !wasOnline) unawaited(refresh());
    });
    return const SyncState();
  }

  Future<void> refresh() async {
    if (state.isRefreshing) return;
    state = const SyncState(isRefreshing: true);
    final result = await ref.read(refreshCatalogProvider).call();
    if (!ref.mounted) return;
    state = SyncState(lastFailure: result.failureOrNull);
  }
}
