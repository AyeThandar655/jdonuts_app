import '../features/auth/domain/auth_entities.dart';

/// Every path in the app, in one place.
abstract final class Routes {
  static const String onboarding = '/onboarding';
  static const String authPrefix = '/auth';
  static const String phonePattern = '/auth/:flow/phone';
  static const String otpPattern = '/auth/:flow/otp';
  static const String name = '/auth/register/name';
  static const String dateOfBirth = '/auth/register/dob';
  static const String welcome = '/welcome';
  static const String home = '/home';
  static const String rewards = '/rewards';
  static const String order = '/order';
  static const String wallet = '/wallet';
  static const String settings = '/settings';
  static const String productPattern = '/product/:id';
  static const String sectionPattern = '/section/:id';

  static String phone(AuthFlow flow) => '$authPrefix/${flow.name}/phone';
  static String otp(AuthFlow flow) => '$authPrefix/${flow.name}/otp';
  static String product(String id) => '/product/$id';
  static String section(String id) => '/section/$id';

  /// Routes reachable without a session.
  static bool isPublic(String location) =>
      location == onboarding || location.startsWith(authPrefix);
}
