// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OtpChallengeDto {

@JsonKey(name: 'pending_token') String get pendingToken; String get method;@JsonKey(name: 'masked_target') String? get maskedTarget;@JsonKey(name: 'expires_in') int get expiresIn;
/// Create a copy of OtpChallengeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtpChallengeDtoCopyWith<OtpChallengeDto> get copyWith => _$OtpChallengeDtoCopyWithImpl<OtpChallengeDto>(this as OtpChallengeDto, _$identity);

  /// Serializes this OtpChallengeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtpChallengeDto&&(identical(other.pendingToken, pendingToken) || other.pendingToken == pendingToken)&&(identical(other.method, method) || other.method == method)&&(identical(other.maskedTarget, maskedTarget) || other.maskedTarget == maskedTarget)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pendingToken,method,maskedTarget,expiresIn);

@override
String toString() {
  return 'OtpChallengeDto(pendingToken: $pendingToken, method: $method, maskedTarget: $maskedTarget, expiresIn: $expiresIn)';
}


}

/// @nodoc
abstract mixin class $OtpChallengeDtoCopyWith<$Res>  {
  factory $OtpChallengeDtoCopyWith(OtpChallengeDto value, $Res Function(OtpChallengeDto) _then) = _$OtpChallengeDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'pending_token') String pendingToken, String method,@JsonKey(name: 'masked_target') String? maskedTarget,@JsonKey(name: 'expires_in') int expiresIn
});




}
/// @nodoc
class _$OtpChallengeDtoCopyWithImpl<$Res>
    implements $OtpChallengeDtoCopyWith<$Res> {
  _$OtpChallengeDtoCopyWithImpl(this._self, this._then);

  final OtpChallengeDto _self;
  final $Res Function(OtpChallengeDto) _then;

/// Create a copy of OtpChallengeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pendingToken = null,Object? method = null,Object? maskedTarget = freezed,Object? expiresIn = null,}) {
  return _then(_self.copyWith(
pendingToken: null == pendingToken ? _self.pendingToken : pendingToken // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,maskedTarget: freezed == maskedTarget ? _self.maskedTarget : maskedTarget // ignore: cast_nullable_to_non_nullable
as String?,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OtpChallengeDto].
extension OtpChallengeDtoPatterns on OtpChallengeDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OtpChallengeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OtpChallengeDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OtpChallengeDto value)  $default,){
final _that = this;
switch (_that) {
case _OtpChallengeDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OtpChallengeDto value)?  $default,){
final _that = this;
switch (_that) {
case _OtpChallengeDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'pending_token')  String pendingToken,  String method, @JsonKey(name: 'masked_target')  String? maskedTarget, @JsonKey(name: 'expires_in')  int expiresIn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OtpChallengeDto() when $default != null:
return $default(_that.pendingToken,_that.method,_that.maskedTarget,_that.expiresIn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'pending_token')  String pendingToken,  String method, @JsonKey(name: 'masked_target')  String? maskedTarget, @JsonKey(name: 'expires_in')  int expiresIn)  $default,) {final _that = this;
switch (_that) {
case _OtpChallengeDto():
return $default(_that.pendingToken,_that.method,_that.maskedTarget,_that.expiresIn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'pending_token')  String pendingToken,  String method, @JsonKey(name: 'masked_target')  String? maskedTarget, @JsonKey(name: 'expires_in')  int expiresIn)?  $default,) {final _that = this;
switch (_that) {
case _OtpChallengeDto() when $default != null:
return $default(_that.pendingToken,_that.method,_that.maskedTarget,_that.expiresIn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OtpChallengeDto implements OtpChallengeDto {
  const _OtpChallengeDto({@JsonKey(name: 'pending_token') required this.pendingToken, this.method = 'sms', @JsonKey(name: 'masked_target') this.maskedTarget, @JsonKey(name: 'expires_in') this.expiresIn = 300});
  factory _OtpChallengeDto.fromJson(Map<String, dynamic> json) => _$OtpChallengeDtoFromJson(json);

@override@JsonKey(name: 'pending_token') final  String pendingToken;
@override@JsonKey() final  String method;
@override@JsonKey(name: 'masked_target') final  String? maskedTarget;
@override@JsonKey(name: 'expires_in') final  int expiresIn;

/// Create a copy of OtpChallengeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtpChallengeDtoCopyWith<_OtpChallengeDto> get copyWith => __$OtpChallengeDtoCopyWithImpl<_OtpChallengeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OtpChallengeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpChallengeDto&&(identical(other.pendingToken, pendingToken) || other.pendingToken == pendingToken)&&(identical(other.method, method) || other.method == method)&&(identical(other.maskedTarget, maskedTarget) || other.maskedTarget == maskedTarget)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pendingToken,method,maskedTarget,expiresIn);

@override
String toString() {
  return 'OtpChallengeDto(pendingToken: $pendingToken, method: $method, maskedTarget: $maskedTarget, expiresIn: $expiresIn)';
}


}

/// @nodoc
abstract mixin class _$OtpChallengeDtoCopyWith<$Res> implements $OtpChallengeDtoCopyWith<$Res> {
  factory _$OtpChallengeDtoCopyWith(_OtpChallengeDto value, $Res Function(_OtpChallengeDto) _then) = __$OtpChallengeDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'pending_token') String pendingToken, String method,@JsonKey(name: 'masked_target') String? maskedTarget,@JsonKey(name: 'expires_in') int expiresIn
});




}
/// @nodoc
class __$OtpChallengeDtoCopyWithImpl<$Res>
    implements _$OtpChallengeDtoCopyWith<$Res> {
  __$OtpChallengeDtoCopyWithImpl(this._self, this._then);

  final _OtpChallengeDto _self;
  final $Res Function(_OtpChallengeDto) _then;

/// Create a copy of OtpChallengeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pendingToken = null,Object? method = null,Object? maskedTarget = freezed,Object? expiresIn = null,}) {
  return _then(_OtpChallengeDto(
pendingToken: null == pendingToken ? _self.pendingToken : pendingToken // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,maskedTarget: freezed == maskedTarget ? _self.maskedTarget : maskedTarget // ignore: cast_nullable_to_non_nullable
as String?,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TokenPairDto {

 String get access; String get refresh;
/// Create a copy of TokenPairDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TokenPairDtoCopyWith<TokenPairDto> get copyWith => _$TokenPairDtoCopyWithImpl<TokenPairDto>(this as TokenPairDto, _$identity);

  /// Serializes this TokenPairDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenPairDto&&(identical(other.access, access) || other.access == access)&&(identical(other.refresh, refresh) || other.refresh == refresh));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,access,refresh);

@override
String toString() {
  return 'TokenPairDto(access: $access, refresh: $refresh)';
}


}

/// @nodoc
abstract mixin class $TokenPairDtoCopyWith<$Res>  {
  factory $TokenPairDtoCopyWith(TokenPairDto value, $Res Function(TokenPairDto) _then) = _$TokenPairDtoCopyWithImpl;
@useResult
$Res call({
 String access, String refresh
});




}
/// @nodoc
class _$TokenPairDtoCopyWithImpl<$Res>
    implements $TokenPairDtoCopyWith<$Res> {
  _$TokenPairDtoCopyWithImpl(this._self, this._then);

  final TokenPairDto _self;
  final $Res Function(TokenPairDto) _then;

/// Create a copy of TokenPairDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? access = null,Object? refresh = null,}) {
  return _then(_self.copyWith(
access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as String,refresh: null == refresh ? _self.refresh : refresh // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TokenPairDto].
extension TokenPairDtoPatterns on TokenPairDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TokenPairDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TokenPairDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TokenPairDto value)  $default,){
final _that = this;
switch (_that) {
case _TokenPairDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TokenPairDto value)?  $default,){
final _that = this;
switch (_that) {
case _TokenPairDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String access,  String refresh)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TokenPairDto() when $default != null:
return $default(_that.access,_that.refresh);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String access,  String refresh)  $default,) {final _that = this;
switch (_that) {
case _TokenPairDto():
return $default(_that.access,_that.refresh);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String access,  String refresh)?  $default,) {final _that = this;
switch (_that) {
case _TokenPairDto() when $default != null:
return $default(_that.access,_that.refresh);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TokenPairDto implements TokenPairDto {
  const _TokenPairDto({required this.access, required this.refresh});
  factory _TokenPairDto.fromJson(Map<String, dynamic> json) => _$TokenPairDtoFromJson(json);

@override final  String access;
@override final  String refresh;

/// Create a copy of TokenPairDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TokenPairDtoCopyWith<_TokenPairDto> get copyWith => __$TokenPairDtoCopyWithImpl<_TokenPairDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TokenPairDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TokenPairDto&&(identical(other.access, access) || other.access == access)&&(identical(other.refresh, refresh) || other.refresh == refresh));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,access,refresh);

@override
String toString() {
  return 'TokenPairDto(access: $access, refresh: $refresh)';
}


}

/// @nodoc
abstract mixin class _$TokenPairDtoCopyWith<$Res> implements $TokenPairDtoCopyWith<$Res> {
  factory _$TokenPairDtoCopyWith(_TokenPairDto value, $Res Function(_TokenPairDto) _then) = __$TokenPairDtoCopyWithImpl;
@override @useResult
$Res call({
 String access, String refresh
});




}
/// @nodoc
class __$TokenPairDtoCopyWithImpl<$Res>
    implements _$TokenPairDtoCopyWith<$Res> {
  __$TokenPairDtoCopyWithImpl(this._self, this._then);

  final _TokenPairDto _self;
  final $Res Function(_TokenPairDto) _then;

/// Create a copy of TokenPairDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? access = null,Object? refresh = null,}) {
  return _then(_TokenPairDto(
access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as String,refresh: null == refresh ? _self.refresh : refresh // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SessionDto {

@JsonKey(name: 'session_id') String get sessionId;@JsonKey(name: 'device_name') String? get deviceName;@JsonKey(name: 'ip_address') String? get ipAddress;@JsonKey(name: 'login_at') DateTime? get loginAt;@JsonKey(name: 'last_activity') DateTime? get lastActivity;@JsonKey(name: 'expires_at') DateTime? get expiresAt;@JsonKey(name: 'is_current') bool get isCurrent;
/// Create a copy of SessionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionDtoCopyWith<SessionDto> get copyWith => _$SessionDtoCopyWithImpl<SessionDto>(this as SessionDto, _$identity);

  /// Serializes this SessionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionDto&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.loginAt, loginAt) || other.loginAt == loginAt)&&(identical(other.lastActivity, lastActivity) || other.lastActivity == lastActivity)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,deviceName,ipAddress,loginAt,lastActivity,expiresAt,isCurrent);

@override
String toString() {
  return 'SessionDto(sessionId: $sessionId, deviceName: $deviceName, ipAddress: $ipAddress, loginAt: $loginAt, lastActivity: $lastActivity, expiresAt: $expiresAt, isCurrent: $isCurrent)';
}


}

/// @nodoc
abstract mixin class $SessionDtoCopyWith<$Res>  {
  factory $SessionDtoCopyWith(SessionDto value, $Res Function(SessionDto) _then) = _$SessionDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'session_id') String sessionId,@JsonKey(name: 'device_name') String? deviceName,@JsonKey(name: 'ip_address') String? ipAddress,@JsonKey(name: 'login_at') DateTime? loginAt,@JsonKey(name: 'last_activity') DateTime? lastActivity,@JsonKey(name: 'expires_at') DateTime? expiresAt,@JsonKey(name: 'is_current') bool isCurrent
});




}
/// @nodoc
class _$SessionDtoCopyWithImpl<$Res>
    implements $SessionDtoCopyWith<$Res> {
  _$SessionDtoCopyWithImpl(this._self, this._then);

  final SessionDto _self;
  final $Res Function(SessionDto) _then;

/// Create a copy of SessionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? deviceName = freezed,Object? ipAddress = freezed,Object? loginAt = freezed,Object? lastActivity = freezed,Object? expiresAt = freezed,Object? isCurrent = null,}) {
  return _then(_self.copyWith(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,loginAt: freezed == loginAt ? _self.loginAt : loginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastActivity: freezed == lastActivity ? _self.lastActivity : lastActivity // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionDto].
extension SessionDtoPatterns on SessionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionDto value)  $default,){
final _that = this;
switch (_that) {
case _SessionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionDto value)?  $default,){
final _that = this;
switch (_that) {
case _SessionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'device_name')  String? deviceName, @JsonKey(name: 'ip_address')  String? ipAddress, @JsonKey(name: 'login_at')  DateTime? loginAt, @JsonKey(name: 'last_activity')  DateTime? lastActivity, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'is_current')  bool isCurrent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionDto() when $default != null:
return $default(_that.sessionId,_that.deviceName,_that.ipAddress,_that.loginAt,_that.lastActivity,_that.expiresAt,_that.isCurrent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'device_name')  String? deviceName, @JsonKey(name: 'ip_address')  String? ipAddress, @JsonKey(name: 'login_at')  DateTime? loginAt, @JsonKey(name: 'last_activity')  DateTime? lastActivity, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'is_current')  bool isCurrent)  $default,) {final _that = this;
switch (_that) {
case _SessionDto():
return $default(_that.sessionId,_that.deviceName,_that.ipAddress,_that.loginAt,_that.lastActivity,_that.expiresAt,_that.isCurrent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'device_name')  String? deviceName, @JsonKey(name: 'ip_address')  String? ipAddress, @JsonKey(name: 'login_at')  DateTime? loginAt, @JsonKey(name: 'last_activity')  DateTime? lastActivity, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'is_current')  bool isCurrent)?  $default,) {final _that = this;
switch (_that) {
case _SessionDto() when $default != null:
return $default(_that.sessionId,_that.deviceName,_that.ipAddress,_that.loginAt,_that.lastActivity,_that.expiresAt,_that.isCurrent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionDto implements SessionDto {
  const _SessionDto({@JsonKey(name: 'session_id') required this.sessionId, @JsonKey(name: 'device_name') this.deviceName, @JsonKey(name: 'ip_address') this.ipAddress, @JsonKey(name: 'login_at') this.loginAt, @JsonKey(name: 'last_activity') this.lastActivity, @JsonKey(name: 'expires_at') this.expiresAt, @JsonKey(name: 'is_current') this.isCurrent = false});
  factory _SessionDto.fromJson(Map<String, dynamic> json) => _$SessionDtoFromJson(json);

@override@JsonKey(name: 'session_id') final  String sessionId;
@override@JsonKey(name: 'device_name') final  String? deviceName;
@override@JsonKey(name: 'ip_address') final  String? ipAddress;
@override@JsonKey(name: 'login_at') final  DateTime? loginAt;
@override@JsonKey(name: 'last_activity') final  DateTime? lastActivity;
@override@JsonKey(name: 'expires_at') final  DateTime? expiresAt;
@override@JsonKey(name: 'is_current') final  bool isCurrent;

/// Create a copy of SessionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionDtoCopyWith<_SessionDto> get copyWith => __$SessionDtoCopyWithImpl<_SessionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionDto&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.loginAt, loginAt) || other.loginAt == loginAt)&&(identical(other.lastActivity, lastActivity) || other.lastActivity == lastActivity)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,deviceName,ipAddress,loginAt,lastActivity,expiresAt,isCurrent);

@override
String toString() {
  return 'SessionDto(sessionId: $sessionId, deviceName: $deviceName, ipAddress: $ipAddress, loginAt: $loginAt, lastActivity: $lastActivity, expiresAt: $expiresAt, isCurrent: $isCurrent)';
}


}

/// @nodoc
abstract mixin class _$SessionDtoCopyWith<$Res> implements $SessionDtoCopyWith<$Res> {
  factory _$SessionDtoCopyWith(_SessionDto value, $Res Function(_SessionDto) _then) = __$SessionDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'session_id') String sessionId,@JsonKey(name: 'device_name') String? deviceName,@JsonKey(name: 'ip_address') String? ipAddress,@JsonKey(name: 'login_at') DateTime? loginAt,@JsonKey(name: 'last_activity') DateTime? lastActivity,@JsonKey(name: 'expires_at') DateTime? expiresAt,@JsonKey(name: 'is_current') bool isCurrent
});




}
/// @nodoc
class __$SessionDtoCopyWithImpl<$Res>
    implements _$SessionDtoCopyWith<$Res> {
  __$SessionDtoCopyWithImpl(this._self, this._then);

  final _SessionDto _self;
  final $Res Function(_SessionDto) _then;

/// Create a copy of SessionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? deviceName = freezed,Object? ipAddress = freezed,Object? loginAt = freezed,Object? lastActivity = freezed,Object? expiresAt = freezed,Object? isCurrent = null,}) {
  return _then(_SessionDto(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,loginAt: freezed == loginAt ? _self.loginAt : loginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastActivity: freezed == lastActivity ? _self.lastActivity : lastActivity // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
