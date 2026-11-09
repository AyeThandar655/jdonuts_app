import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/domain/failure.dart';
import 'package:jdonuts/core/domain/result.dart';
import 'package:jdonuts/features/auth/data/fake_auth_repository.dart';
import 'package:jdonuts/features/auth/data/session_storage.dart';
import 'package:jdonuts/features/auth/data/user_store.dart';
import 'package:jdonuts/features/auth/domain/auth_entities.dart';
import 'package:jdonuts/features/auth/domain/auth_use_cases.dart';

import '../helpers/fakes.dart';

void main() {
  const phone = '+959254135592';
  late InMemoryUserStore users;
  late InMemorySessionStorage session;
  late FakeAuthRepository auth;
  late InMemoryMemberRepository members;

  final details = RegistrationDetails(
    phone: phone,
    firstName: 'Ye Min',
    lastName: 'Phyoe Win',
    dateOfBirth: DateTime(1980, 5, 1),
  );

  setUp(() {
    users = InMemoryUserStore();
    session = InMemorySessionStorage();
    auth = fastAuthRepository(users: users, session: session);
    members = InMemoryMemberRepository();
  });

  group('RequestOtp', () {
    test('normalizes the typed number before calling the repository', () async {
      final result = await RequestOtp(auth)(rawPhone: '09 254 135 592', flow: AuthFlow.register);
      expect(result.valueOrNull, phone);
    });

    test('log in with a number that never registered fails with UserNotFound', () async {
      final result = await RequestOtp(auth)(rawPhone: '09254135592', flow: AuthFlow.login);
      expect(result.failureOrNull, isA<UserNotFoundFailure>());
    });

    test('register with an existing number fails with UserAlreadyExists', () async {
      await auth.register(details);
      final result = await RequestOtp(auth)(rawPhone: '09254135592', flow: AuthFlow.register);
      expect(result.failureOrNull, isA<UserAlreadyExistsFailure>());
    });
  });

  group('VerifyOtp', () {
    test('accepts the fake code 123456 and asks a new user for a profile', () async {
      final result = await VerifyOtp(auth, members)(
        phone: phone,
        code: kFakeOtpCode,
        flow: AuthFlow.register,
      );
      expect(result.valueOrNull, isA<PhoneVerified>());
      expect(await session.readPhone(), isNull);
    });

    test('rejects any other code', () async {
      final result = await VerifyOtp(auth, members)(
        phone: phone,
        code: '654321',
        flow: AuthFlow.register,
      );
      expect(result.failureOrNull, isA<InvalidOtpFailure>());
    });

    test('rejects a malformed code without calling the repository', () async {
      final result = await VerifyOtp(auth, members)(
        phone: phone,
        code: '12',
        flow: AuthFlow.login,
      );
      expect(result.failureOrNull, isA<InvalidOtpFailure>());
    });

    test('signs a returning user in, stores the session and syncs the member name', () async {
      await auth.register(details);
      await session.clear();
      final result = await VerifyOtp(auth, members)(
        phone: phone,
        code: kFakeOtpCode,
        flow: AuthFlow.login,
      );
      expect(result.valueOrNull, isA<SignedIn>());
      expect(await session.readPhone(), phone);
      expect(members.updatedNames, ['Ye Min']);
    });
  });

  group('CompleteRegistration', () {
    test('creates the user, starts a session and personalizes the member', () async {
      final result = await CompleteRegistration(auth, members)(details);
      expect(result, isA<Ok<User>>());
      expect((await users.findByPhone(phone))?.lastName, 'Phyoe Win');
      expect(await session.readPhone(), phone);
      expect(members.updatedNames, ['Ye Min']);
    });
  });

  group('session', () {
    test('RestoreSession returns the signed-in user after a relaunch', () async {
      await CompleteRegistration(auth, members)(details);
      final relaunched = fastAuthRepository(users: users, session: session);
      final user = await RestoreSession(relaunched)();
      expect(user?.phone, phone);
    });

    test('LogOut clears the session so a relaunch opens Onboarding', () async {
      await CompleteRegistration(auth, members)(details);
      await LogOut(auth)();
      expect(await RestoreSession(auth)(), isNull);
    });
  });

  test('every fake call waits for the configured latency', () async {
    final slow = fastAuthRepository(latency: const Duration(milliseconds: 120));
    final watch = Stopwatch()..start();
    await slow.requestOtp(phone: phone, flow: AuthFlow.register);
    expect(watch.elapsed, greaterThanOrEqualTo(const Duration(milliseconds: 120)));
  });

  test('the production fake waits about one second', () {
    expect(kFakeAuthLatency, const Duration(seconds: 1));
  });
}
