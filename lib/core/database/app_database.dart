import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'database_seeder.dart';
import 'seed_source.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// The local SQLite database: the single source of truth the UI reads.
@DriftDatabase(
  tables: [
    Products,
    Banners,
    HomeSections,
    SectionProducts,
    Shops,
    Tiers,
    Members,
    Challenges,
    Gifts,
    Users,
    CartItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor, {required SeedSource seedSource})
      : _seedSource = seedSource;

  /// Opens the on-device database file.
  factory AppDatabase.onDevice({required SeedSource seedSource}) =>
      AppDatabase(driftDatabase(name: databaseName), seedSource: seedSource);

  static const String databaseName = 'jdonuts';
  static const int currentSchemaVersion = 2;

  final SeedSource _seedSource;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Versioned, step-by-step migrations. Never edit a shipped step.
          if (from < 2) {
            await m.createTable(cartItems);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          if (details.wasCreated || await _isCatalogEmpty()) {
            await DatabaseSeeder(this).seed(await _seedSource.load());
          }
        },
      );

  Future<bool> _isCatalogEmpty() async {
    final firstProduct = await (select(products)..limit(1)).getSingleOrNull();
    return firstProduct == null;
  }
}
