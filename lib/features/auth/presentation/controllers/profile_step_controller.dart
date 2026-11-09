import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/result.dart';
import '../../auth_providers.dart';
import '../../domain/auth_entities.dart';
import '../../domain/validators/dob_validator.dart';
import '../../domain/validators/name_validator.dart';
import 'auth_session_controller.dart';
import 'phone_step_controller.dart';
import 'registration_draft.dart';

/// Supplies "today" so date rules are testable.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final profileStepControllerProvider =
    NotifierProvider.autoDispose<ProfileStepController, SubmitState>(
  ProfileStepController.new,
);

/// Final registration step: validates every field again and creates the
/// account. On success the session changes and the router moves to Welcome.
class ProfileStepController extends Notifier<SubmitState> {
  @override
  SubmitState build() => const SubmitState();

  Future<bool> submit() async {
    if (state.isSubmitting) return false;
    final details = _details(ref.read(registrationDraftProvider));
    if (details == null) return false;
    state = const SubmitState(isSubmitting: true);
    final result = await ref.read(completeRegistrationProvider).call(details);
    if (!ref.mounted) return false;
    switch (result) {
      case Ok(:final value):
        state = const SubmitState();
        ref.read(authSessionProvider.notifier).signedIn(value, isNewUser: true);
        return true;
      case Err(:final failure):
        state = SubmitState(failure: failure);
        return false;
    }
  }

  RegistrationDetails? _details(RegistrationDraft draft) {
    final phone = draft.verifiedPhone;
    final firstName = validateFirstName(draft.firstName).valueOrNull;
    final lastName = validateLastName(draft.lastName);
    final dob = validateDateOfBirth(
      year: int.tryParse(draft.birthYear),
      month: draft.birthMonth,
      day: int.tryParse(draft.birthDay),
      today: ref.read(clockProvider)(),
    ).valueOrNull;
    if (phone == null || firstName == null || !lastName.isValid || dob == null) {
      return null;
    }
    return RegistrationDetails(
      phone: phone,
      firstName: firstName,
      lastName: lastName.valueOrNull,
      dateOfBirth: dob,
    );
  }
}
