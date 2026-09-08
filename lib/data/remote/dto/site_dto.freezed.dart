// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'site_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SiteDto {

@JsonKey(name: 'site_id') String get siteId;@JsonKey(name: 'tenant_id') String? get tenantId; String get label; String get timezone;@JsonKey(name: 'meter_type') String get meterType;@JsonKey(name: 'kplc_account_no') String? get kplcAccountNo;@JsonKey(name: 'kplc_meter_no') String? get kplcMeterNo;@JsonKey(name: 'supply_phase') String get supplyPhase;@JsonKey(name: 'occupant_count') int? get occupantCount; String get status;@JsonKey(name: 'static_ip') String? get staticIp;@JsonKey(name: 'local_api_port') int get localApiPort;@JsonKey(name: 'allow_lan_commands') bool get allowLanCommands;@JsonKey(name: 'allow_cloud_commands') bool get allowCloudCommands;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of SiteDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SiteDtoCopyWith<SiteDto> get copyWith => _$SiteDtoCopyWithImpl<SiteDto>(this as SiteDto, _$identity);

  /// Serializes this SiteDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SiteDto&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.label, label) || other.label == label)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.meterType, meterType) || other.meterType == meterType)&&(identical(other.kplcAccountNo, kplcAccountNo) || other.kplcAccountNo == kplcAccountNo)&&(identical(other.kplcMeterNo, kplcMeterNo) || other.kplcMeterNo == kplcMeterNo)&&(identical(other.supplyPhase, supplyPhase) || other.supplyPhase == supplyPhase)&&(identical(other.occupantCount, occupantCount) || other.occupantCount == occupantCount)&&(identical(other.status, status) || other.status == status)&&(identical(other.staticIp, staticIp) || other.staticIp == staticIp)&&(identical(other.localApiPort, localApiPort) || other.localApiPort == localApiPort)&&(identical(other.allowLanCommands, allowLanCommands) || other.allowLanCommands == allowLanCommands)&&(identical(other.allowCloudCommands, allowCloudCommands) || other.allowCloudCommands == allowCloudCommands)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,siteId,tenantId,label,timezone,meterType,kplcAccountNo,kplcMeterNo,supplyPhase,occupantCount,status,staticIp,localApiPort,allowLanCommands,allowCloudCommands,createdAt);

