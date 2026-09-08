import 'dart:math';

import 'package:dio/dio.dart';

import '../../../core/config/env_config.dart';
import 'fixtures.dart';

/// Serves canned Tier-B responses (System_Design §8 shapes) when the real
/// endpoint isn't deployed yet.
///
///   * `EnvConfig.mockMode == true`  → always mock Tier-B paths.
///   * otherwise                      → only mock after the real call 404s
///     (handled in [onError]).
///
/// Tier-A paths are never mocked.
class MockInterceptor extends Interceptor {
  MockInterceptor({Random? random}) : _rng = random ?? Random();
  final Random _rng;

  bool get _alwaysMock => EnvConfig.instance.mockMode;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_alwaysMock && MockFixtures.handles(options)) {
      final response = MockFixtures.respond(options, _rng);
      if (response != null) {
        return handler.resolve(
          Response(
            requestOptions: options,
            statusCode: response.$1,
            data: response.$2,
          ),
        );
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final is404or501 =
        err.response?.statusCode == 404 ||
        err.response?.statusCode == 501 ||
        err.type == DioExceptionType.connectionError;
    if (is404or501 && MockFixtures.handles(err.requestOptions)) {
      final response = MockFixtures.respond(err.requestOptions, _rng);
      if (response != null) {
        return handler.resolve(
          Response(
            requestOptions: err.requestOptions,
            statusCode: response.$1,
            data: response.$2,
          ),
        );
      }
    }
    handler.next(err);
  }
}
