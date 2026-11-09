import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/failure.dart';
import '../../../../core/domain/result.dart';
import '../../auth_providers.dart';
import '../../domain/auth_entities.dart';
import 'registration_draft.dart';

final class SubmitState {
  const SubmitState({this.isSubmitting = false, this.failure});

  final bool isSubmitting;
  final Failure? failure;
}

final phoneStepControllerProvider =
    NotifierProvider.autoDispose<PhoneStepController, SubmitState>(
  PhoneStepController.new,
);

class PhoneStepController extends Notifier<SubmitState> {
  @override
  SubmitState build() => const SubmitState();

  /// Clears a previous server error once the user edits the number.
  void clearFailure() {
    if (state.failure != null) state = const SubmitState();
  }

  /// Requests an OTP. Returns `true` when the next step may open.
  /// A second tap while a request is running is ignored.
  Future<bool> submit(AuthFlow flow) async {
    if (state.isSubmitting) return false;
    state = const SubmitState(isSubmitting: true);
    final draft = ref.read(registrationDraftProvider);
    final result = await ref
        .read(requestOtpProvider)
        .call(rawPhone: draft.rawPhone, flow: flow);
    if (!ref.mounted) return false;
    switch (result) {
      case Ok(:final value):
        ref
            .read(registrationDraftProvider.notifier)
            .update((d) => d.copyWith(verifiedPhone: value));
        state = const SubmitState();
        return true;
      case Err(:final failure):
        state = SubmitState(failure: failure);
        return false;
    }
  }
}
