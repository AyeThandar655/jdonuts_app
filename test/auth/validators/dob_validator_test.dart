import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/features/auth/domain/validators/dob_validator.dart';

void main() {
  final today = DateTime(2026, 11, 9);

  DobError? errorFor(int? year, int? month, int? day) => validateDateOfBirth(
        year: year,
        month: month,
        day: day,
        today: today,
      ).errorOrNull;

  group('validateDateOfBirth', () {
    test('accepts the design example, 1 May 1980', () {
      final result = validateDateOfBirth(year: 1980, month: 5, day: 1, today: today);
      expect(result.valueOrNull, DateTime(1980, 5, 1));
    });

    test('reports missing parts as incomplete', () {
      expect(errorFor(null, 5, 1), DobError.incomplete);
      expect(errorFor(1980, null, 1), DobError.incomplete);
      expect(errorFor(1980, 5, null), DobError.incomplete);
    });

    test('rejects 31 April', () {
      expect(errorFor(1990, 4, 31), DobError.invalidDate);
    });

    test('accepts 29 February in a leap year', () {
      expect(errorFor(2000, 2, 29), isNull);
    });

    test('rejects 29 February outside a leap year', () {
      expect(errorFor(2001, 2, 29), DobError.invalidDate);
      expect(errorFor(1900, 2, 29), DobError.invalidDate);
    });

    test('rejects months and days out of range', () {
      expect(errorFor(1990, 13, 1), DobError.invalidDate);
      expect(errorFor(1990, 0, 1), DobError.invalidDate);
      expect(errorFor(1990, 1, 0), DobError.invalidDate);
      expect(errorFor(1990, 1, 32), DobError.invalidDate);
    });

    test('rejects a date in the future', () {
      expect(errorFor(2026, 11, 10), DobError.inFuture);
    });

    test('rejects someone younger than 13', () {
      expect(kMinimumAge, 13);
      expect(errorFor(2013, 11, 10), DobError.tooYoung);
    });

    test('accepts someone turning 13 today', () {
      expect(errorFor(2013, 11, 9), isNull);
    });

    test('rejects implausible years before 1900', () {
      expect(errorFor(1899, 12, 31), DobError.tooOld);
    });
  });

  group('ageOn', () {
    test('does not count the birthday until it arrives', () {
      expect(ageOn(DateTime(2000, 12, 1), DateTime(2026, 11, 30)), 25);
      expect(ageOn(DateTime(2000, 12, 1), DateTime(2026, 12, 1)), 26);
    });
  });

  test('isLeapYear follows the Gregorian rules', () {
    expect(isLeapYear(2024), isTrue);
    expect(isLeapYear(1900), isFalse);
    expect(isLeapYear(2000), isTrue);
    expect(isLeapYear(2026), isFalse);
  });
}
