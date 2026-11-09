/// Outcome of a pure validator: either a normalized value or a typed error.
sealed class Validation<T, E> {
  const Validation();

  bool get isValid => this is Valid<T, E>;

  T? get valueOrNull => switch (this) {
        Valid<T, E>(:final value) => value,
        Invalid<T, E>() => null,
      };

  E? get errorOrNull => switch (this) {
        Valid<T, E>() => null,
        Invalid<T, E>(:final error) => error,
      };
}

final class Valid<T, E> extends Validation<T, E> {
  const Valid(this.value);
  final T value;
}

final class Invalid<T, E> extends Validation<T, E> {
  const Invalid(this.error);
  final E error;
}
