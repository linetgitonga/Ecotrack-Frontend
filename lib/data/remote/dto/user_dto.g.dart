// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserDto _$UserDtoFromJson(Map<String, dynamic> json) => _UserDto(
  id: json['id'] as String,
  tenant: json['tenant'] as String,
  phoneE164: json['phone_e164'] as String,
  email: json['email'] as String?,
  displayName: json['display_name'] as String?,
  role: json['role'] as String,
  locale: json['locale'] as String? ?? 'en-KE',
  status: json['status'] as String? ?? 'active',
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  lastLoginAt: json['last_login_at'] == null
      ? null
      : DateTime.parse(json['last_login_at'] as String),
);

Map<String, dynamic> _$UserDtoToJson(_UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'tenant': instance.tenant,
  'phone_e164': instance.phoneE164,
  'email': instance.email,
  'display_name': instance.displayName,
  'role': instance.role,
  'locale': instance.locale,
  'status': instance.status,
  'created_at': instance.createdAt?.toIso8601String(),
  'last_login_at': instance.lastLoginAt?.toIso8601String(),
};

_PreferencesDto _$PreferencesDtoFromJson(Map<String, dynamic> json) =>
    _PreferencesDto(
      currency: json['currency'] as String? ?? 'KES',
      unitsDisplay: json['units_display'] as String? ?? 'kwh_and_kes',
      defaultSiteId: json['default_site_id'] as String?,
      quietHoursStart: json['quiet_hours_start'] as String?,
      quietHoursEnd: json['quiet_hours_end'] as String?,
      channels:
          json['channels'] as Map<String, dynamic>? ??
          const {'push': true, 'sms': false, 'email': false},
      notifyMinSeverity: json['notify_min_severity'] as String? ?? 'warning',
      dataSaver: json['data_saver'] as bool? ?? false,
    );

Map<String, dynamic> _$PreferencesDtoToJson(_PreferencesDto instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'units_display': instance.unitsDisplay,
      'default_site_id': instance.defaultSiteId,
      'quiet_hours_start': instance.quietHoursStart,
      'quiet_hours_end': instance.quietHoursEnd,
      'channels': instance.channels,
      'notify_min_severity': instance.notifyMinSeverity,
      'data_saver': instance.dataSaver,
    };
