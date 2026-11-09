import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/core_providers.dart';
import '../../core/domain/result.dart';
import 'data/drift_member_repository.dart';
import 'domain/build_member_status.dart';
import 'domain/member.dart';
import 'domain/member_repository.dart';

final memberRepositoryProvider = Provider<MemberRepository>(
  (ref) => DriftMemberRepository(ref.watch(appDatabaseProvider)),
);

final _memberProvider = StreamProvider<Member?>(
  (ref) => ref.watch(memberRepositoryProvider).watchMember(),
);

final _tiersProvider = StreamProvider<List<Tier>>(
  (ref) => ref.watch(memberRepositoryProvider).watchTiers(),
);

/// The single member view used by Home and Rewards.
final memberStatusProvider = FutureProvider<MemberStatus>((ref) async {
  final member = await ref.watch(_memberProvider.future);
  final tiers = await ref.watch(_tiersProvider.future);
  if (member == null) throw const MemberMissing();
  return switch (buildMemberStatus(member, tiers)) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
});

/// Thrown when the database has no member row (should never happen after
/// seeding, but the UI still has an error state for it).
final class MemberMissing implements Exception {
  const MemberMissing();
}
