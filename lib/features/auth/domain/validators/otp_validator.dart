import '../../../../core/domain/validation.dart';

enum OtpError { incomplete, notDigits }

/// Number of OTP boxes.
const int kOtpLength = 6;

/// Wrong codes allowed before entry locks until the user taps Resend.
const int kMaxOtpAttempts = 3;

/// Time before the Resend action becomes available.
const Duration kOtpResendCountdown = Duration(minutes: 5);

final RegExp _digitsOnly = RegExp(r'^\d+$');

/// Checks the *shape* of an OTP: exactly [kOtpLength] digits.
/// Whether the code is correct is decided by the [AuthRepository].
Validation<String, OtpError> validateOtp(String raw) {
  final code = raw.trim();
  if (code.isNotEmpty && !_digitsOnly.hasMatch(code)) {
    return const Invalid(OtpError.notDigits);
  }
  if (code.length != kOtpLength) return const Invalid(OtpError.incomplete);
  return Valid(code);
}

/// True once [failedAttempts] wrong codes have been entered.
bool isOtpLocked(int failedAttempts) => failedAttempts >= kMaxOtpAttempts;

/// Keeps only digits and caps the length, so a pasted "123 456" or an SMS
/// autofill string fills all boxes.
String sanitizeOtpInput(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  return digits.length > kOtpLength ? digits.substring(0, kOtpLength) : digits;
}
