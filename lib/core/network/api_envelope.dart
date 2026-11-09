import '../domain/failure.dart';
import '../domain/result.dart';

/// Unwraps the `{data, error, meta}` response envelope used by `/v1`.
Result<T> unwrapEnvelope<T>(Object? body, T Function(Object? data) parse) {
  if (body is! Map<String, dynamic>) {
    return const Result.err(ServerFailure('response is not an envelope'));
  }
  final error = body['error'];
  if (error is Map<String, dynamic>) {
    return Result.err(
      ServerFailure(
        error['message'] as String? ?? 'server error',
        code: error['code'] as String?,
      ),
    );
  }
  try {
    return Result.ok(parse(body['data']));
  } on TypeError catch (e) {
    return Result.err(ServerFailure('malformed data: $e'));
  }
}
