import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/domain/validation.dart';
import 'package:jdonuts/features/auth/domain/validators/phone_validator.dart';

void main() {
  group('validatePhone', () {
    test('turns the design example 09254135592 into +959254135592', () {
      expect(validatePhone('09254135592').valueOrNull, '+959254135592');
    });

    test('strips spaces and dashes before checking', () {
      expect(validatePhone('09-254 135 592').valueOrNull, '+959254135592');
    });

    test('accepts a number typed without the leading 0', () {
      expect(validatePhone('9254135592').valueOrNull, '+959254135592');
    });

    test('accepts 9 followed by 7 digits (shortest)', () {
      expect(validatePhone('091234567').isValid, isTrue);
    });

    test('accepts 9 followed by 9 digits (longest)', () {
      expect(validatePhone('09123456789').isValid, isTrue);
    });

    test('rejects 9 followed by only 6 digits', () {
      expect(validatePhone('09123456').errorOrNull, PhoneError.invalid);
    });

    test('rejects 9 followed by 10 digits', () {
      expect(validatePhone('091234567890').errorOrNull, PhoneError.invalid);
    });

    test('rejects numbers that do not start with 9 after the 0', () {
      expect(validatePhone('0812345678').errorOrNull, PhoneError.invalid);
    });

    test('strips only one leading 0', () {
      expect(validatePhone('009254135592').errorOrNull, PhoneError.invalid);
    });

    test('rejects letters and symbols', () {
      expect(validatePhone('09254a35592').errorOrNull, PhoneError.invalid);
      expect(validatePhone('+959254135592').errorOrNull, PhoneError.invalid);
    });

    test('reports empty input separately', () {
      expect(validatePhone('').errorOrNull, PhoneError.empty);
      expect(validatePhone(' - ').errorOrNull, PhoneError.empty);
    });

    test('returns a Valid result type on success', () {
      expect(validatePhone('09254135592'), isA<Valid<String, PhoneError>>());
    });
  });
}
