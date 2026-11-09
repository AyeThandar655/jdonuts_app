import 'failure.dart';

/// Outcome of an operation that can fail in an expected way.
///
/// Repositories return a [Result] instead of throwing, so callers are forced
/// to handle the failure branch and no exception is silently swallowed.
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;
  const factory Result.err(Failure failure) = Err<T>;

  bool get isOk => this is Ok<T>;

  /// Returns the value, or `null` when this is a failure.
  T? get valueOrNull => switch (this) {
        Ok<T>(:final value) => value,
        Err<T>() => null,
      };

  /// Returns the failure, or `null` when this is a success.
  Failure? get failureOrNull => switch (this) {
        Ok<T>() => null,
        Err<T>(:final failure) => failure,
      };

  /// Maps the success value, keeping the failure untouched.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
        Ok<T>(:final value) => Result.ok(transform(value)),
        Err<T>(:final failure) => Result.err(failure),
      };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}

/// A [Result] for operations that produce no value.
typedef VoidResult = Result<void>;

/// Shorthand for a successful [VoidResult].
const VoidResult okVoid = Ok<void>(null);
