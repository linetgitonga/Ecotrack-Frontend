import 'package:dio/dio.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/network/error_mapper.dart';
import '../../../core/network/interceptors/auth_interceptor.dart';
import '../../../core/network/interceptors/idempotency_interceptor.dart';

/// Thin wrapper over a [Dio] instance that returns [Result] instead of throwing,
/// mapping every failure through [ErrorMapper]. One instance per transport
/// (cloud / LAN); API classes take the one they need.
class ApiClient {
  ApiClient(this._dio);
  final Dio _dio;

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    T Function(Object? data)? parse,
  }) => _run(() => _dio.get<Object?>(path, queryParameters: query), parse);

  Future<Result<T>> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    String? idempotencyKey,
    bool skipAuth = false,
    T Function(Object? data)? parse,
  }) => _run(
    () => _dio.post<Object?>(
      path,
      data: body,
      queryParameters: query,
      options: _options(idempotencyKey: idempotencyKey, skipAuth: skipAuth),
    ),
    parse,
  );

  Future<Result<T>> patch<T>(
    String path, {
    Object? body,
    T Function(Object? data)? parse,
  }) => _run(() => _dio.patch<Object?>(path, data: body), parse);

  Future<Result<T>> put<T>(
    String path, {
    Object? body,
    T Function(Object? data)? parse,
  }) => _run(() => _dio.put<Object?>(path, data: body), parse);

  Future<Result<Unit>> delete(String path, {Object? body}) async {
    final r = await _run<Object?>(
      () => _dio.delete<Object?>(path, data: body),
      (d) => d,
    );
    return r.map((_) => Unit.value);
  }

  Options _options({String? idempotencyKey, bool skipAuth = false}) {
    final extra = <String, dynamic>{};
    if (idempotencyKey != null) {
      extra[IdempotencyInterceptor.kExtraKey] = idempotencyKey;
    }
    if (skipAuth) extra[AuthInterceptor.kSkipAuth] = true;
    return Options(extra: extra);
  }

  Future<Result<T>> _run<T>(
    Future<Response<Object?>> Function() call,
    T Function(Object? data)? parse,
  ) async {
    try {
      final response = await call();
      final data = response.data;
      if (parse != null) return Result.ok(parse(data));
      return Result.ok(data as T);
    } on DioException catch (e) {
      return Err<T>(ErrorMapper.fromDio(e));
    } catch (e, st) {
      return Err<T>(UnknownFailure(cause: e, message: '$e\n$st'));
    }
  }
}

/// Response-envelope helpers. Tier A list endpoints return a **bare array**;
/// `/audit-log` returns `{next, previous, results}` (backend_design.md §3).
abstract final class ApiEnvelope {
  static List<Map<String, dynamic>> list(Object? data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data['results'] is List) {
      return (data['results'] as List).cast<Map<String, dynamic>>();
    }
    return const [];
  }

  static ({List<Map<String, dynamic>> items, String? nextCursor}) paged(
    Object? data,
  ) {
    if (data is Map && data['results'] is List) {
      return (
        items: (data['results'] as List).cast<Map<String, dynamic>>(),
        nextCursor: data['next']?.toString(),
      );
    }
    return (items: list(data), nextCursor: null);
  }

  static Map<String, dynamic> object(Object? data) =>
      data is Map ? data.cast<String, dynamic>() : const {};
}
