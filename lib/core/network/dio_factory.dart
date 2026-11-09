import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_config.dart';

/// Builds the configured [Dio] client: timeouts, retry and logging.
Dio createDio(ApiConfig config) {
  final dio = Dio(
    BaseOptions(
      baseUrl: '${config.baseUrl}${ApiConfig.apiVersionPath}',
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      responseType: ResponseType.json,
    ),
  );
  dio.interceptors.add(RetryInterceptor(dio));
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(requestBody: false, responseBody: false, logPrint: _log),
    );
  }
  return dio;
}

void _log(Object message) => debugPrint('[api] $message');

/// Retries idempotent GET requests on transient network errors with
/// exponential back-off.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio, {this.maxRetries = ApiConfig.maxRetries});

  final Dio _dio;
  final int maxRetries;

  static const String _attemptKey = 'retry_attempt';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = (options.extra[_attemptKey] as int?) ?? 0;
    if (!_isRetryable(err) || attempt >= maxRetries) {
      handler.next(err);
      return;
    }
    await Future<void>.delayed(ApiConfig.retryBaseDelay * (1 << attempt));
    options.extra[_attemptKey] = attempt + 1;
    try {
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _isRetryable(DioException err) {
    final isGet = err.requestOptions.method.toUpperCase() == 'GET';
    final transient = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError =>
        true,
      _ => false,
    };
    return isGet && transient;
  }
}
