// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'presence.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserPresence _$UserPresenceFromJson(Map<String, dynamic> json) {
  return _UserPresence.fromJson(json);
}

/// @nodoc
mixin _$UserPresence {
  String get userId => throw _privateConstructorUsedError;
  DateTime get lastSeen => throw _privateConstructorUsedError;
  bool get isOnline => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserPresenceCopyWith<UserPresence> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPresenceCopyWith<$Res> {
  factory $UserPresenceCopyWith(
          UserPresence value, $Res Function(UserPresence) then) =
      _$UserPresenceCopyWithImpl<$Res, UserPresence>;
  @useResult
  $Res call({String userId, DateTime lastSeen, bool isOnline});
}

/// @nodoc
class _$UserPresenceCopyWithImpl<$Res, $Val extends UserPresence>
    implements $UserPresenceCopyWith<$Res> {
  _$UserPresenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? lastSeen = null,
    Object? isOnline = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      lastSeen: null == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserPresenceImplCopyWith<$Res>
    implements $UserPresenceCopyWith<$Res> {
  factory _$$UserPresenceImplCopyWith(
          _$UserPresenceImpl value, $Res Function(_$UserPresenceImpl) then) =
      __$$UserPresenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId, DateTime lastSeen, bool isOnline});
}

/// @nodoc
class __$$UserPresenceImplCopyWithImpl<$Res>
    extends _$UserPresenceCopyWithImpl<$Res, _$UserPresenceImpl>
    implements _$$UserPresenceImplCopyWith<$Res> {
  __$$UserPresenceImplCopyWithImpl(
      _$UserPresenceImpl _value, $Res Function(_$UserPresenceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? lastSeen = null,
    Object? isOnline = null,
  }) {
    return _then(_$UserPresenceImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      lastSeen: null == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserPresenceImpl implements _UserPresence {
  const _$UserPresenceImpl(
      {this.userId = '', required this.lastSeen, this.isOnline = false});

  factory _$UserPresenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPresenceImplFromJson(json);

  @override
  @JsonKey()
  final String userId;
  @override
  final DateTime lastSeen;
  @override
  @JsonKey()
  final bool isOnline;

  @override
  String toString() {
    return 'UserPresence(userId: $userId, lastSeen: $lastSeen, isOnline: $isOnline)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPresenceImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, userId, lastSeen, isOnline);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPresenceImplCopyWith<_$UserPresenceImpl> get copyWith =>
      __$$UserPresenceImplCopyWithImpl<_$UserPresenceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPresenceImplToJson(
      this,
    );
  }
}

abstract class _UserPresence implements UserPresence {
  const factory _UserPresence(
      {final String userId,
      required final DateTime lastSeen,
      final bool isOnline}) = _$UserPresenceImpl;

  factory _UserPresence.fromJson(Map<String, dynamic> json) =
      _$UserPresenceImpl.fromJson;

  @override
  String get userId;
  @override
  DateTime get lastSeen;
  @override
  bool get isOnline;
  @override
  @JsonKey(ignore: true)
  _$$UserPresenceImplCopyWith<_$UserPresenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
