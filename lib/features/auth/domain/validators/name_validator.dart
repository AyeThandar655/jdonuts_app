import '../../../../core/domain/validation.dart';

enum NameError { required, tooLong, invalidCharacters }

const int kNameMaxLength = 50;

/// Letters from any script (Myanmar included), their combining marks, and
/// spaces. Digits and symbols are rejected.
final RegExp _nameCharacters = RegExp(r'^[\p{L}\p{M} ]+$', unicode: true);

/// First name: required, 1 to [kNameMaxLength] characters after trimming.
Validation<String, NameError> validateFirstName(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return const Invalid(NameError.required);
  return _validateCharacters(trimmed);
}

/// Last name: optional (many Myanmar names have no family name). An empty
/// value is valid and normalizes to `null`.
Validation<String?, NameError> validateLastName(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return const Valid(null);
  return switch (_validateCharacters(trimmed)) {
    Valid(:final value) => Valid(value),
    Invalid(:final error) => Invalid(error),
  };
}

Validation<String, NameError> _validateCharacters(String trimmed) {
  if (trimmed.runes.length > kNameMaxLength) {
    return const Invalid(NameError.tooLong);
  }
  if (!_nameCharacters.hasMatch(trimmed)) {
    return const Invalid(NameError.invalidCharacters);
  }
  return Valid(trimmed);
}
