import 'dart:convert';

import 'app_database.dart';
import 'json_rows.dart';

/// Writes the bundled seed JSON into the local database in one batch.
class DatabaseSeeder {
  DatabaseSeeder(this._db);
  final AppDatabase _db;

  Future<void> seed(String rawJson) async {
    final json = jsonDecode(rawJson) as JsonMap;
    final sections = jsonList(json['sections']);
    await _db.batch((b) {
      b.insertAllOnConflictUpdate(
        _db.products,
        jsonList(json['products']).map(productFromJson).toList(),
      );
      b.insertAllOnConflictUpdate(
        _db.banners,
        indexedRows(jsonList(json['banners']), bannerFromJson),
      );
      b.insertAllOnConflictUpdate(
        _db.homeSections,
        indexedRows(sections, sectionFromJson),
      );
      b.insertAllOnConflictUpdate(
        _db.sectionProducts,
        sections.expand(sectionProductsFromJson).toList(),
      );
      b.insertAllOnConflictUpdate(
        _db.shops,
        indexedRows(jsonList(json['shops']), shopFromJson),
      );
      b.insertAllOnConflictUpdate(
        _db.tiers,
        indexedRows(jsonList(json['tiers']), tierFromJson),
      );
      b.insertAllOnConflictUpdate(
        _db.members,
        [memberFromJson(json['member'] as JsonMap)],
      );
      b.insertAllOnConflictUpdate(
        _db.challenges,
        indexedRows(jsonList(json['challenges']), challengeFromJson),
      );
      b.insertAllOnConflictUpdate(
        _db.gifts,
        indexedRows(jsonList(json['gifts']), giftFromJson),
      );
    });
  }
}