@override
String toString() {
  return 'SiteDto(siteId: $siteId, tenantId: $tenantId, label: $label, timezone: $timezone, meterType: $meterType, kplcAccountNo: $kplcAccountNo, kplcMeterNo: $kplcMeterNo, supplyPhase: $supplyPhase, occupantCount: $occupantCount, status: $status, staticIp: $staticIp, localApiPort: $localApiPort, allowLanCommands: $allowLanCommands, allowCloudCommands: $allowCloudCommands, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SiteDtoCopyWith<$Res>  {
  factory $SiteDtoCopyWith(SiteDto value, $Res Function(SiteDto) _then) = _$SiteDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'site_id') String siteId,@JsonKey(name: 'tenant_id') String? tenantId, String label, String timezone,@JsonKey(name: 'meter_type') String meterType,@JsonKey(name: 'kplc_account_no') String? kplcAccountNo,@JsonKey(name: 'kplc_meter_no') String? kplcMeterNo,@JsonKey(name: 'supply_phase') String supplyPhase,@JsonKey(name: 'occupant_count') int? occupantCount, String status,@JsonKey(name: 'static_ip') String? staticIp,@JsonKey(name: 'local_api_port') int localApiPort,@JsonKey(name: 'allow_lan_commands') bool allowLanCommands,@JsonKey(name: 'allow_cloud_commands') bool allowCloudCommands,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$SiteDtoCopyWithImpl<$Res>
    implements $SiteDtoCopyWith<$Res> {
  _$SiteDtoCopyWithImpl(this._self, this._then);

  final SiteDto _self;
  final $Res Function(SiteDto) _then;

/// Create a copy of SiteDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? siteId = null,Object? tenantId = freezed,Object? label = null,Object? timezone = null,Object? meterType = null,Object? kplcAccountNo = freezed,Object? kplcMeterNo = freezed,Object? supplyPhase = null,Object? occupantCount = freezed,Object? status = null,Object? staticIp = freezed,Object? localApiPort = null,Object? allowLanCommands = null,Object? allowCloudCommands = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,tenantId: freezed == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String?,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,meterType: null == meterType ? _self.meterType : meterType // ignore: cast_nullable_to_non_nullable
as String,kplcAccountNo: freezed == kplcAccountNo ? _self.kplcAccountNo : kplcAccountNo // ignore: cast_nullable_to_non_nullable
as String?,kplcMeterNo: freezed == kplcMeterNo ? _self.kplcMeterNo : kplcMeterNo // ignore: cast_nullable_to_non_nullable
as String?,supplyPhase: null == supplyPhase ? _self.supplyPhase : supplyPhase // ignore: cast_nullable_to_non_nullable
as String,occupantCount: freezed == occupantCount ? _self.occupantCount : occupantCount // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,staticIp: freezed == staticIp ? _self.staticIp : staticIp // ignore: cast_nullable_to_non_nullable
as String?,localApiPort: null == localApiPort ? _self.localApiPort : localApiPort // ignore: cast_nullable_to_non_nullable
as int,allowLanCommands: null == allowLanCommands ? _self.allowLanCommands : allowLanCommands // ignore: cast_nullable_to_non_nullable
as bool,allowCloudCommands: null == allowCloudCommands ? _self.allowCloudCommands : allowCloudCommands // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SiteDto].
extension SiteDtoPatterns on SiteDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SiteDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SiteDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SiteDto value)  $default,){
final _that = this;
switch (_that) {
case _SiteDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SiteDto value)?  $default,){
final _that = this;
switch (_that) {
case _SiteDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'site_id')  String siteId, @JsonKey(name: 'tenant_id')  String? tenantId,  String label,  String timezone, @JsonKey(name: 'meter_type')  String meterType, @JsonKey(name: 'kplc_account_no')  String? kplcAccountNo, @JsonKey(name: 'kplc_meter_no')  String? kplcMeterNo, @JsonKey(name: 'supply_phase')  String supplyPhase, @JsonKey(name: 'occupant_count')  int? occupantCount,  String status, @JsonKey(name: 'static_ip')  String? staticIp, @JsonKey(name: 'local_api_port')  int localApiPort, @JsonKey(name: 'allow_lan_commands')  bool allowLanCommands, @JsonKey(name: 'allow_cloud_commands')  bool allowCloudCommands, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SiteDto() when $default != null:
return $default(_that.siteId,_that.tenantId,_that.label,_that.timezone,_that.meterType,_that.kplcAccountNo,_that.kplcMeterNo,_that.supplyPhase,_that.occupantCount,_that.status,_that.staticIp,_that.localApiPort,_that.allowLanCommands,_that.allowCloudCommands,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'site_id')  String siteId, @JsonKey(name: 'tenant_id')  String? tenantId,  String label,  String timezone, @JsonKey(name: 'meter_type')  String meterType, @JsonKey(name: 'kplc_account_no')  String? kplcAccountNo, @JsonKey(name: 'kplc_meter_no')  String? kplcMeterNo, @JsonKey(name: 'supply_phase')  String supplyPhase, @JsonKey(name: 'occupant_count')  int? occupantCount,  String status, @JsonKey(name: 'static_ip')  String? staticIp, @JsonKey(name: 'local_api_port')  int localApiPort, @JsonKey(name: 'allow_lan_commands')  bool allowLanCommands, @JsonKey(name: 'allow_cloud_commands')  bool allowCloudCommands, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _SiteDto():
return $default(_that.siteId,_that.tenantId,_that.label,_that.timezone,_that.meterType,_that.kplcAccountNo,_that.kplcMeterNo,_that.supplyPhase,_that.occupantCount,_that.status,_that.staticIp,_that.localApiPort,_that.allowLanCommands,_that.allowCloudCommands,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'site_id')  String siteId, @JsonKey(name: 'tenant_id')  String? tenantId,  String label,  String timezone, @JsonKey(name: 'meter_type')  String meterType, @JsonKey(name: 'kplc_account_no')  String? kplcAccountNo, @JsonKey(name: 'kplc_meter_no')  String? kplcMeterNo, @JsonKey(name: 'supply_phase')  String supplyPhase, @JsonKey(name: 'occupant_count')  int? occupantCount,  String status, @JsonKey(name: 'static_ip')  String? staticIp, @JsonKey(name: 'local_api_port')  int localApiPort, @JsonKey(name: 'allow_lan_commands')  bool allowLanCommands, @JsonKey(name: 'allow_cloud_commands')  bool allowCloudCommands, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SiteDto() when $default != null:
return $default(_that.siteId,_that.tenantId,_that.label,_that.timezone,_that.meterType,_that.kplcAccountNo,_that.kplcMeterNo,_that.supplyPhase,_that.occupantCount,_that.status,_that.staticIp,_that.localApiPort,_that.allowLanCommands,_that.allowCloudCommands,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SiteDto implements SiteDto {
  const _SiteDto({@JsonKey(name: 'site_id') required this.siteId, @JsonKey(name: 'tenant_id') this.tenantId, required this.label, this.timezone = 'Africa/Nairobi', @JsonKey(name: 'meter_type') required this.meterType, @JsonKey(name: 'kplc_account_no') this.kplcAccountNo, @JsonKey(name: 'kplc_meter_no') this.kplcMeterNo, @JsonKey(name: 'supply_phase') this.supplyPhase = 'single', @JsonKey(name: 'occupant_count') this.occupantCount, this.status = 'active', @JsonKey(name: 'static_ip') this.staticIp, @JsonKey(name: 'local_api_port') this.localApiPort = 8443, @JsonKey(name: 'allow_lan_commands') this.allowLanCommands = true, @JsonKey(name: 'allow_cloud_commands') this.allowCloudCommands = true, @JsonKey(name: 'created_at') this.createdAt});
  factory _SiteDto.fromJson(Map<String, dynamic> json) => _$SiteDtoFromJson(json);

@override@JsonKey(name: 'site_id') final  String siteId;
@override@JsonKey(name: 'tenant_id') final  String? tenantId;
@override final  String label;
@override@JsonKey() final  String timezone;
@override@JsonKey(name: 'meter_type') final  String meterType;
@override@JsonKey(name: 'kplc_account_no') final  String? kplcAccountNo;
@override@JsonKey(name: 'kplc_meter_no') final  String? kplcMeterNo;
@override@JsonKey(name: 'supply_phase') final  String supplyPhase;
@override@JsonKey(name: 'occupant_count') final  int? occupantCount;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'static_ip') final  String? staticIp;
@override@JsonKey(name: 'local_api_port') final  int localApiPort;
@override@JsonKey(name: 'allow_lan_commands') final  bool allowLanCommands;
@override@JsonKey(name: 'allow_cloud_commands') final  bool allowCloudCommands;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of SiteDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SiteDtoCopyWith<_SiteDto> get copyWith => __$SiteDtoCopyWithImpl<_SiteDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SiteDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SiteDto&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.label, label) || other.label == label)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.meterType, meterType) || other.meterType == meterType)&&(identical(other.kplcAccountNo, kplcAccountNo) || other.kplcAccountNo == kplcAccountNo)&&(identical(other.kplcMeterNo, kplcMeterNo) || other.kplcMeterNo == kplcMeterNo)&&(identical(other.supplyPhase, supplyPhase) || other.supplyPhase == supplyPhase)&&(identical(other.occupantCount, occupantCount) || other.occupantCount == occupantCount)&&(identical(other.status, status) || other.status == status)&&(identical(other.staticIp, staticIp) || other.staticIp == staticIp)&&(identical(other.localApiPort, localApiPort) || other.localApiPort == localApiPort)&&(identical(other.allowLanCommands, allowLanCommands) || other.allowLanCommands == allowLanCommands)&&(identical(other.allowCloudCommands, allowCloudCommands) || other.allowCloudCommands == allowCloudCommands)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,siteId,tenantId,label,timezone,meterType,kplcAccountNo,kplcMeterNo,supplyPhase,occupantCount,status,staticIp,localApiPort,allowLanCommands,allowCloudCommands,createdAt);

