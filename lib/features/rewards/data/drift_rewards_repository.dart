import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/storage_errors.dart';
import '../../../core/domain/image_ref.dart';
import '../../../core/domain/result.dart';
import '../domain/rewards.dart';

final class DriftRewardsRepository implements RewardsRepository {
  DriftRewardsRepository(this._db);
  final AppDatabase _db;

  @override
  Stream<List<Challenge>> watchChallenges() {
    final query = _db.select(_db.challenges)
      ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]);
    return query
        .watch()
        .map((rows) => rows.map(_toChallenge).toList())
        .mapStorageErrors();
  }

  @override
  Stream<List<Gift>> watchGifts() {
    final query = _db.select(_db.gifts)
      ..orderBy([(g) => OrderingTerm.asc(g.sortOrder)]);
    return query
        .watch()
        .map((rows) => rows.map(_toGift).toList())
        .mapStorageErrors();
  }

  /// The brief asks for visual feedback only, so this is a no-op success.
  @override
  Future<Result<void>> claimChallenge(String challengeId) async => okVoid;

  Challenge _toChallenge(ChallengeRow row) => Challenge(
        id: row.id,
        title: row.title,
        progress: row.progress,
        goal: row.goal,
        rewardPoints: row.rewardPoints,
        artwork: ChallengeArtwork.fromName(row.artwork),
        image: ImageRef(asset: row.imageAsset),
      );

  Gift _toGift(GiftRow row) => Gift(
        id: row.id,
        title: row.title,
        pointsCost: row.pointsCost,
        image: ImageRef(asset: row.imageAsset),
      );
}
