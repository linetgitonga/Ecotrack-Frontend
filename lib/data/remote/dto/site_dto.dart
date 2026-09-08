import 'package:freezed_annotation/freezed_annotation.dart';

part 'site_dto.freezed.dart';
part 'site_dto.g.dart';

/// `GET/POST /v1/sites`, `GET/PATCH /v1/sites/{id}` (backend_design.md §3.3).
@freezed
abstract class SiteDto with _$SiteDto {
  const factory SiteDto({
    @JsonKey(name: 'site_id') required String siteId,
    @JsonKey(name: 'tenant_id') String? tenantId,
    required String label,
    @Default('Africa/Nairobi') String timezone,
    @JsonKey(name: 'meter_type') required String meterType,
    @JsonKey(name: 'kplc_account_no') String? kplcAccountNo,
    @JsonKey(name: 'kplc_meter_no') String? kplcMeterNo,
    @JsonKey(name: 'supply_phase') @Default('single') String supplyPhase,
    @JsonKey(name: 'occupant_count') int? occupantCount,
    @Default('active') String status,
    @JsonKey(name: 'static_ip') String? staticIp,
    @JsonKey(name: 'local_api_port') @Default(8443) int localApiPort,
    @JsonKey(name: 'allow_lan_commands') @Default(true) bool allowLanCommands,
    @JsonKey(name: 'allow_cloud_commands')
    @Default(true)
    bool allowCloudCommands,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _SiteDto;

  factory SiteDto.fromJson(Map<String, dynamic> json) =>
      _$SiteDtoFromJson(json);
}

@freezed
abstract class RoomDto with _$RoomDto {
  const factory RoomDto({
    @JsonKey(name: 'room_id') required String roomId,
    String? site,
    required String name,
    @JsonKey(name: 'room_type') String? roomType,
  }) = _RoomDto;

  factory RoomDto.fromJson(Map<String, dynamic> json) =>
      _$RoomDtoFromJson(json);
}

/// `GET/POST /v1/sites/{id}/members` (backend_design.md §3.5).
@freezed
abstract class MemberDto with _$MemberDto {
  const factory MemberDto({
    required int id,
    required String user,
    @JsonKey(name: 'phone_e164') String? phoneE164,
    @JsonKey(name: 'display_name') String? displayName,
    required String role,
    @JsonKey(name: 'granted_by') String? grantedBy,
    @JsonKey(name: 'granted_at') DateTime? grantedAt,
    @JsonKey(name: 'revoked_at') DateTime? revokedAt,
  }) = _MemberDto;

  factory MemberDto.fromJson(Map<String, dynamic> json) =>
      _$MemberDtoFromJson(json);
}
