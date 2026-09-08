// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserDto {

 String get id; String get tenant;@JsonKey(name: 'phone_e164') String get phoneE164; String? get email;@JsonKey(name: 'display_name') String? get displayName; String get role; String get locale; String get status;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'last_login_at') DateTime? get lastLoginAt;
/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserDtoCopyWith<UserDto> get copyWith => _$UserDtoCopyWithImpl<UserDto>(this as UserDto, _$identity);

  /// Serializes this UserDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserDto&&(identical(other.id, id) || other.id == id)&&(identical(other.tenant, tenant) || other.tenant == tenant)&&(identical(other.phoneE164, phoneE164) || other.phoneE164 == phoneE164)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.role, role) || other.role == role)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tenant,phoneE164,email,displayName,role,locale,status,createdAt,lastLoginAt);

@override
String toString() {
  return 'UserDto(id: $id, tenant: $tenant, phoneE164: $phoneE164, email: $email, displayName: $displayName, role: $role, locale: $locale, status: $status, createdAt: $createdAt, lastLoginAt: $lastLoginAt)';
}


}

/// @nodoc
abstract mixin class $UserDtoCopyWith<$Res>  {
  factory $UserDtoCopyWith(UserDto value, $Res Function(UserDto) _then) = _$UserDtoCopyWithImpl;
@useResult
$Res call({
 String id, String tenant,@JsonKey(name: 'phone_e164') String phoneE164, String? email,@JsonKey(name: 'display_name') String? displayName, String role, String locale, String status,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'last_login_at') DateTime? lastLoginAt
});




}
/// @nodoc
class _$UserDtoCopyWithImpl<$Res>
    implements $UserDtoCopyWith<$Res> {
  _$UserDtoCopyWithImpl(this._self, this._then);

  final UserDto _self;
  final $Res Function(UserDto) _then;

/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tenant = null,Object? phoneE164 = null,Object? email = freezed,Object? displayName = freezed,Object? role = null,Object? locale = null,Object? status = null,Object? createdAt = freezed,Object? lastLoginAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenant: null == tenant ? _self.tenant : tenant // ignore: cast_nullable_to_non_nullable
as String,phoneE164: null == phoneE164 ? _self.phoneE164 : phoneE164 // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserDto].
extension UserDtoPatterns on UserDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserDto value)  $default,){
final _that = this;
switch (_that) {
case _UserDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserDto value)?  $default,){
final _that = this;
switch (_that) {
case _UserDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tenant, @JsonKey(name: 'phone_e164')  String phoneE164,  String? email, @JsonKey(name: 'display_name')  String? displayName,  String role,  String locale,  String status, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'last_login_at')  DateTime? lastLoginAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserDto() when $default != null:
return $default(_that.id,_that.tenant,_that.phoneE164,_that.email,_that.displayName,_that.role,_that.locale,_that.status,_that.createdAt,_that.lastLoginAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tenant, @JsonKey(name: 'phone_e164')  String phoneE164,  String? email, @JsonKey(name: 'display_name')  String? displayName,  String role,  String locale,  String status, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'last_login_at')  DateTime? lastLoginAt)  $default,) {final _that = this;
switch (_that) {
case _UserDto():
return $default(_that.id,_that.tenant,_that.phoneE164,_that.email,_that.displayName,_that.role,_that.locale,_that.status,_that.createdAt,_that.lastLoginAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tenant, @JsonKey(name: 'phone_e164')  String phoneE164,  String? email, @JsonKey(name: 'display_name')  String? displayName,  String role,  String locale,  String status, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'last_login_at')  DateTime? lastLoginAt)?  $default,) {final _that = this;
switch (_that) {
case _UserDto() when $default != null:
return $default(_that.id,_that.tenant,_that.phoneE164,_that.email,_that.displayName,_that.role,_that.locale,_that.status,_that.createdAt,_that.lastLoginAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserDto implements UserDto {
  const _UserDto({required this.id, required this.tenant, @JsonKey(name: 'phone_e164') required this.phoneE164, this.email, @JsonKey(name: 'display_name') this.displayName, required this.role, this.locale = 'en-KE', this.status = 'active', @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'last_login_at') this.lastLoginAt});
  factory _UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);

@override final  String id;
@override final  String tenant;
@override@JsonKey(name: 'phone_e164') final  String phoneE164;
@override final  String? email;
@override@JsonKey(name: 'display_name') final  String? displayName;
@override final  String role;
@override@JsonKey() final  String locale;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'last_login_at') final  DateTime? lastLoginAt;

/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserDtoCopyWith<_UserDto> get copyWith => __$UserDtoCopyWithImpl<_UserDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserDto&&(identical(other.id, id) || other.id == id)&&(identical(other.tenant, tenant) || other.tenant == tenant)&&(identical(other.phoneE164, phoneE164) || other.phoneE164 == phoneE164)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.role, role) || other.role == role)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tenant,phoneE164,email,displayName,role,locale,status,createdAt,lastLoginAt);

