import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/storage_errors.dart';
import '../../../core/domain/image_ref.dart';
import '../../../core/domain/result.dart';
import '../domain/member.dart';
import '../domain/member_repository.dart';

final class DriftMemberRepository implements MemberRepository {
  DriftMemberRepository(this._db);
  final AppDatabase _db;

  @override
  Stream<Member?> watchMember() => _db
      .select(_db.members)
      .watch()
      .map((rows) => rows.isEmpty ? null : _toMember(rows.first))
      .mapStorageErrors();

  @override
  Stream<List<Tier>> watchTiers() {
    final query = _db.select(_db.tiers)
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    return query
        .watch()
        .map((rows) => rows.map(_toTier).toList())
        .mapStorageErrors();
  }

  @override
  Future<Result<void>> updateDisplayName(String name) => guardStorage(() async {
        await _db
            .update(_db.members)
            .write(MembersCompanion(displayName: Value(name)));
      });

  Member _toMember(MemberRow row) => Member(
        id: row.id,
        displayName: row.displayName,
        photo: ImageRef(asset: row.photoAsset),
        tierId: row.tierId,
        tierPoints: row.tierPoints,
        totalPoints: row.totalPoints,
        notificationCount: row.notificationCount,
        rewardsCount: row.rewardsCount,
      );

  Tier _toTier(TierRow row) =>
      Tier(id: row.id, name: row.name, minPoints: row.minPoints);
}
