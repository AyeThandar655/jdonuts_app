import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/features/auth/domain/validators/name_validator.dart';

void main() {
  group('validateFirstName', () {
    test('accepts a Latin name and trims it', () {
      expect(validateFirstName('  Ye Min ').valueOrNull, 'Ye Min');
    });

    test('accepts Myanmar script, including combining marks', () {
      expect(validateFirstName('ရဲမင်း').valueOrNull, 'ရဲမင်း');
    });

    test('is required', () {
      expect(validateFirstName('').errorOrNull, NameError.required);
      expect(validateFirstName('   ').errorOrNull, NameError.required);
    });

    test('accepts a single character', () {
      expect(validateFirstName('A').isValid, isTrue);
    });

    test('accepts exactly 50 characters after trimming', () {
      expect(validateFirstName(' ${'a' * kNameMaxLength} ').isValid, isTrue);
    });

    test('rejects 51 characters', () {
      expect(validateFirstName('a' * (kNameMaxLength + 1)).errorOrNull, NameError.tooLong);
    });

    test('rejects digits, including Myanmar digits', () {
      expect(validateFirstName('Ye Min 2').errorOrNull, NameError.invalidCharacters);
      expect(validateFirstName('ရဲ၂').errorOrNull, NameError.invalidCharacters);
    });

    test('rejects symbols', () {
      expect(validateFirstName('Ye_Min!').errorOrNull, NameError.invalidCharacters);
    });
  });

  group('validateLastName', () {
    test('is optional: empty normalizes to null', () {
      final result = validateLastName('  ');
      expect(result.isValid, isTrue);
      expect(result.valueOrNull, isNull);
    });

    test('follows the same character rules as the first name', () {
      expect(validateLastName('Phyoe Win').valueOrNull, 'Phyoe Win');
      expect(validateLastName('Win9').errorOrNull, NameError.invalidCharacters);
      expect(validateLastName('a' * 51).errorOrNull, NameError.tooLong);
    });
  });
}
