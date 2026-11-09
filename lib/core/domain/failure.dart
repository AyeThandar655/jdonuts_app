/// Typed failures shared by every feature. Pure Dart, no Flutter imports.
sealed class Failure implements Exception {
  const Failure(this.debugMessage);

  /// Developer-facing detail. UI maps the failure *type* to localized text.
  final String debugMessage;

  @override
  String toString() => '$runtimeType($debugMessage)';
}

/// The device is offline or the server could not be reached.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.debugMessage = 'network unavailable']);
}

/// The server answered with an error envelope or an unexpected payload.
final class ServerFailure extends Failure {
  const ServerFailure(super.debugMessage, {this.code});
  final String? code;
}

/// Reading or writing the local database failed.
final class StorageFailure extends Failure {
  const StorageFailure(super.debugMessage);
}

/// The requested record does not exist locally.
final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.debugMessage);
}

/// Authentication-specific failures.
sealed class AuthFailure extends Failure {
  const AuthFailure(super.debugMessage);
}

/// Log in was attempted with a number that never registered.
final class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure() : super('no user for this phone number');
}

/// Registration was attempted with a number that already has an account.
final class UserAlreadyExistsFailure extends AuthFailure {
  const UserAlreadyExistsFailure() : super('phone number already registered');
}

/// The OTP did not match.
final class InvalidOtpFailure extends AuthFailure {
  const InvalidOtpFailure() : super('otp did not match');
}

/// Anything we did not anticipate. Always carries the original error text.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.debugMessage);
}
