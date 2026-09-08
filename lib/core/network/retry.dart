import 'dart:math';

import 'package:dio/dio.dart';

/// Retries idempotent requests (GET/HEAD/PUT/DELETE) and any request that failed
/// with 429 or 5xx / a transient transport error, with capped exponential
/// backoff + jitter. Non-idempotent POSTs are retried only when they carry an
/// `Idempotency-Key` (the server dedupes them).
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required Dio dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 400),
    this.maxDelay = const Duration(seconds: 8),
  }) : _dio = dio;

  final Dio _dio;
  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;

  static const _kAttempt = 'retry_attempt';
  final _rand = Random();

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra[_kAttempt] as int?) ?? 0;

    if (attempt >= maxRetries || !_shouldRetry(err)) {
      return handler.next(err);
    }

    final delay = _delayFor(attempt, err);
    await Future<void>.delayed(delay);

    final options = err.requestOptions;
    options.extra[_kAttempt] = attempt + 1;

    try {
      final response = await _dio.fetch<dynamic>(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.badResponse) {
      final status = err.response?.statusCode ?? 0;
      if (status != 429 && status < 500) return false;
      return _isRetriableMethod(err.requestOptions);
    }
    if (err.type == DioExceptionType.cancel ||
        err.type == DioExceptionType.badCertificate) {
      return false;
    }
    // connection error / any timeout / unknown transport hiccup
    final transient =
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown ||
        err.type.name.toLowerCase().contains('timeout');
    return transient && _isRetriableMethod(err.requestOptions);
  }

  bool _isRetriableMethod(RequestOptions o) {
    final method = o.method.toUpperCase();
    if (method == 'GET' ||
        method == 'HEAD' ||
        method == 'PUT' ||
        method == 'DELETE') {
      return true;
    }
    // POST only if the server can dedupe it.
    return o.headers.containsKey('Idempotency-Key');
  }

  Duration _delayFor(int attempt, DioException err) {
    // Honour Retry-After on 429.
    final retryAfter = err.response?.headers.value('retry-after');
    if (retryAfter != null) {
      final s = int.tryParse(retryAfter.trim());
      if (s != null) return Duration(seconds: s.clamp(0, maxDelay.inSeconds));
    }
    final exp = baseDelay.inMilliseconds * pow(2, attempt).toInt();
    final jitter = _rand.nextInt(baseDelay.inMilliseconds + 1);
    return Duration(milliseconds: min(exp + jitter, maxDelay.inMilliseconds));
  }
}
