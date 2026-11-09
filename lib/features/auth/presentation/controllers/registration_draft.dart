import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/auth_entities.dart';

/// Everything typed during sign-up / log-in, kept while the user moves back
/// and forth between steps.
final class RegistrationDraft {
  const RegistrationDraft({
    this.flow = AuthFlow.register,
    this.rawPhone = '',
    this.verifiedPhone,
    this.firstName = '',
    this.lastName = '',
    this.birthMonth,
    this.birthDay = '',
    this.birthYear = '',
  });

  final AuthFlow flow;
  final String rawPhone;

  /// E.164 number the OTP was sent to.
  final String? verifiedPhone;
  final String firstName;
  final String lastName;
  final int? birthMonth;
  final String birthDay;
  final String birthYear;

  RegistrationDraft copyWith({
    String? rawPhone,
    String? verifiedPhone,
    String? firstName,
    String? lastName,
    int? birthMonth,
    String? birthDay,
    String? birthYear,
  }) =>
      RegistrationDraft(
        flow: flow,
        rawPhone: rawPhone ?? this.rawPhone,
        verifiedPhone: verifiedPhone ?? this.verifiedPhone,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        birthMonth: birthMonth ?? this.birthMonth,
        birthDay: birthDay ?? this.birthDay,
        birthYear: birthYear ?? this.birthYear,
      );
}

final registrationDraftProvider =
    NotifierProvider<RegistrationDraftController, RegistrationDraft>(
  RegistrationDraftController.new,
);

class RegistrationDraftController extends Notifier<RegistrationDraft> {
  @override
  RegistrationDraft build() => const RegistrationDraft();

  /// Starts a fresh flow from Onboarding.
  void start(AuthFlow flow) => state = RegistrationDraft(flow: flow);

  /// Switches the flow but keeps the typed phone (e.g. "Register instead").
  void switchFlow(AuthFlow flow) =>
      state = RegistrationDraft(flow: flow, rawPhone: state.rawPhone);

  void update(RegistrationDraft Function(RegistrationDraft draft) change) =>
      state = change(state);
}
