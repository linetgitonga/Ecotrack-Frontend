import 'package:dio/dio.dart';

/// Short-circuits a request when the device has no network at all, so callers
/// get a fast, typed offline signal instead of a socket timeout. `ErrorMapper`
/// turns the resulting `connectionError` into a `NetworkFailure`, which
/// repositories present as `OfflineFailure` when the connection state is offline.
class ConnectivityInterceptor extends Interceptor {
  ConnectivityInterceptor(this._hasConnection);

  /// Backed by `connectivity_plus`' last known value.
  final Future<bool> Function() _hasConnection;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (await _hasConnection()) return handler.next(options);
    handler.reject(
      DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        message: 'No network connectivity',
      ),
      true,
    );
  }
}
