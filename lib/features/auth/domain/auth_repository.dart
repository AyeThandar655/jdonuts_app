import '../../../core/domain/result.dart';
import 'auth_entities.dart';

/// Authentication contract. The app ships a fake implementation; a real API
/// can replace it without touching the UI.
abstract interface class AuthRepository {
  /// Sends an OTP to [phone]. For [AuthFlow.login] fails with
  /// `UserNotFoundFailure` when the number never registered; for
  /// [AuthFlow.register] fails with `UserAlreadyExistsFailure`.
  Future<Result<void>> requestOtp({
    required String phone,
    required AuthFlow flow,
  });

  /// Checks [code]. Fails with `InvalidOtpFailure` on a wrong code.
  Future<Result<OtpOutcome>> verifyOtp({
    required String phone,
    required String code,
    required AuthFlow flow,
  });

  /// Creates the account and starts a session.
  Future<Result<User>> register(RegistrationDetails details);

  /// The signed-in user from the stored session, if any.
  Future<User?> restoreSession();

  Future<Result<void>> logOut();
}
