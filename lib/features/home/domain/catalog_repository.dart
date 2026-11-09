import '../../../core/domain/result.dart';
import 'catalog.dart';

/// Home data. Every `watch*` stream reads the local database only; [refresh]
/// pulls from the server (when there is one) and writes into that database,
/// which then pushes the new rows to the streams.
abstract interface class CatalogRepository {
  Stream<List<PromoBanner>> watchBanners();
  Stream<List<HomeSection>> watchSections();
  Stream<List<Shop>> watchShops();

  /// Syncs public data from the server into the local database.
  Future<Result<RefreshOutcome>> refresh();
}

enum RefreshOutcome {
  /// New data was written.
  updated,

  /// No server is configured; local data is all there is.
  localOnly,
}

/// Use case: refresh only when the device can reach the network, so the
/// offline path never waits on timeouts.
class RefreshCatalog {
  const RefreshCatalog(this._catalog, this._isOnline);
  final CatalogRepository _catalog;
  final Future<bool> Function() _isOnline;

  Future<Result<RefreshOutcome>> call() async {
    if (!await _isOnline()) return const Result.ok(RefreshOutcome.localOnly);
    return _catalog.refresh();
  }
}