@override
String toString() {
  return 'SiteDto(siteId: $siteId, tenantId: $tenantId, label: $label, timezone: $timezone, meterType: $meterType, kplcAccountNo: $kplcAccountNo, kplcMeterNo: $kplcMeterNo, supplyPhase: $supplyPhase, occupantCount: $occupantCount, status: $status, staticIp: $staticIp, localApiPort: $localApiPort, allowLanCommands: $allowLanCommands, allowCloudCommands: $allowCloudCommands, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SiteDtoCopyWith<$Res> implements $SiteDtoCopyWith<$Res> {
  factory _$SiteDtoCopyWith(_SiteDto value, $Res Function(_SiteDto) _then) = __$SiteDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'site_id') String siteId,@JsonKey(name: 'tenant_id') String? tenantId, String label, String timezone,@JsonKey(name: 'meter_type') String meterType,@JsonKey(name: 'kplc_account_no') String? kplcAccountNo,@JsonKey(name: 'kplc_meter_no') String? kplcMeterNo,@JsonKey(name: 'supply_phase') String supplyPhase,@JsonKey(name: 'occupant_count') int? occupantCount, String status,@JsonKey(name: 'static_ip') String? staticIp,@JsonKey(name: 'local_api_port') int localApiPort,@JsonKey(name: 'allow_lan_commands') bool allowLanCommands,@JsonKey(name: 'allow_cloud_commands') bool allowCloudCommands,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$SiteDtoCopyWithImpl<$Res>
    implements _$SiteDtoCopyWith<$Res> {
  __$SiteDtoCopyWithImpl(this._self, this._then);

  final _SiteDto _self;
  final $Res Function(_SiteDto) _then;

/// Create a copy of SiteDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? siteId = null,Object? tenantId = freezed,Object? label = null,Object? timezone = null,Object? meterType = null,Object? kplcAccountNo = freezed,Object? kplcMeterNo = freezed,Object? supplyPhase = null,Object? occupantCount = freezed,Object? status = null,Object? staticIp = freezed,Object? localApiPort = null,Object? allowLanCommands = null,Object? allowCloudCommands = null,Object? createdAt = freezed,}) {
  return _then(_SiteDto(
siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,tenantId: freezed == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String?,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,meterType: null == meterType ? _self.meterType : meterType // ignore: cast_nullable_to_non_nullable
as String,kplcAccountNo: freezed == kplcAccountNo ? _self.kplcAccountNo : kplcAccountNo // ignore: cast_nullable_to_non_nullable
as String?,kplcMeterNo: freezed == kplcMeterNo ? _self.kplcMeterNo : kplcMeterNo // ignore: cast_nullable_to_non_nullable
as String?,supplyPhase: null == supplyPhase ? _self.supplyPhase : supplyPhase // ignore: cast_nullable_to_non_nullable
as String,occupantCount: freezed == occupantCount ? _self.occupantCount : occupantCount // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,staticIp: freezed == staticIp ? _self.staticIp : staticIp // ignore: cast_nullable_to_non_nullable
as String?,localApiPort: null == localApiPort ? _self.localApiPort : localApiPort // ignore: cast_nullable_to_non_nullable
as int,allowLanCommands: null == allowLanCommands ? _self.allowLanCommands : allowLanCommands // ignore: cast_nullable_to_non_nullable
as bool,allowCloudCommands: null == allowCloudCommands ? _self.allowCloudCommands : allowCloudCommands // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$RoomDto {

@JsonKey(name: 'room_id') String get roomId; String? get site; String get name;@JsonKey(name: 'room_type') String? get roomType;
/// Create a copy of RoomDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomDtoCopyWith<RoomDto> get copyWith => _$RoomDtoCopyWithImpl<RoomDto>(this as RoomDto, _$identity);

  /// Serializes this RoomDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoomDto&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.site, site) || other.site == site)&&(identical(other.name, name) || other.name == name)&&(identical(other.roomType, roomType) || other.roomType == roomType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,roomId,site,name,roomType);

@override
String toString() {
  return 'RoomDto(roomId: $roomId, site: $site, name: $name, roomType: $roomType)';
}


}

/// @nodoc
abstract mixin class $RoomDtoCopyWith<$Res>  {
  factory $RoomDtoCopyWith(RoomDto value, $Res Function(RoomDto) _then) = _$RoomDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'room_id') String roomId, String? site, String name,@JsonKey(name: 'room_type') String? roomType
});




}
/// @nodoc
class _$RoomDtoCopyWithImpl<$Res>
    implements $RoomDtoCopyWith<$Res> {
  _$RoomDtoCopyWithImpl(this._self, this._then);

  final RoomDto _self;
  final $Res Function(RoomDto) _then;

/// Create a copy of RoomDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? roomId = null,Object? site = freezed,Object? name = null,Object? roomType = freezed,}) {
  return _then(_self.copyWith(
roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,site: freezed == site ? _self.site : site // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,roomType: freezed == roomType ? _self.roomType : roomType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RoomDto].
extension RoomDtoPatterns on RoomDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoomDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoomDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoomDto value)  $default,){
final _that = this;
switch (_that) {
case _RoomDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoomDto value)?  $default,){
final _that = this;
switch (_that) {
case _RoomDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'room_id')  String roomId,  String? site,  String name, @JsonKey(name: 'room_type')  String? roomType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoomDto() when $default != null:
return $default(_that.roomId,_that.site,_that.name,_that.roomType);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'room_id')  String roomId,  String? site,  String name, @JsonKey(name: 'room_type')  String? roomType)  $default,) {final _that = this;
switch (_that) {
case _RoomDto():
return $default(_that.roomId,_that.site,_that.name,_that.roomType);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'room_id')  String roomId,  String? site,  String name, @JsonKey(name: 'room_type')  String? roomType)?  $default,) {final _that = this;
switch (_that) {
case _RoomDto() when $default != null:
return $default(_that.roomId,_that.site,_that.name,_that.roomType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoomDto implements RoomDto {
  const _RoomDto({@JsonKey(name: 'room_id') required this.roomId, this.site, required this.name, @JsonKey(name: 'room_type') this.roomType});
  factory _RoomDto.fromJson(Map<String, dynamic> json) => _$RoomDtoFromJson(json);

@override@JsonKey(name: 'room_id') final  String roomId;
@override final  String? site;
@override final  String name;
@override@JsonKey(name: 'room_type') final  String? roomType;

/// Create a copy of RoomDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoomDtoCopyWith<_RoomDto> get copyWith => __$RoomDtoCopyWithImpl<_RoomDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoomDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoomDto&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.site, site) || other.site == site)&&(identical(other.name, name) || other.name == name)&&(identical(other.roomType, roomType) || other.roomType == roomType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,roomId,site,name,roomType);

@override
String toString() {
  return 'RoomDto(roomId: $roomId, site: $site, name: $name, roomType: $roomType)';
}


}

/// @nodoc
abstract mixin class _$RoomDtoCopyWith<$Res> implements $RoomDtoCopyWith<$Res> {
  factory _$RoomDtoCopyWith(_RoomDto value, $Res Function(_RoomDto) _then) = __$RoomDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'room_id') String roomId, String? site, String name,@JsonKey(name: 'room_type') String? roomType
});




}
/// @nodoc
class __$RoomDtoCopyWithImpl<$Res>
    implements _$RoomDtoCopyWith<$Res> {
  __$RoomDtoCopyWithImpl(this._self, this._then);

  final _RoomDto _self;
  final $Res Function(_RoomDto) _then;

/// Create a copy of RoomDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? roomId = null,Object? site = freezed,Object? name = null,Object? roomType = freezed,}) {
  return _then(_RoomDto(
roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,site: freezed == site ? _self.site : site // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,roomType: freezed == roomType ? _self.roomType : roomType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MemberDto {

 int get id; String get user;@JsonKey(name: 'phone_e164') String? get phoneE164;@JsonKey(name: 'display_name') String? get displayName; String get role;@JsonKey(name: 'granted_by') String? get grantedBy;@JsonKey(name: 'granted_at') DateTime? get grantedAt;@JsonKey(name: 'revoked_at') DateTime? get revokedAt;
/// Create a copy of MemberDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberDtoCopyWith<MemberDto> get copyWith => _$MemberDtoCopyWithImpl<MemberDto>(this as MemberDto, _$identity);

  /// Serializes this MemberDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberDto&&(identical(other.id, id) || other.id == id)&&(identical(other.user, user) || other.user == user)&&(identical(other.phoneE164, phoneE164) || other.phoneE164 == phoneE164)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.role, role) || other.role == role)&&(identical(other.grantedBy, grantedBy) || other.grantedBy == grantedBy)&&(identical(other.grantedAt, grantedAt) || other.grantedAt == grantedAt)&&(identical(other.revokedAt, revokedAt) || other.revokedAt == revokedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,user,phoneE164,displayName,role,grantedBy,grantedAt,revokedAt);

@override
String toString() {
  return 'MemberDto(id: $id, user: $user, phoneE164: $phoneE164, displayName: $displayName, role: $role, grantedBy: $grantedBy, grantedAt: $grantedAt, revokedAt: $revokedAt)';
}


}

/// @nodoc
abstract mixin class $MemberDtoCopyWith<$Res>  {
  factory $MemberDtoCopyWith(MemberDto value, $Res Function(MemberDto) _then) = _$MemberDtoCopyWithImpl;
@useResult
$Res call({
 int id, String user,@JsonKey(name: 'phone_e164') String? phoneE164,@JsonKey(name: 'display_name') String? displayName, String role,@JsonKey(name: 'granted_by') String? grantedBy,@JsonKey(name: 'granted_at') DateTime? grantedAt,@JsonKey(name: 'revoked_at') DateTime? revokedAt
});




}
/// @nodoc
class _$MemberDtoCopyWithImpl<$Res>
    implements $MemberDtoCopyWith<$Res> {
  _$MemberDtoCopyWithImpl(this._self, this._then);

  final MemberDto _self;
  final $Res Function(MemberDto) _then;

/// Create a copy of MemberDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? user = null,Object? phoneE164 = freezed,Object? displayName = freezed,Object? role = null,Object? grantedBy = freezed,Object? grantedAt = freezed,Object? revokedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String,phoneE164: freezed == phoneE164 ? _self.phoneE164 : phoneE164 // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,grantedBy: freezed == grantedBy ? _self.grantedBy : grantedBy // ignore: cast_nullable_to_non_nullable
as String?,grantedAt: freezed == grantedAt ? _self.grantedAt : grantedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,revokedAt: freezed == revokedAt ? _self.revokedAt : revokedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberDto].
extension MemberDtoPatterns on MemberDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberDto value)  $default,){
final _that = this;
switch (_that) {
case _MemberDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberDto value)?  $default,){
final _that = this;
switch (_that) {
case _MemberDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String user, @JsonKey(name: 'phone_e164')  String? phoneE164, @JsonKey(name: 'display_name')  String? displayName,  String role, @JsonKey(name: 'granted_by')  String? grantedBy, @JsonKey(name: 'granted_at')  DateTime? grantedAt, @JsonKey(name: 'revoked_at')  DateTime? revokedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberDto() when $default != null:
return $default(_that.id,_that.user,_that.phoneE164,_that.displayName,_that.role,_that.grantedBy,_that.grantedAt,_that.revokedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String user, @JsonKey(name: 'phone_e164')  String? phoneE164, @JsonKey(name: 'display_name')  String? displayName,  String role, @JsonKey(name: 'granted_by')  String? grantedBy, @JsonKey(name: 'granted_at')  DateTime? grantedAt, @JsonKey(name: 'revoked_at')  DateTime? revokedAt)  $default,) {final _that = this;
switch (_that) {
case _MemberDto():
return $default(_that.id,_that.user,_that.phoneE164,_that.displayName,_that.role,_that.grantedBy,_that.grantedAt,_that.revokedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String user, @JsonKey(name: 'phone_e164')  String? phoneE164, @JsonKey(name: 'display_name')  String? displayName,  String role, @JsonKey(name: 'granted_by')  String? grantedBy, @JsonKey(name: 'granted_at')  DateTime? grantedAt, @JsonKey(name: 'revoked_at')  DateTime? revokedAt)?  $default,) {final _that = this;
switch (_that) {
case _MemberDto() when $default != null:
return $default(_that.id,_that.user,_that.phoneE164,_that.displayName,_that.role,_that.grantedBy,_that.grantedAt,_that.revokedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemberDto implements MemberDto {
  const _MemberDto({required this.id, required this.user, @JsonKey(name: 'phone_e164') this.phoneE164, @JsonKey(name: 'display_name') this.displayName, required this.role, @JsonKey(name: 'granted_by') this.grantedBy, @JsonKey(name: 'granted_at') this.grantedAt, @JsonKey(name: 'revoked_at') this.revokedAt});
  factory _MemberDto.fromJson(Map<String, dynamic> json) => _$MemberDtoFromJson(json);

@override final  int id;
@override final  String user;
@override@JsonKey(name: 'phone_e164') final  String? phoneE164;
@override@JsonKey(name: 'display_name') final  String? displayName;
@override final  String role;
@override@JsonKey(name: 'granted_by') final  String? grantedBy;
@override@JsonKey(name: 'granted_at') final  DateTime? grantedAt;
@override@JsonKey(name: 'revoked_at') final  DateTime? revokedAt;

/// Create a copy of MemberDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberDtoCopyWith<_MemberDto> get copyWith => __$MemberDtoCopyWithImpl<_MemberDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberDto&&(identical(other.id, id) || other.id == id)&&(identical(other.user, user) || other.user == user)&&(identical(other.phoneE164, phoneE164) || other.phoneE164 == phoneE164)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.role, role) || other.role == role)&&(identical(other.grantedBy, grantedBy) || other.grantedBy == grantedBy)&&(identical(other.grantedAt, grantedAt) || other.grantedAt == grantedAt)&&(identical(other.revokedAt, revokedAt) || other.revokedAt == revokedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,user,phoneE164,displayName,role,grantedBy,grantedAt,revokedAt);

@override
String toString() {
  return 'MemberDto(id: $id, user: $user, phoneE164: $phoneE164, displayName: $displayName, role: $role, grantedBy: $grantedBy, grantedAt: $grantedAt, revokedAt: $revokedAt)';
}


}

/// @nodoc
abstract mixin class _$MemberDtoCopyWith<$Res> implements $MemberDtoCopyWith<$Res> {
  factory _$MemberDtoCopyWith(_MemberDto value, $Res Function(_MemberDto) _then) = __$MemberDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String user,@JsonKey(name: 'phone_e164') String? phoneE164,@JsonKey(name: 'display_name') String? displayName, String role,@JsonKey(name: 'granted_by') String? grantedBy,@JsonKey(name: 'granted_at') DateTime? grantedAt,@JsonKey(name: 'revoked_at') DateTime? revokedAt
});




}
/// @nodoc
class __$MemberDtoCopyWithImpl<$Res>
    implements _$MemberDtoCopyWith<$Res> {
  __$MemberDtoCopyWithImpl(this._self, this._then);

  final _MemberDto _self;
  final $Res Function(_MemberDto) _then;

/// Create a copy of MemberDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? user = null,Object? phoneE164 = freezed,Object? displayName = freezed,Object? role = null,Object? grantedBy = freezed,Object? grantedAt = freezed,Object? revokedAt = freezed,}) {
  return _then(_MemberDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String,phoneE164: freezed == phoneE164 ? _self.phoneE164 : phoneE164 // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,grantedBy: freezed == grantedBy ? _self.grantedBy : grantedBy // ignore: cast_nullable_to_non_nullable
as String?,grantedAt: freezed == grantedAt ? _self.grantedAt : grantedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,revokedAt: freezed == revokedAt ? _self.revokedAt : revokedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
