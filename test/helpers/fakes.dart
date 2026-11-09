import 'dart:async';

import 'package:jdonuts/core/domain/image_ref.dart';
import 'package:jdonuts/core/domain/result.dart';
import 'package:jdonuts/features/auth/data/fake_auth_repository.dart';
import 'package:jdonuts/features/auth/data/session_storage.dart';
import 'package:jdonuts/features/auth/data/user_store.dart';
import 'package:jdonuts/features/auth/domain/auth_entities.dart';
import 'package:jdonuts/features/auth/domain/auth_repository.dart';
import 'package:jdonuts/features/member/domain/member.dart';
import 'package:jdonuts/features/member/domain/member_repository.dart';

/// Fast fake auth for tests: same rules, short latency.
FakeAuthRepository fastAuthRepository({
  UserStore? users,
  SessionStorage? session,
  Duration latency = const Duration(milliseconds: 10),
}) =>
    FakeAuthRepository(
      users: users ?? InMemoryUserStore(),
      session: session ?? InMemorySessionStorage(),
      latency: latency,
    );

const testTiers = [
  Tier(id: 'silver', name: 'Silver', minPoints: 0),
  Tier(id: 'gold', name: 'Gold', minPoints: 2000),
  Tier(id: 'platinum', name: 'Platinum', minPoints: 5000),
];

Member testMember({String tierId = 'silver', int tierPoints = 1500}) => Member(
      id: 'me',
      displayName: 'Hania',
      photo: const ImageRef(asset: 'assets/images/avatar_member.png'),
      tierId: tierId,
      tierPoints: tierPoints,
      totalPoints: 680000,
      notificationCount: 2,
      rewardsCount: 3,
    );

/// In-memory [MemberRepository] that records name updates.
class InMemoryMemberRepository implements MemberRepository {
  InMemoryMemberRepository([Member? member]) : _member = member ?? testMember();

  Member _member;
  final _changes = StreamController<Member?>.broadcast();
  final List<String> updatedNames = [];

  @override
  Stream<Member?> watchMember() async* {
    yield _member;
    yield* _changes.stream;
  }

  @override
  Stream<List<Tier>> watchTiers() => Stream.value(testTiers);

  @override
  Future<Result<void>> updateDisplayName(String name) async {
    updatedNames.add(name);
    _member = Member(
      id: _member.id,
      displayName: name,
      photo: _member.photo,
      tierId: _member.tierId,
      tierPoints: _member.tierPoints,
      totalPoints: _member.totalPoints,
      notificationCount: _member.notificationCount,
      rewardsCount: _member.rewardsCount,
    );
    _changes.add(_member);
    return okVoid;
  }
}

/// Wraps the fast fake and counts OTP requests (double-tap test).
class CountingAuthRepository implements AuthRepository {
  CountingAuthRepository({required this.onRequestOtp});

  final void Function() onRequestOtp;
  final AuthRepository _inner = fastAuthRepository();

  @override
  Future<Result<void>> requestOtp({required String phone, required AuthFlow flow}) {
    onRequestOtp();
    return _inner.requestOtp(phone: phone, flow: flow);
  }

  @override
  Future<Result<OtpOutcome>> verifyOtp({
    required String phone,
    required String code,
    required AuthFlow flow,
  }) =>
      _inner.verifyOtp(phone: phone, code: code, flow: flow);

  @override
  Future<Result<User>> register(RegistrationDetails details) => _inner.register(details);

  @override
  Future<User?> restoreSession() => _inner.restoreSession();

  @override
  Future<Result<void>> logOut() => _inner.logOut();
}
