// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SiteDto _$SiteDtoFromJson(Map<String, dynamic> json) => _SiteDto(
  siteId: json['site_id'] as String,
  tenantId: json['tenant_id'] as String?,
  label: json['label'] as String,
  timezone: json['timezone'] as String? ?? 'Africa/Nairobi',
  meterType: json['meter_type'] as String,
  kplcAccountNo: json['kplc_account_no'] as String?,
  kplcMeterNo: json['kplc_meter_no'] as String?,
  supplyPhase: json['supply_phase'] as String? ?? 'single',
  occupantCount: (json['occupant_count'] as num?)?.toInt(),
  status: json['status'] as String? ?? 'active',
  staticIp: json['static_ip'] as String?,
  localApiPort: (json['local_api_port'] as num?)?.toInt() ?? 8443,
  allowLanCommands: json['allow_lan_commands'] as bool? ?? true,
  allowCloudCommands: json['allow_cloud_commands'] as bool? ?? true,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$SiteDtoToJson(_SiteDto instance) => <String, dynamic>{
  'site_id': instance.siteId,
  'tenant_id': instance.tenantId,
  'label': instance.label,
  'timezone': instance.timezone,
  'meter_type': instance.meterType,
  'kplc_account_no': instance.kplcAccountNo,
  'kplc_meter_no': instance.kplcMeterNo,
  'supply_phase': instance.supplyPhase,
  'occupant_count': instance.occupantCount,
  'status': instance.status,
  'static_ip': instance.staticIp,
  'local_api_port': instance.localApiPort,
  'allow_lan_commands': instance.allowLanCommands,
  'allow_cloud_commands': instance.allowCloudCommands,
  'created_at': instance.createdAt?.toIso8601String(),
};

_RoomDto _$RoomDtoFromJson(Map<String, dynamic> json) => _RoomDto(
  roomId: json['room_id'] as String,
  site: json['site'] as String?,
  name: json['name'] as String,
  roomType: json['room_type'] as String?,
);

Map<String, dynamic> _$RoomDtoToJson(_RoomDto instance) => <String, dynamic>{
  'room_id': instance.roomId,
  'site': instance.site,
  'name': instance.name,
  'room_type': instance.roomType,
};

_MemberDto _$MemberDtoFromJson(Map<String, dynamic> json) => _MemberDto(
  id: (json['id'] as num).toInt(),
  user: json['user'] as String,
  phoneE164: json['phone_e164'] as String?,
  displayName: json['display_name'] as String?,
  role: json['role'] as String,
  grantedBy: json['granted_by'] as String?,
  grantedAt: json['granted_at'] == null
      ? null
      : DateTime.parse(json['granted_at'] as String),
  revokedAt: json['revoked_at'] == null
      ? null
      : DateTime.parse(json['revoked_at'] as String),
);

Map<String, dynamic> _$MemberDtoToJson(_MemberDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'phone_e164': instance.phoneE164,
      'display_name': instance.displayName,
      'role': instance.role,
      'granted_by': instance.grantedBy,
      'granted_at': instance.grantedAt?.toIso8601String(),
      'revoked_at': instance.revokedAt?.toIso8601String(),
    };
