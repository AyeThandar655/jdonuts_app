import '../../../core/domain/failure.dart';
import '../../../core/widgets/section_states.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/validators/dob_validator.dart';
import '../domain/validators/name_validator.dart';
import '../domain/validators/phone_validator.dart';

/// Maps domain validation errors and auth failures to localized text.

String? phoneErrorText(AppLocalizations l10n, PhoneError? error) =>
    switch (error) {
      null => null,
      PhoneError.empty => l10n.phoneErrorEmpty,
      PhoneError.invalid => l10n.phoneErrorInvalid,
    };

String? nameErrorText(AppLocalizations l10n, NameError? error) =>
    switch (error) {
      null => null,
      NameError.required => l10n.nameErrorRequired,
      NameError.tooLong => l10n.nameErrorTooLong(kNameMaxLength),
      NameError.invalidCharacters => l10n.nameErrorCharacters,
    };

String? dobErrorText(AppLocalizations l10n, DobError? error) =>
    switch (error) {
      null || DobError.incomplete => null,
      DobError.invalidDate => l10n.dobErrorInvalid,
      DobError.inFuture => l10n.dobErrorFuture,
      DobError.tooYoung => l10n.dobErrorTooYoung(kMinimumAge),
      DobError.tooOld => l10n.dobErrorTooOld(kEarliestBirthYear),
    };

String authFailureText(AppLocalizations l10n, Failure failure) =>
    switch (failure) {
      UserNotFoundFailure() => l10n.phoneNotRegistered,
      UserAlreadyExistsFailure() => l10n.phoneAlreadyRegistered,
      InvalidOtpFailure() => l10n.otpErrorWrong,
      _ => failureMessage(l10n, failure),
    };
