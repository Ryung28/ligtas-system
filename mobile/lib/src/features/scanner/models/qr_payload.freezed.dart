// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'qr_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LigtasQrPayload _$LigtasQrPayloadFromJson(Map<String, dynamic> json) {
  return _LigtasQrPayload.fromJson(json);
}

/// @nodoc
mixin _$LigtasQrPayload {
  String get protocol => throw _privateConstructorUsedError;
  String get version => throw _privateConstructorUsedError;
  String get action => throw _privateConstructorUsedError;
  int get itemId => throw _privateConstructorUsedError;
  String get itemName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LigtasQrPayloadCopyWith<LigtasQrPayload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LigtasQrPayloadCopyWith<$Res> {
  factory $LigtasQrPayloadCopyWith(
          LigtasQrPayload value, $Res Function(LigtasQrPayload) then) =
      _$LigtasQrPayloadCopyWithImpl<$Res, LigtasQrPayload>;
  @useResult
  $Res call(
      {String protocol,
      String version,
      String action,
      int itemId,
      String itemName});
}

/// @nodoc
class _$LigtasQrPayloadCopyWithImpl<$Res, $Val extends LigtasQrPayload>
    implements $LigtasQrPayloadCopyWith<$Res> {
  _$LigtasQrPayloadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? protocol = null,
    Object? version = null,
    Object? action = null,
    Object? itemId = null,
    Object? itemName = null,
  }) {
    return _then(_value.copyWith(
      protocol: null == protocol
          ? _value.protocol
          : protocol // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as int,
      itemName: null == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LigtasQrPayloadImplCopyWith<$Res>
    implements $LigtasQrPayloadCopyWith<$Res> {
  factory _$$LigtasQrPayloadImplCopyWith(_$LigtasQrPayloadImpl value,
          $Res Function(_$LigtasQrPayloadImpl) then) =
      __$$LigtasQrPayloadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String protocol,
      String version,
      String action,
      int itemId,
      String itemName});
}

/// @nodoc
class __$$LigtasQrPayloadImplCopyWithImpl<$Res>
    extends _$LigtasQrPayloadCopyWithImpl<$Res, _$LigtasQrPayloadImpl>
    implements _$$LigtasQrPayloadImplCopyWith<$Res> {
  __$$LigtasQrPayloadImplCopyWithImpl(
      _$LigtasQrPayloadImpl _value, $Res Function(_$LigtasQrPayloadImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? protocol = null,
    Object? version = null,
    Object? action = null,
    Object? itemId = null,
    Object? itemName = null,
  }) {
    return _then(_$LigtasQrPayloadImpl(
      protocol: null == protocol
          ? _value.protocol
          : protocol // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as int,
      itemName: null == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LigtasQrPayloadImpl extends _LigtasQrPayload {
  const _$LigtasQrPayloadImpl(
      {required this.protocol,
      required this.version,
      required this.action,
      required this.itemId,
      required this.itemName})
      : super._();

  factory _$LigtasQrPayloadImpl.fromJson(Map<String, dynamic> json) =>
      _$$LigtasQrPayloadImplFromJson(json);

  @override
  final String protocol;
  @override
  final String version;
  @override
  final String action;
  @override
  final int itemId;
  @override
  final String itemName;

  @override
  String toString() {
    return 'LigtasQrPayload(protocol: $protocol, version: $version, action: $action, itemId: $itemId, itemName: $itemName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LigtasQrPayloadImpl &&
            (identical(other.protocol, protocol) ||
                other.protocol == protocol) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, protocol, version, action, itemId, itemName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LigtasQrPayloadImplCopyWith<_$LigtasQrPayloadImpl> get copyWith =>
      __$$LigtasQrPayloadImplCopyWithImpl<_$LigtasQrPayloadImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LigtasQrPayloadImplToJson(
      this,
    );
  }
}

abstract class _LigtasQrPayload extends LigtasQrPayload {
  const factory _LigtasQrPayload(
      {required final String protocol,
      required final String version,
      required final String action,
      required final int itemId,
      required final String itemName}) = _$LigtasQrPayloadImpl;
  const _LigtasQrPayload._() : super._();

  factory _LigtasQrPayload.fromJson(Map<String, dynamic> json) =
      _$LigtasQrPayloadImpl.fromJson;

  @override
  String get protocol;
  @override
  String get version;
  @override
  String get action;
  @override
  int get itemId;
  @override
  String get itemName;
  @override
  @JsonKey(ignore: true)
  _$$LigtasQrPayloadImplCopyWith<_$LigtasQrPayloadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
