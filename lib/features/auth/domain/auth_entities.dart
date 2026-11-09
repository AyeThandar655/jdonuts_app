/// Which path brought the user to the phone / OTP screens.
enum AuthFlow {
  register,
  login;

  static AuthFlow fromName(String? name) =>
      AuthFlow.values.firstWhere((f) => f.name == name, orElse: () => register);
}

/// A registered customer.
final class User {
  const User({
    required this.phone,
    required this.firstName,
    required this.dateOfBirth,
    this.lastName,
  });

  /// E.164, e.g. `+959254135592`.
  final String phone;
  final String firstName;
  final String? lastName;
  final DateTime dateOfBirth;

  String get fullName =>
      lastName == null ? firstName : '$firstName $lastName';
}

/// Everything collected across the registration steps.
final class RegistrationDetails {
  const RegistrationDetails({
    required this.phone,
    required this.firstName,
    required this.dateOfBirth,
    this.lastName,
  });

  final String phone;
  final String firstName;
  final String? lastName;
  final DateTime dateOfBirth;
}

/// What a correct OTP leads to.
sealed class OtpOutcome {
  const OtpOutcome();
}

/// Log in succeeded; a session now exists.
final class SignedIn extends OtpOutcome {
  const SignedIn(this.user);
  final User user;
}

/// The phone is verified; the user still has to finish registration.
final class PhoneVerified extends OtpOutcome {
  const PhoneVerified(this.phone);
  final String phone;
}
