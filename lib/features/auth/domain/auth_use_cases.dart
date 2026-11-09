import '../../../core/domain/failure.dart';
import '../../../core/domain/result.dart';
import '../../member/domain/member_repository.dart';
import 'auth_entities.dart';
import 'auth_repository.dart';
import 'validators/otp_validator.dart';
import 'validators/phone_validator.dart';

/// Validates the typed number and asks the repository for an OTP.
/// Returns the normalized E.164 number on success.
class RequestOtp {
  const RequestOtp(this._auth);
  final AuthRepository _auth;

  Future<Result<String>> call({
    required String rawPhone,
    required AuthFlow flow,
  }) async {
    final phone = validatePhone(rawPhone).valueOrNull;
    if (phone == null) {
      return const Result.err(UnexpectedFailure('phone failed validation'));
    }
    final result = await _auth.requestOtp(phone: phone, flow: flow);
    return result.map((_) => phone);
  }
}

/// Checks the OTP and, for a returning user, syncs the member name.
class VerifyOtp {
  const VerifyOtp(this._auth, this._members);
  final AuthRepository _auth;
  final MemberRepository _members;

  Future<Result<OtpOutcome>> call({
    required String phone,
    required String code,
    required AuthFlow flow,
  }) async {
    final validCode = validateOtp(code).valueOrNull;
    if (validCode == null) return const Result.err(InvalidOtpFailure());
    final result =
        await _auth.verifyOtp(phone: phone, code: validCode, flow: flow);
    if (result case Ok(value: SignedIn(:final user))) {
      await _members.updateDisplayName(user.firstName);
    }
    return result;
  }
}

/// Creates the account from all registration steps and personalizes the
/// member record.
class CompleteRegistration {
  const CompleteRegistration(this._auth, this._members);
  final AuthRepository _auth;
  final MemberRepository _members;

  Future<Result<User>> call(RegistrationDetails details) async {
    final result = await _auth.register(details);
    if (result case Ok(:final value)) {
      await _members.updateDisplayName(value.firstName);
    }
    return result;
  }
}

class RestoreSession {
  const RestoreSession(this._auth);
  final AuthRepository _auth;

  Future<User?> call() => _auth.restoreSession();
}

class LogOut {
  const LogOut(this._auth);
  final AuthRepository _auth;

  Future<Result<void>> call() => _auth.logOut();
}
