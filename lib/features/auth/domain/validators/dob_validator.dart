import '../../../../core/domain/validation.dart';

enum DobError { incomplete, invalidDate, inFuture, tooYoung, tooOld }

/// Youngest age allowed to register.
const int kMinimumAge = 13;

/// Earliest birth year we accept as plausible.
const int kEarliestBirthYear = 1900;

const int _monthsPerYear = 12;
const int _maxDayOfMonth = 31;

/// Validates a date of birth entered as separate fields.
///
/// The date must exist on the calendar (no 31 April; 29 February only in leap
/// years), must not be in the future, and the person must be at least
/// [kMinimumAge] years old on [today].
Validation<DateTime, DobError> validateDateOfBirth({
  required int? year,
  required int? month,
  required int? day,
  required DateTime today,
}) {
  if (year == null || month == null || day == null) {
    return const Invalid(DobError.incomplete);
  }
  final date = _calendarDate(year, month, day);
  if (date == null) return const Invalid(DobError.invalidDate);
  if (year < kEarliestBirthYear) return const Invalid(DobError.tooOld);
  final todayDate = DateTime(today.year, today.month, today.day);
  if (date.isAfter(todayDate)) return const Invalid(DobError.inFuture);
  if (ageOn(date, todayDate) < kMinimumAge) {
    return const Invalid(DobError.tooYoung);
  }
  return Valid(date);
}

/// Returns the date only if it really exists; `DateTime` would silently roll
/// 31 April over to 1 May, so we compare the parts back.
DateTime? _calendarDate(int year, int month, int day) {
  if (month < 1 || month > _monthsPerYear) return null;
  if (day < 1 || day > _maxDayOfMonth) return null;
  final date = DateTime(year, month, day);
  final exists = date.year == year && date.month == month && date.day == day;
  return exists ? date : null;
}

/// Whole years between [birth] and [on], counting the birthday itself.
int ageOn(DateTime birth, DateTime on) {
  var age = on.year - birth.year;
  final hadBirthday = on.month > birth.month ||
      (on.month == birth.month && on.day >= birth.day);
  if (!hadBirthday) age -= 1;
  return age;
}

/// True for leap years in the Gregorian calendar.
bool isLeapYear(int year) =>
    (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
