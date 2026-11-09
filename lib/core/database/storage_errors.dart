import '../domain/failure.dart';
import '../domain/result.dart';

/// Runs a database write and converts exceptions into a [StorageFailure].
Future<Result<void>> guardStorage(Future<void> Function() body) async {
  try {
    await body();
    return okVoid;
  } on Exception catch (e) {
    return Result.err(StorageFailure(e.toString()));
  }
}

extension StorageErrorMapping<T> on Stream<T> {
  /// Re-emits database errors as typed [StorageFailure]s so the UI can show a
  /// section-level error state.
  Stream<T> mapStorageErrors() => handleError(
        (Object error) => throw StorageFailure(error.toString()),
        test: (error) => error is! Failure,
      );
}
