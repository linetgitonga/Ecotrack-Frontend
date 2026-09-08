import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

/// `GET /v1/me` (and the body returned by `PATCH /v1/me`).
@freezed
abstract class UserDto with _$UserDto {
  const factory UserDto({
    required String id,
    required String tenant,
    @JsonKey(name: 'phone_e164') required String phoneE164,
    String? email,
    @JsonKey(name: 'display_name') String? displayName,
    required String role,
    @Default('en-KE') String locale,
    @Default('active') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'last_login_at') DateTime? lastLoginAt,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}

/// `PUT /v1/me/preferences` body / `GET` response (Tier B).
@freezed
abstract class PreferencesDto with _$PreferencesDto {
  const factory PreferencesDto({
    @Default('KES') String currency,
    @JsonKey(name: 'units_display') @Default('kwh_and_kes') String unitsDisplay,
    @JsonKey(name: 'default_site_id') String? defaultSiteId,
    @JsonKey(name: 'quiet_hours_start') String? quietHoursStart,
    @JsonKey(name: 'quiet_hours_end') String? quietHoursEnd,
    @Default({'push': true, 'sms': false, 'email': false})
    Map<String, dynamic> channels,
    @JsonKey(name: 'notify_min_severity')
    @Default('warning')
    String notifyMinSeverity,
    @JsonKey(name: 'data_saver') @Default(false) bool dataSaver,
  }) = _PreferencesDto;

  factory PreferencesDto.fromJson(Map<String, dynamic> json) =>
      _$PreferencesDtoFromJson(json);
}
