import '../../../../core/domain/validation.dart';

enum PhoneError { empty, invalid }

/// Myanmar country calling code shown as the fixed field prefix.
const String kMyanmarCountryCode = '+95';

final RegExp _separators = RegExp(r'[\s-]');
final RegExp _subscriberNumber = RegExp(r'^9\d{7,9}$');

/// Removes spaces and dashes, then one leading `0`.
///
/// `092-541 35592` -> `9254135592`
String normalizeMyanmarPhone(String raw) {
  final digits = raw.replaceAll(_separators, '');
  return digits.startsWith('0') ? digits.substring(1) : digits;
}

/// Validates the number typed after the `+95` prefix.
///
/// After normalizing, it must be `9` followed by 7 to 9 digits. On success the
/// value is the E.164 number, e.g. `09254135592` -> `+959254135592`.
Validation<String, PhoneError> validatePhone(String raw) {
  final normalized = normalizeMyanmarPhone(raw);
  if (normalized.isEmpty) return const Invalid(PhoneError.empty);
  if (!_subscriberNumber.hasMatch(normalized)) {
    return const Invalid(PhoneError.invalid);
  }
  return Valid('$kMyanmarCountryCode$normalized');
}
