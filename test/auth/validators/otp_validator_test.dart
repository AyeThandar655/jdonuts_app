import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/features/auth/domain/validators/otp_validator.dart';

void main() {
  group('validateOtp', () {
    test('accepts exactly six digits', () {
      expect(validateOtp('123456').valueOrNull, '123456');
    });

    test('rejects fewer than six digits as incomplete', () {
      expect(validateOtp('12345').errorOrNull, OtpError.incomplete);
      expect(validateOtp('').errorOrNull, OtpError.incomplete);
    });

    test('rejects more than six digits as incomplete', () {
      expect(validateOtp('1234567').errorOrNull, OtpError.incomplete);
    });

    test('rejects non-digit characters', () {
      expect(validateOtp('12a456').errorOrNull, OtpError.notDigits);
    });
  });

  group('isOtpLocked', () {
    test('stays unlocked for the first two wrong codes', () {
      expect(isOtpLocked(0), isFalse);
      expect(isOtpLocked(2), isFalse);
    });

    test('locks after three wrong codes', () {
      expect(kMaxOtpAttempts, 3);
      expect(isOtpLocked(3), isTrue);
    });
  });

  group('sanitizeOtpInput (paste and SMS autofill)', () {
    test('keeps only digits so a pasted "123 456" fills every box', () {
      expect(sanitizeOtpInput('123 456'), '123456');
    });

    test('caps the input at six digits', () {
      expect(sanitizeOtpInput('Your code is 12345678'), '123456');
    });
  });

  test('the resend countdown starts at 5:00', () {
    expect(kOtpResendCountdown, const Duration(minutes: 5));
  });
}
