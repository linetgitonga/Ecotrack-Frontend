import 'package:dio/dio.dart';

import '../../auth/token_store.dart';
import '../../constants/api_endpoints.dart';

/// Refreshes the access token. Implemented by `SessionManager` (Phase 3); the
/// interceptor holds only this narrow contract so it can be wired now.
abstract interface class TokenRefresher {
  /// Returns the new access token, or null if refresh failed (→ force logout).
  Future<String?> refresh();
}

/// Attaches `Authorization: Bearer <access>` and, on a 401, performs a
/// single-flight refresh then replays the request once.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required TokenStore tokenStore,
    required TokenRefresher Function() refresher,
    this.onSessionLost,
  }) : _dio = dio,
       _tokens = tokenStore,
       _refresher = refresher;

  final Dio _dio;
  final TokenStore _tokens;
  final TokenRefresher Function() _refresher;
  final void Function()? onSessionLost;

  static const _kRetried = 'auth_retried';

  /// Request `extra` flag: when true the interceptor adds no header and does not
  /// attempt a refresh (login / refresh / logout calls set this).
  static const kSkipAuth = 'skip_auth';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[kSkipAuth] == true) return handler.next(options);

    // If a refresh is mid-flight, wait for it before reading the token.
    if (_tokens.isRefreshing) await _tokens.awaitRefresh();

    final token = _tokens.accessToken;
    if (token != null) {
      options.headers[ApiHeaders.authorization] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final is401 = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra[_kRetried] == true;
    final skipAuth = err.requestOptions.extra[kSkipAuth] == true;

    if (!is401 || alreadyRetried || skipAuth) return handler.next(err);

    final newToken = await _obtainFreshToken();
    if (newToken == null) {
      onSessionLost?.call();
      return handler.next(err);
    }

    final options = err.requestOptions
      ..extra[_kRetried] = true
      ..headers[ApiHeaders.authorization] = 'Bearer $newToken';

    try {
      return handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  /// Single-flight: only one request drives the refresh; the rest await it.
  Future<String?> _obtainFreshToken() async {
    if (_tokens.beginRefresh()) {
      try {
        return await _refresher().refresh();
      } finally {
        _tokens.endRefresh();
      }
    }
    await _tokens.awaitRefresh();
    return _tokens.accessToken;
  }
}

/// Marks a request so [AuthInterceptor] leaves it alone (login, refresh, etc.).
extension NoAuth on RequestOptions {
  void skipAuth() => extra['skip_auth'] = true;
}
