import '../../../core/domain/image_ref.dart';

/// A loyalty tier (Silver, Gold, Platinum).
final class Tier {
  const Tier({required this.id, required this.name, required this.minPoints});

  final String id;
  final String name;
  final int minPoints;
}

/// The one member record every screen reads (Home header and Rewards).
final class Member {
  const Member({
    required this.id,
    required this.displayName,
    required this.photo,
    required this.tierId,
    required this.tierPoints,
    required this.totalPoints,
    required this.notificationCount,
    required this.rewardsCount,
  });

  final String id;
  final String displayName;
  final ImageRef photo;
  final String tierId;

  /// Points that count toward the next tier.
  final int tierPoints;

  /// Lifetime points balance shown in the Rewards ring.
  final int totalPoints;
  final int notificationCount;
  final int rewardsCount;
}

/// Where the member sits on the tier ladder.
final class MemberStatus {
  const MemberStatus({
    required this.member,
    required this.tiers,
    required this.currentTier,
    required this.nextTier,
    required this.pointsToNextTier,
    required this.progressToNextTier,
  });

  final Member member;

  /// All tiers, lowest first.
  final List<Tier> tiers;
  final Tier currentTier;
  final Tier? nextTier;
  final int pointsToNextTier;

  /// 0..1 progress from the current tier to the next (1 at the top tier).
  final double progressToNextTier;

  int get currentTierIndex => tiers.indexWhere((t) => t.id == currentTier.id);
}
