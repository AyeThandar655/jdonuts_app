import '../../../core/domain/failure.dart';
import '../../../core/domain/result.dart';
import 'member.dart';

/// Use case: works out the member's tier, next tier and progress.
///
/// Pure function so Home ("1,290 points left to become Gold") and Rewards
/// (ladder + ring) always agree.
Result<MemberStatus> buildMemberStatus(Member member, List<Tier> tiers) {
  final sorted = [...tiers]..sort((a, b) => a.minPoints.compareTo(b.minPoints));
  final index = sorted.indexWhere((t) => t.id == member.tierId);
  if (index < 0) {
    return Result.err(NotFoundFailure('tier ${member.tierId} missing'));
  }
  final current = sorted[index];
  final next = index + 1 < sorted.length ? sorted[index + 1] : null;
  return Result.ok(
    MemberStatus(
      member: member,
      tiers: sorted,
      currentTier: current,
      nextTier: next,
      pointsToNextTier: _pointsToNext(member, next),
      progressToNextTier: _progress(member, current, next),
    ),
  );
}

int _pointsToNext(Member member, Tier? next) {
  if (next == null) return 0;
  final remaining = next.minPoints - member.tierPoints;
  return remaining < 0 ? 0 : remaining;
}

double _progress(Member member, Tier current, Tier? next) {
  if (next == null) return 1;
  final span = next.minPoints - current.minPoints;
  if (span <= 0) return 1;
  final earned = member.tierPoints - current.minPoints;
  return (earned / span).clamp(0.0, 1.0);
}
