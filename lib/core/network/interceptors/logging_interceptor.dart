import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Dev-only request/response logging with secrets redacted. Disabled entirely in
/// release builds and when `enableLogging` is false (see `EnvConfig`).
///
/// Mirrors `data_classification.mask_in_logs`: phone numbers, OTP codes, tokens
/// and the Authorization header never reach the console.
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({required this.enabled});
  final bool enabled;

  bool get _active => enabled && kDebugMode;

  static final _sensitiveKeys = {
    'authorization',
    'idempotency-key',
    'phone_e164',
    'code',
    'access',
    'refresh',
    'pending_token',
    'password',
    'token',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_active) {
      debugPrint(
        '→ ${options.method} ${options.uri.path}'
        '${_redactedBody(options.data)}',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (_active) {
      debugPrint(
        '← ${response.statusCode} ${response.requestOptions.uri.path}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_active) {
      debugPrint(
        '✗ ${err.response?.statusCode ?? err.type.name} '
        '${err.requestOptions.uri.path}',
      );
    }
    handler.next(err);
  }

  String _redactedBody(Object? data) {
    if (data is! Map) return '';
    final redacted = <String, Object?>{};
    data.forEach((k, v) {
      redacted[k.toString()] =
          _sensitiveKeys.contains(k.toString().toLowerCase()) ? '***' : v;
    });
    return ' $redacted';
  }
}
