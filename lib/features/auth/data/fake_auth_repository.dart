import '../../../core/domain/failure.dart';
import '../../../core/domain/result.dart';
import '../domain/auth_entities.dart';
import '../domain/auth_repository.dart';
import 'session_storage.dart';
import 'user_store.dart';

/// The only OTP the fake back end accepts.
const String kFakeOtpCode = '123456';

/// Simulated network latency for every fake call.
const Duration kFakeAuthLatency = Duration(seconds: 1);

/// Fake [AuthRepository]: waits about a second like a real API, keeps users
/// in the local database and the session in secure storage.
final class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    required UserStore users,
    required SessionStorage session,
    this.latency = kFakeAuthLatency,
  })  : _users = users,
        _session = session;

  final UserStore _users;
  final SessionStorage _session;
  final Duration latency;

  @override
  Future<Result<void>> requestOtp({
    required String phone,
    required AuthFlow flow,
  }) =>
      _guard(() async {
        final existing = await _users.findByPhone(phone);
        return switch (flow) {
          AuthFlow.login when existing == null =>
            const Result.err(UserNotFoundFailure()),
          AuthFlow.register when existing != null =>
            const Result.err(UserAlreadyExistsFailure()),
          _ => okVoid,
        };
      });

  @override
  Future<Result<OtpOutcome>> verifyOtp({
    required String phone,
    required String code,
    required AuthFlow flow,
  }) =>
      _guard(() async {
        if (code != kFakeOtpCode) return const Result.err(InvalidOtpFailure());
        if (flow == AuthFlow.register) return Result.ok(PhoneVerified(phone));
        final user = await _users.findByPhone(phone);
        if (user == null) return const Result.err(UserNotFoundFailure());
        await _session.writePhone(user.phone);
        return Result.ok(SignedIn(user));
      });

  @override
  Future<Result<User>> register(RegistrationDetails details) =>
      _guard(() async {
        if (await _users.findByPhone(details.phone) != null) {
          return const Result.err(UserAlreadyExistsFailure());
        }
        final user = User(
          phone: details.phone,
          firstName: details.firstName,
          lastName: details.lastName,
          dateOfBirth: details.dateOfBirth,
        );
        await _users.insert(user);
        await _session.writePhone(user.phone);
        return Result.ok(user);
      });

  @override
  Future<User?> restoreSession() async {
    final phone = await _session.readPhone();
    return phone == null ? null : _users.findByPhone(phone);
  }

  @override
  Future<Result<void>> logOut() => _guard(() async {
        await _session.clear();
        return okVoid;
      });

  /// Adds latency and turns unexpected exceptions into typed failures.
  Future<Result<T>> _guard<T>(Future<Result<T>> Function() body) async {
    await Future<void>.delayed(latency);
    try {
      return await body();
    } on Exception catch (e) {
      return Result.err(StorageFailure(e.toString()));
    }
  }
}
