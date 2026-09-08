// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OtpChallengeDto _$OtpChallengeDtoFromJson(Map<String, dynamic> json) =>
    _OtpChallengeDto(
      pendingToken: json['pending_token'] as String,
      method: json['method'] as String? ?? 'sms',
      maskedTarget: json['masked_target'] as String?,
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 300,
    );

Map<String, dynamic> _$OtpChallengeDtoToJson(_OtpChallengeDto instance) =>
    <String, dynamic>{
      'pending_token': instance.pendingToken,
      'method': instance.method,
      'masked_target': instance.maskedTarget,
      'expires_in': instance.expiresIn,
    };

_TokenPairDto _$TokenPairDtoFromJson(Map<String, dynamic> json) =>
    _TokenPairDto(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
    );

Map<String, dynamic> _$TokenPairDtoToJson(_TokenPairDto instance) =>
    <String, dynamic>{'access': instance.access, 'refresh': instance.refresh};

_SessionDto _$SessionDtoFromJson(Map<String, dynamic> json) => _SessionDto(
  sessionId: json['session_id'] as String,
  deviceName: json['device_name'] as String?,
  ipAddress: json['ip_address'] as String?,
  loginAt: json['login_at'] == null
      ? null
      : DateTime.parse(json['login_at'] as String),
  lastActivity: json['last_activity'] == null
      ? null
      : DateTime.parse(json['last_activity'] as String),
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
  isCurrent: json['is_current'] as bool? ?? false,
);

Map<String, dynamic> _$SessionDtoToJson(_SessionDto instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'device_name': instance.deviceName,
      'ip_address': instance.ipAddress,
      'login_at': instance.loginAt?.toIso8601String(),
      'last_activity': instance.lastActivity?.toIso8601String(),
      'expires_at': instance.expiresAt?.toIso8601String(),
      'is_current': instance.isCurrent,
    };
