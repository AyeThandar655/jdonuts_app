import 'package:dio/dio.dart';

import '../../../core/database/json_rows.dart';
import '../../../core/domain/failure.dart';
import '../../../core/domain/result.dart';
import '../../../core/network/api_envelope.dart';

/// Raw public catalog as delivered by `/v1`.
final class CatalogPayload {
  const CatalogPayload({
    required this.products,
    required this.banners,
    required this.sections,
    required this.shops,
  });

  final List<JsonMap> products;
  final List<JsonMap> banners;
  final List<JsonMap> sections;
  final List<JsonMap> shops;
}

abstract interface class CatalogRemoteDataSource {
  Future<Result<CatalogPayload>> fetchCatalog();
}

/// Talks to the optional mock server.
final class DioCatalogRemoteDataSource implements CatalogRemoteDataSource {
  DioCatalogRemoteDataSource(this._dio);
  final Dio _dio;

  @override
  Future<Result<CatalogPayload>> fetchCatalog() async {
    final responses = await Future.wait([
      _getList('/products'),
      _getList('/banners'),
      _getList('/sections'),
      _getList('/shops'),
    ]);
    for (final response in responses) {
      if (response case Err(:final failure)) return Result.err(failure);
    }
    final lists = responses.map((r) => r.valueOrNull!).toList();
    return Result.ok(
      CatalogPayload(
        products: lists[0],
        banners: lists[1],
        sections: lists[2],
        shops: lists[3],
      ),
    );
  }

  Future<Result<List<JsonMap>>> _getList(String path) async {
    try {
      final response = await _dio.get<Object?>(path);
      return unwrapEnvelope(response.data, jsonList);
    } on DioException catch (e) {
      return Result.err(_mapDioError(e));
    }
  }

  Failure _mapDioError(DioException e) => switch (e.type) {
        DioExceptionType.badResponse => ServerFailure(
            'HTTP ${e.response?.statusCode}',
            code: e.response?.statusCode?.toString(),
          ),
        _ => NetworkFailure(e.message ?? e.type.name),
      };
}
