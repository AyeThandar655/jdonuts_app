import '../../../core/domain/result.dart';
import 'member.dart';

abstract interface class MemberRepository {
  /// Emits the member record and every later change.
  Stream<Member?> watchMember();

  /// Emits all tiers, lowest first.
  Stream<List<Tier>> watchTiers();

  /// Puts the signed-in user's name on the member record.
  Future<Result<void>> updateDisplayName(String name);
}
