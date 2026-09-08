import 'package:injectable/injectable.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/error/result.dart';
import '../../../core/network/dio_factory.dart';
import '../dto/auth_dto.dart';
import 'api_client.dart';

/// Tier A — implemented today (`backend_design.md` §3.1).
@lazySingleton
class AuthApi {
  AuthApi(@Named(DioNames.cloud) this._client);
  final ApiClient _client;

  Future<Result<OtpChallengeDto>> requestOtp({
    required String phoneE164,
    String? deviceName,
  }) => _client.post<OtpChallengeDto>(
    ApiPaths.otpRequest,
    body: {'phone_e164': phoneE164, 'device_name': ?deviceName},
    skipAuth: true,
    parse: (d) => OtpChallengeDto.fromJson(ApiEnvelope.object(d)),
  );

  Future<Result<Unit>> resendOtp(String pendingToken) async {
    final r = await _client.post<Object?>(
      ApiPaths.otpResend,
      body: {'pending_token': pendingToken},
      skipAuth: true,
      parse: (d) => d,
    );
    return r.map((_) => Unit.value);
  }

  Future<Result<TokenPairDto>> verifyOtp({
    required String pendingToken,
    required String code,
    String? deviceName,
  }) => _client.post<TokenPairDto>(
    ApiPaths.otpVerify,
    body: {
      'pending_token': pendingToken,
      'code': code,
      'device_name': ?deviceName,
    },
    skipAuth: true,
    parse: (d) => TokenPairDto.fromJson(ApiEnvelope.object(d)),
  );

  Future<Result<TokenPairDto>> refresh(String refreshToken) =>
      _client.post<TokenPairDto>(
        ApiPaths.refresh,
        body: {'refresh': refreshToken},
        skipAuth: true,
        parse: (d) => TokenPairDto.fromJson(ApiEnvelope.object(d)),
      );

  Future<Result<Unit>> logout(String refreshToken) async {
    final r = await _client.post<Object?>(
      ApiPaths.logout,
      body: {'refresh': refreshToken},
      parse: (d) => d,
    );
    return r.map((_) => Unit.value);
  }

  Future<Result<List<SessionDto>>> sessions() => _client.get<List<SessionDto>>(
    ApiPaths.sessions,
    parse: (d) => ApiEnvelope.list(d).map(SessionDto.fromJson).toList(),
  );

  Future<Result<Unit>> revokeSession(String sessionId) =>
      _client.delete(ApiPaths.session(sessionId));

  Future<Result<int>> revokeAllSessions() => _client.post<int>(
    ApiPaths.sessionsRevokeAll,
    parse: (d) => (ApiEnvelope.object(d)['revoked'] as num?)?.toInt() ?? 0,
  );

  // --- Step-up (corekit two-call) --------------------------------------
  Future<Result<OtpChallengeDto>> stepUpInitiate() =>
      _client.post<OtpChallengeDto>(
        ApiPaths.stepUpInitiate,
        body: const {},
        parse: (d) => OtpChallengeDto.fromJson(ApiEnvelope.object(d)),
      );

  Future<Result<Unit>> stepUpVerify({
    required String pendingToken,
    required String code,
  }) async {
    final r = await _client.post<Object?>(
      ApiPaths.stepUpVerify,
      body: {'pending_token': pendingToken, 'code': code},
      parse: (d) => d,
    );
    return r.map((_) => Unit.value);
  }
}
