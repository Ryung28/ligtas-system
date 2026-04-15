// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SettingsUser _$SettingsUserFromJson(Map<String, dynamic> json) {
  return _SettingsUser.fromJson(json);
}

/// @nodoc
mixin _$SettingsUser {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  String get lguName => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  bool get isOnline => throw _privateConstructorUsedError;
  String get lastSyncAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SettingsUserCopyWith<SettingsUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingsUserCopyWith<$Res> {
  factory $SettingsUserCopyWith(
          SettingsUser value, $Res Function(SettingsUser) then) =
      _$SettingsUserCopyWithImpl<$Res, SettingsUser>;
  @useResult
  $Res call(
      {String id,
      String email,
      String fullName,
      String role,
      String lguName,
      String? avatarUrl,
      bool isOnline,
      String lastSyncAt});
}

/// @nodoc
class _$SettingsUserCopyWithImpl<$Res, $Val extends SettingsUser>
    implements $SettingsUserCopyWith<$Res> {
  _$SettingsUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? fullName = null,
    Object? role = null,
    Object? lguName = null,
    Object? avatarUrl = freezed,
    Object? isOnline = null,
    Object? lastSyncAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      lguName: null == lguName
          ? _value.lguName
          : lguName // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSyncAt: null == lastSyncAt
          ? _value.lastSyncAt
          : lastSyncAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SettingsUserImplCopyWith<$Res>
    implements $SettingsUserCopyWith<$Res> {
  factory _$$SettingsUserImplCopyWith(
          _$SettingsUserImpl value, $Res Function(_$SettingsUserImpl) then) =
      __$$SettingsUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      String fullName,
      String role,
      String lguName,
      String? avatarUrl,
      bool isOnline,
      String lastSyncAt});
}

/// @nodoc
class __$$SettingsUserImplCopyWithImpl<$Res>
    extends _$SettingsUserCopyWithImpl<$Res, _$SettingsUserImpl>
    implements _$$SettingsUserImplCopyWith<$Res> {
  __$$SettingsUserImplCopyWithImpl(
      _$SettingsUserImpl _value, $Res Function(_$SettingsUserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? fullName = null,
    Object? role = null,
    Object? lguName = null,
    Object? avatarUrl = freezed,
    Object? isOnline = null,
    Object? lastSyncAt = null,
  }) {
    return _then(_$SettingsUserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      lguName: null == lguName
          ? _value.lguName
          : lguName // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSyncAt: null == lastSyncAt
          ? _value.lastSyncAt
          : lastSyncAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SettingsUserImpl implements _SettingsUser {
  const _$SettingsUserImpl(
      {this.id = '',
      this.email = '',
      this.fullName = '',
      this.role = '',
      this.lguName = '',
      this.avatarUrl = null,
      this.isOnline = false,
      this.lastSyncAt = ''});

  factory _$SettingsUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$SettingsUserImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String email;
  @override
  @JsonKey()
  final String fullName;
  @override
  @JsonKey()
  final String role;
  @override
  @JsonKey()
  final String lguName;
  @override
  @JsonKey()
  final String? avatarUrl;
  @override
  @JsonKey()
  final bool isOnline;
  @override
  @JsonKey()
  final String lastSyncAt;

  @override
  String toString() {
    return 'SettingsUser(id: $id, email: $email, fullName: $fullName, role: $role, lguName: $lguName, avatarUrl: $avatarUrl, isOnline: $isOnline, lastSyncAt: $lastSyncAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettingsUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.lguName, lguName) || other.lguName == lguName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.lastSyncAt, lastSyncAt) ||
                other.lastSyncAt == lastSyncAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, email, fullName, role,
      lguName, avatarUrl, isOnline, lastSyncAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SettingsUserImplCopyWith<_$SettingsUserImpl> get copyWith =>
      __$$SettingsUserImplCopyWithImpl<_$SettingsUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SettingsUserImplToJson(
      this,
    );
  }
}

abstract class _SettingsUser implements SettingsUser {
  const factory _SettingsUser(
      {final String id,
      final String email,
      final String fullName,
      final String role,
      final String lguName,
      final String? avatarUrl,
      final bool isOnline,
      final String lastSyncAt}) = _$SettingsUserImpl;

  factory _SettingsUser.fromJson(Map<String, dynamic> json) =
      _$SettingsUserImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String get fullName;
  @override
  String get role;
  @override
  String get lguName;
  @override
  String? get avatarUrl;
  @override
  bool get isOnline;
  @override
  String get lastSyncAt;
  @override
  @JsonKey(ignore: true)
  _$$SettingsUserImplCopyWith<_$SettingsUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
