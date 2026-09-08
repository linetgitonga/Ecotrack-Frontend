import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:injectable/injectable.dart';

import '../../data/remote/api/api_client.dart';
import '../../data/remote/mock/mock_interceptor.dart';
import '../auth/token_store.dart';
import '../config/env_config.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import 'cert_pinning.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/connectivity_interceptor.dart';
import 'interceptors/idempotency_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'network_wiring.dart';
import 'retry.dart';

/// Named Dio instances; repositories take the one they need via DI.
abstract final class DioNames {
  static const cloud = 'cloud';
  static const lan = 'lan';
}

/// Builds the two transports (plan §2.3):
///   * **cloud** — `EnvConfig.apiBaseUrl`, full interceptor stack, JWT auth.
///   * **lan**   — base URL set at runtime from mDNS, pinned TLS, local bearer
///     token, no refresh interceptor.
@module
abstract class NetworkModule {
  @Named(DioNames.cloud)
  @lazySingleton
  Dio cloudDio(TokenStore tokenStore, NetworkWiring wiring) {
    final env = EnvConfig.instance;
    final dio = Dio(
      BaseOptions(
        baseUrl: env.apiBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {ApiHeaders.contentType: 'application/json'},
      ),
    );

    dio.interceptors.addAll([
      MockInterceptor(),
      ConnectivityInterceptor(wiring.hasConnection),
      AuthInterceptor(
        dio: dio,
        tokenStore: tokenStore,
        refresher: () => wiring.refresher,
        onSessionLost: () => wiring.onSessionLost?.call(),
      ),
      IdempotencyInterceptor(),
      RetryInterceptor(dio: dio),
      LoggingInterceptor(enabled: env.enableLogging),
    ]);

    return dio;
  }

  @Named(DioNames.lan)
  @lazySingleton
  Dio lanDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: AppConstants.lanProbeTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {ApiHeaders.contentType: 'application/json'},
      ),
    );
    dio.interceptors.addAll([
      IdempotencyInterceptor(),
      LoggingInterceptor(enabled: EnvConfig.instance.enableLogging),
    ]);
    return dio;
  }

  @Named(DioNames.cloud)
  @lazySingleton
  ApiClient cloudApiClient(@Named(DioNames.cloud) Dio dio) => ApiClient(dio);

  @Named(DioNames.lan)
  @lazySingleton
  ApiClient lanApiClient(@Named(DioNames.lan) Dio dio) => ApiClient(dio);
}

/// Points a LAN [Dio] at a discovered hub and pins its certificate. Called by
/// `ConnectionManager` when a LAN session is established.
void bindLanTransport(
  Dio lanDio, {
  required String baseUrl,
  required String? bearerToken,
  CertificatePinner? pinner,
}) {
  lanDio.options.baseUrl = baseUrl;
  if (bearerToken != null) {
    lanDio.options.headers[ApiHeaders.authorization] = 'Bearer $bearerToken';
  } else {
    lanDio.options.headers.remove(ApiHeaders.authorization);
  }
  final adapter = lanDio.httpClientAdapter;
  if (adapter is IOHttpClientAdapter) {
    adapter.createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = pinner?.allowBadCertificate;
      return client;
    };
  }
}
