import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_dto.freezed.dart';
part 'auth_dto.g.dart';

/// `POST /v1/auth/otp/request` → 200
@freezed
abstract class OtpChallengeDto with _$OtpChallengeDto {
  const factory OtpChallengeDto({
    @JsonKey(name: 'pending_token') required String pendingToken,
    @Default('sms') String method,
    @JsonKey(name: 'masked_target') String? maskedTarget,
    @JsonKey(name: 'expires_in') @Default(300) int expiresIn,
  }) = _OtpChallengeDto;

  factory OtpChallengeDto.fromJson(Map<String, dynamic> json) =>
      _$OtpChallengeDtoFromJson(json);
}

/// `POST /v1/auth/otp/verify` and `POST /v1/auth/refresh` → `{access, refresh}`
@freezed
abstract class TokenPairDto with _$TokenPairDto {
  const factory TokenPairDto({
    required String access,
    required String refresh,
  }) = _TokenPairDto;

  factory TokenPairDto.fromJson(Map<String, dynamic> json) =>
      _$TokenPairDtoFromJson(json);
}

/// `GET /v1/auth/sessions` entry
@freezed
abstract class SessionDto with _$SessionDto {
  const factory SessionDto({
    @JsonKey(name: 'session_id') required String sessionId,
    @JsonKey(name: 'device_name') String? deviceName,
    @JsonKey(name: 'ip_address') String? ipAddress,
    @JsonKey(name: 'login_at') DateTime? loginAt,
    @JsonKey(name: 'last_activity') DateTime? lastActivity,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'is_current') @Default(false) bool isCurrent,
  }) = _SessionDto;

  factory SessionDto.fromJson(Map<String, dynamic> json) =>
      _$SessionDtoFromJson(json);
}