@override
String toString() {
  return 'UserDto(id: $id, tenant: $tenant, phoneE164: $phoneE164, email: $email, displayName: $displayName, role: $role, locale: $locale, status: $status, createdAt: $createdAt, lastLoginAt: $lastLoginAt)';
}


}

/// @nodoc
abstract mixin class _$UserDtoCopyWith<$Res> implements $UserDtoCopyWith<$Res> {
  factory _$UserDtoCopyWith(_UserDto value, $Res Function(_UserDto) _then) = __$UserDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String tenant,@JsonKey(name: 'phone_e164') String phoneE164, String? email,@JsonKey(name: 'display_name') String? displayName, String role, String locale, String status,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'last_login_at') DateTime? lastLoginAt
});




}
/// @nodoc
class __$UserDtoCopyWithImpl<$Res>
    implements _$UserDtoCopyWith<$Res> {
  __$UserDtoCopyWithImpl(this._self, this._then);

  final _UserDto _self;
  final $Res Function(_UserDto) _then;

/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tenant = null,Object? phoneE164 = null,Object? email = freezed,Object? displayName = freezed,Object? role = null,Object? locale = null,Object? status = null,Object? createdAt = freezed,Object? lastLoginAt = freezed,}) {
  return _then(_UserDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenant: null == tenant ? _self.tenant : tenant // ignore: cast_nullable_to_non_nullable
as String,phoneE164: null == phoneE164 ? _self.phoneE164 : phoneE164 // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$PreferencesDto {

 String get currency;@JsonKey(name: 'units_display') String get unitsDisplay;@JsonKey(name: 'default_site_id') String? get defaultSiteId;@JsonKey(name: 'quiet_hours_start') String? get quietHoursStart;@JsonKey(name: 'quiet_hours_end') String? get quietHoursEnd; Map<String, dynamic> get channels;@JsonKey(name: 'notify_min_severity') String get notifyMinSeverity;@JsonKey(name: 'data_saver') bool get dataSaver;
/// Create a copy of PreferencesDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PreferencesDtoCopyWith<PreferencesDto> get copyWith => _$PreferencesDtoCopyWithImpl<PreferencesDto>(this as PreferencesDto, _$identity);

  /// Serializes this PreferencesDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PreferencesDto&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.unitsDisplay, unitsDisplay) || other.unitsDisplay == unitsDisplay)&&(identical(other.defaultSiteId, defaultSiteId) || other.defaultSiteId == defaultSiteId)&&(identical(other.quietHoursStart, quietHoursStart) || other.quietHoursStart == quietHoursStart)&&(identical(other.quietHoursEnd, quietHoursEnd) || other.quietHoursEnd == quietHoursEnd)&&const DeepCollectionEquality().equals(other.channels, channels)&&(identical(other.notifyMinSeverity, notifyMinSeverity) || other.notifyMinSeverity == notifyMinSeverity)&&(identical(other.dataSaver, dataSaver) || other.dataSaver == dataSaver));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currency,unitsDisplay,defaultSiteId,quietHoursStart,quietHoursEnd,const DeepCollectionEquality().hash(channels),notifyMinSeverity,dataSaver);

@override
String toString() {
  return 'PreferencesDto(currency: $currency, unitsDisplay: $unitsDisplay, defaultSiteId: $defaultSiteId, quietHoursStart: $quietHoursStart, quietHoursEnd: $quietHoursEnd, channels: $channels, notifyMinSeverity: $notifyMinSeverity, dataSaver: $dataSaver)';
}


}

/// @nodoc
abstract mixin class $PreferencesDtoCopyWith<$Res>  {
  factory $PreferencesDtoCopyWith(PreferencesDto value, $Res Function(PreferencesDto) _then) = _$PreferencesDtoCopyWithImpl;
@useResult
$Res call({
 String currency,@JsonKey(name: 'units_display') String unitsDisplay,@JsonKey(name: 'default_site_id') String? defaultSiteId,@JsonKey(name: 'quiet_hours_start') String? quietHoursStart,@JsonKey(name: 'quiet_hours_end') String? quietHoursEnd, Map<String, dynamic> channels,@JsonKey(name: 'notify_min_severity') String notifyMinSeverity,@JsonKey(name: 'data_saver') bool dataSaver
});




}
/// @nodoc
class _$PreferencesDtoCopyWithImpl<$Res>
    implements $PreferencesDtoCopyWith<$Res> {
  _$PreferencesDtoCopyWithImpl(this._self, this._then);

  final PreferencesDto _self;
  final $Res Function(PreferencesDto) _then;

/// Create a copy of PreferencesDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currency = null,Object? unitsDisplay = null,Object? defaultSiteId = freezed,Object? quietHoursStart = freezed,Object? quietHoursEnd = freezed,Object? channels = null,Object? notifyMinSeverity = null,Object? dataSaver = null,}) {
  return _then(_self.copyWith(
currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,unitsDisplay: null == unitsDisplay ? _self.unitsDisplay : unitsDisplay // ignore: cast_nullable_to_non_nullable
as String,defaultSiteId: freezed == defaultSiteId ? _self.defaultSiteId : defaultSiteId // ignore: cast_nullable_to_non_nullable
as String?,quietHoursStart: freezed == quietHoursStart ? _self.quietHoursStart : quietHoursStart // ignore: cast_nullable_to_non_nullable
as String?,quietHoursEnd: freezed == quietHoursEnd ? _self.quietHoursEnd : quietHoursEnd // ignore: cast_nullable_to_non_nullable
as String?,channels: null == channels ? _self.channels : channels // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,notifyMinSeverity: null == notifyMinSeverity ? _self.notifyMinSeverity : notifyMinSeverity // ignore: cast_nullable_to_non_nullable
as String,dataSaver: null == dataSaver ? _self.dataSaver : dataSaver // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PreferencesDto].
extension PreferencesDtoPatterns on PreferencesDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PreferencesDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PreferencesDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PreferencesDto value)  $default,){
final _that = this;
switch (_that) {
case _PreferencesDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PreferencesDto value)?  $default,){
final _that = this;
switch (_that) {
case _PreferencesDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String currency, @JsonKey(name: 'units_display')  String unitsDisplay, @JsonKey(name: 'default_site_id')  String? defaultSiteId, @JsonKey(name: 'quiet_hours_start')  String? quietHoursStart, @JsonKey(name: 'quiet_hours_end')  String? quietHoursEnd,  Map<String, dynamic> channels, @JsonKey(name: 'notify_min_severity')  String notifyMinSeverity, @JsonKey(name: 'data_saver')  bool dataSaver)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PreferencesDto() when $default != null:
return $default(_that.currency,_that.unitsDisplay,_that.defaultSiteId,_that.quietHoursStart,_that.quietHoursEnd,_that.channels,_that.notifyMinSeverity,_that.dataSaver);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String currency, @JsonKey(name: 'units_display')  String unitsDisplay, @JsonKey(name: 'default_site_id')  String? defaultSiteId, @JsonKey(name: 'quiet_hours_start')  String? quietHoursStart, @JsonKey(name: 'quiet_hours_end')  String? quietHoursEnd,  Map<String, dynamic> channels, @JsonKey(name: 'notify_min_severity')  String notifyMinSeverity, @JsonKey(name: 'data_saver')  bool dataSaver)  $default,) {final _that = this;
switch (_that) {
case _PreferencesDto():
return $default(_that.currency,_that.unitsDisplay,_that.defaultSiteId,_that.quietHoursStart,_that.quietHoursEnd,_that.channels,_that.notifyMinSeverity,_that.dataSaver);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String currency, @JsonKey(name: 'units_display')  String unitsDisplay, @JsonKey(name: 'default_site_id')  String? defaultSiteId, @JsonKey(name: 'quiet_hours_start')  String? quietHoursStart, @JsonKey(name: 'quiet_hours_end')  String? quietHoursEnd,  Map<String, dynamic> channels, @JsonKey(name: 'notify_min_severity')  String notifyMinSeverity, @JsonKey(name: 'data_saver')  bool dataSaver)?  $default,) {final _that = this;
switch (_that) {
case _PreferencesDto() when $default != null:
return $default(_that.currency,_that.unitsDisplay,_that.defaultSiteId,_that.quietHoursStart,_that.quietHoursEnd,_that.channels,_that.notifyMinSeverity,_that.dataSaver);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PreferencesDto implements PreferencesDto {
  const _PreferencesDto({this.currency = 'KES', @JsonKey(name: 'units_display') this.unitsDisplay = 'kwh_and_kes', @JsonKey(name: 'default_site_id') this.defaultSiteId, @JsonKey(name: 'quiet_hours_start') this.quietHoursStart, @JsonKey(name: 'quiet_hours_end') this.quietHoursEnd, final  Map<String, dynamic> channels = const {'push' : true, 'sms' : false, 'email' : false}, @JsonKey(name: 'notify_min_severity') this.notifyMinSeverity = 'warning', @JsonKey(name: 'data_saver') this.dataSaver = false}): _channels = channels;
  factory _PreferencesDto.fromJson(Map<String, dynamic> json) => _$PreferencesDtoFromJson(json);

@override@JsonKey() final  String currency;
@override@JsonKey(name: 'units_display') final  String unitsDisplay;
@override@JsonKey(name: 'default_site_id') final  String? defaultSiteId;
@override@JsonKey(name: 'quiet_hours_start') final  String? quietHoursStart;
@override@JsonKey(name: 'quiet_hours_end') final  String? quietHoursEnd;
 final  Map<String, dynamic> _channels;
@override@JsonKey() Map<String, dynamic> get channels {
  if (_channels is EqualUnmodifiableMapView) return _channels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_channels);
}

@override@JsonKey(name: 'notify_min_severity') final  String notifyMinSeverity;
@override@JsonKey(name: 'data_saver') final  bool dataSaver;

/// Create a copy of PreferencesDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PreferencesDtoCopyWith<_PreferencesDto> get copyWith => __$PreferencesDtoCopyWithImpl<_PreferencesDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PreferencesDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PreferencesDto&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.unitsDisplay, unitsDisplay) || other.unitsDisplay == unitsDisplay)&&(identical(other.defaultSiteId, defaultSiteId) || other.defaultSiteId == defaultSiteId)&&(identical(other.quietHoursStart, quietHoursStart) || other.quietHoursStart == quietHoursStart)&&(identical(other.quietHoursEnd, quietHoursEnd) || other.quietHoursEnd == quietHoursEnd)&&const DeepCollectionEquality().equals(other._channels, _channels)&&(identical(other.notifyMinSeverity, notifyMinSeverity) || other.notifyMinSeverity == notifyMinSeverity)&&(identical(other.dataSaver, dataSaver) || other.dataSaver == dataSaver));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currency,unitsDisplay,defaultSiteId,quietHoursStart,quietHoursEnd,const DeepCollectionEquality().hash(_channels),notifyMinSeverity,dataSaver);

@override
String toString() {
  return 'PreferencesDto(currency: $currency, unitsDisplay: $unitsDisplay, defaultSiteId: $defaultSiteId, quietHoursStart: $quietHoursStart, quietHoursEnd: $quietHoursEnd, channels: $channels, notifyMinSeverity: $notifyMinSeverity, dataSaver: $dataSaver)';
}


}

/// @nodoc
abstract mixin class _$PreferencesDtoCopyWith<$Res> implements $PreferencesDtoCopyWith<$Res> {
  factory _$PreferencesDtoCopyWith(_PreferencesDto value, $Res Function(_PreferencesDto) _then) = __$PreferencesDtoCopyWithImpl;
@override @useResult
$Res call({
 String currency,@JsonKey(name: 'units_display') String unitsDisplay,@JsonKey(name: 'default_site_id') String? defaultSiteId,@JsonKey(name: 'quiet_hours_start') String? quietHoursStart,@JsonKey(name: 'quiet_hours_end') String? quietHoursEnd, Map<String, dynamic> channels,@JsonKey(name: 'notify_min_severity') String notifyMinSeverity,@JsonKey(name: 'data_saver') bool dataSaver
});




}
/// @nodoc
class __$PreferencesDtoCopyWithImpl<$Res>
    implements _$PreferencesDtoCopyWith<$Res> {
  __$PreferencesDtoCopyWithImpl(this._self, this._then);

  final _PreferencesDto _self;
  final $Res Function(_PreferencesDto) _then;

/// Create a copy of PreferencesDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currency = null,Object? unitsDisplay = null,Object? defaultSiteId = freezed,Object? quietHoursStart = freezed,Object? quietHoursEnd = freezed,Object? channels = null,Object? notifyMinSeverity = null,Object? dataSaver = null,}) {
  return _then(_PreferencesDto(
currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,unitsDisplay: null == unitsDisplay ? _self.unitsDisplay : unitsDisplay // ignore: cast_nullable_to_non_nullable
as String,defaultSiteId: freezed == defaultSiteId ? _self.defaultSiteId : defaultSiteId // ignore: cast_nullable_to_non_nullable
as String?,quietHoursStart: freezed == quietHoursStart ? _self.quietHoursStart : quietHoursStart // ignore: cast_nullable_to_non_nullable
as String?,quietHoursEnd: freezed == quietHoursEnd ? _self.quietHoursEnd : quietHoursEnd // ignore: cast_nullable_to_non_nullable
as String?,channels: null == channels ? _self._channels : channels // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,notifyMinSeverity: null == notifyMinSeverity ? _self.notifyMinSeverity : notifyMinSeverity // ignore: cast_nullable_to_non_nullable
as String,dataSaver: null == dataSaver ? _self.dataSaver : dataSaver // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
