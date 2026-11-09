import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../database/app_database.dart';
import '../database/seed_source.dart';
import '../network/api_config.dart';
import '../network/connectivity_service.dart';
import '../network/dio_factory.dart';

/// Composition root for infrastructure. Widgets never construct these;
/// tests override them.

final apiConfigProvider = Provider<ApiConfig>((ref) => ApiConfig.fromEnvironment());

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.onDevice(seedSource: const AssetSeedSource());
  ref.onDispose(db.close);
  return db;
});

/// `null` when no mock server is configured: the app then runs on local data.
final dioProvider = Provider<Dio?>((ref) {
  final config = ref.watch(apiConfigProvider);
  return config.isConfigured ? createDio(config) : null;
});

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => DeviceConnectivityService(config: ref.watch(apiConfigProvider)),
);

/// Live reachability. UI shows the offline banner from this.
final isOnlineProvider = StreamProvider<bool>(
  (ref) => ref.watch(connectivityServiceProvider).watchOnline(),
);
