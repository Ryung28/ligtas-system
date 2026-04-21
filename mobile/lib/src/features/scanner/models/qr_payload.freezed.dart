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
  switch (json['runtimeType']) {
    case 'equipment':
      return _EquipmentPayload.fromJson(json);
    case 'station':
      return _StationPayload.fromJson(json);
    case 'person':
      return _PersonPayload.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'LigtasQrPayload',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$LigtasQrPayload {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String protocol, String version, String action,
            int itemId, String itemName)
        equipment,
    required TResult Function(String stationId, String locationName) station,
    required TResult Function(String personId, String personName, String role)
        person,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String protocol, String version, String action,
            int itemId, String itemName)?
        equipment,
    TResult? Function(String stationId, String locationName)? station,
    TResult? Function(String personId, String personName, String role)? person,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String protocol, String version, String action, int itemId,
            String itemName)?
        equipment,
    TResult Function(String stationId, String locationName)? station,
    TResult Function(String personId, String personName, String role)? person,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_EquipmentPayload value) equipment,
    required TResult Function(_StationPayload value) station,
    required TResult Function(_PersonPayload value) person,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_EquipmentPayload value)? equipment,
    TResult? Function(_StationPayload value)? station,
    TResult? Function(_PersonPayload value)? person,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_EquipmentPayload value)? equipment,
    TResult Function(_StationPayload value)? station,
    TResult Function(_PersonPayload value)? person,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LigtasQrPayloadCopyWith<$Res> {
  factory $LigtasQrPayloadCopyWith(
          LigtasQrPayload value, $Res Function(LigtasQrPayload) then) =
      _$LigtasQrPayloadCopyWithImpl<$Res, LigtasQrPayload>;
}

/// @nodoc
class _$LigtasQrPayloadCopyWithImpl<$Res, $Val extends LigtasQrPayload>
    implements $LigtasQrPayloadCopyWith<$Res> {
  _$LigtasQrPayloadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$EquipmentPayloadImplCopyWith<$Res> {
  factory _$$EquipmentPayloadImplCopyWith(_$EquipmentPayloadImpl value,
          $Res Function(_$EquipmentPayloadImpl) then) =
      __$$EquipmentPayloadImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {String protocol,
      String version,
      String action,
      int itemId,
      String itemName});
}

/// @nodoc
class __$$EquipmentPayloadImplCopyWithImpl<$Res>
    extends _$LigtasQrPayloadCopyWithImpl<$Res, _$EquipmentPayloadImpl>
    implements _$$EquipmentPayloadImplCopyWith<$Res> {
  __$$EquipmentPayloadImplCopyWithImpl(_$EquipmentPayloadImpl _value,
      $Res Function(_$EquipmentPayloadImpl) _then)
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
    return _then(_$EquipmentPayloadImpl(
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
class _$EquipmentPayloadImpl extends _EquipmentPayload
    with DiagnosticableTreeMixin {
  const _$EquipmentPayloadImpl(
      {required this.protocol,
      required this.version,
      required this.action,
      required this.itemId,
      required this.itemName,
      final String? $type})
      : $type = $type ?? 'equipment',
        super._();

  factory _$EquipmentPayloadImpl.fromJson(Map<String, dynamic> json) =>
      _$$EquipmentPayloadImplFromJson(json);

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

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'LigtasQrPayload.equipment(protocol: $protocol, version: $version, action: $action, itemId: $itemId, itemName: $itemName)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'LigtasQrPayload.equipment'))
      ..add(DiagnosticsProperty('protocol', protocol))
      ..add(DiagnosticsProperty('version', version))
      ..add(DiagnosticsProperty('action', action))
      ..add(DiagnosticsProperty('itemId', itemId))
      ..add(DiagnosticsProperty('itemName', itemName));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EquipmentPayloadImpl &&
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
  _$$EquipmentPayloadImplCopyWith<_$EquipmentPayloadImpl> get copyWith =>
      __$$EquipmentPayloadImplCopyWithImpl<_$EquipmentPayloadImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String protocol, String version, String action,
            int itemId, String itemName)
        equipment,
    required TResult Function(String stationId, String locationName) station,
    required TResult Function(String personId, String personName, String role)
        person,
  }) {
    return equipment(protocol, version, action, itemId, itemName);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String protocol, String version, String action,
            int itemId, String itemName)?
        equipment,
    TResult? Function(String stationId, String locationName)? station,
    TResult? Function(String personId, String personName, String role)? person,
  }) {
    return equipment?.call(protocol, version, action, itemId, itemName);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String protocol, String version, String action, int itemId,
            String itemName)?
        equipment,
    TResult Function(String stationId, String locationName)? station,
    TResult Function(String personId, String personName, String role)? person,
    required TResult orElse(),
  }) {
    if (equipment != null) {
      return equipment(protocol, version, action, itemId, itemName);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_EquipmentPayload value) equipment,
    required TResult Function(_StationPayload value) station,
    required TResult Function(_PersonPayload value) person,
  }) {
    return equipment(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_EquipmentPayload value)? equipment,
    TResult? Function(_StationPayload value)? station,
    TResult? Function(_PersonPayload value)? person,
  }) {
    return equipment?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_EquipmentPayload value)? equipment,
    TResult Function(_StationPayload value)? station,
    TResult Function(_PersonPayload value)? person,
    required TResult orElse(),
  }) {
    if (equipment != null) {
      return equipment(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$EquipmentPayloadImplToJson(
      this,
    );
  }
}

abstract class _EquipmentPayload extends LigtasQrPayload {
  const factory _EquipmentPayload(
      {required final String protocol,
      required final String version,
      required final String action,
      required final int itemId,
      required final String itemName}) = _$EquipmentPayloadImpl;
  const _EquipmentPayload._() : super._();

  factory _EquipmentPayload.fromJson(Map<String, dynamic> json) =
      _$EquipmentPayloadImpl.fromJson;

  String get protocol;
  String get version;
  String get action;
  int get itemId;
  String get itemName;
  @JsonKey(ignore: true)
  _$$EquipmentPayloadImplCopyWith<_$EquipmentPayloadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$StationPayloadImplCopyWith<$Res> {
  factory _$$StationPayloadImplCopyWith(_$StationPayloadImpl value,
          $Res Function(_$StationPayloadImpl) then) =
      __$$StationPayloadImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String stationId, String locationName});
}

/// @nodoc
class __$$StationPayloadImplCopyWithImpl<$Res>
    extends _$LigtasQrPayloadCopyWithImpl<$Res, _$StationPayloadImpl>
    implements _$$StationPayloadImplCopyWith<$Res> {
  __$$StationPayloadImplCopyWithImpl(
      _$StationPayloadImpl _value, $Res Function(_$StationPayloadImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stationId = null,
    Object? locationName = null,
  }) {
    return _then(_$StationPayloadImpl(
      stationId: null == stationId
          ? _value.stationId
          : stationId // ignore: cast_nullable_to_non_nullable
              as String,
      locationName: null == locationName
          ? _value.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StationPayloadImpl extends _StationPayload
    with DiagnosticableTreeMixin {
  const _$StationPayloadImpl(
      {required this.stationId,
      required this.locationName,
      final String? $type})
      : $type = $type ?? 'station',
        super._();

  factory _$StationPayloadImpl.fromJson(Map<String, dynamic> json) =>
      _$$StationPayloadImplFromJson(json);

  @override
  final String stationId;
  @override
  final String locationName;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'LigtasQrPayload.station(stationId: $stationId, locationName: $locationName)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'LigtasQrPayload.station'))
      ..add(DiagnosticsProperty('stationId', stationId))
      ..add(DiagnosticsProperty('locationName', locationName));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StationPayloadImpl &&
            (identical(other.stationId, stationId) ||
                other.stationId == stationId) &&
            (identical(other.locationName, locationName) ||
                other.locationName == locationName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, stationId, locationName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StationPayloadImplCopyWith<_$StationPayloadImpl> get copyWith =>
      __$$StationPayloadImplCopyWithImpl<_$StationPayloadImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String protocol, String version, String action,
            int itemId, String itemName)
        equipment,
    required TResult Function(String stationId, String locationName) station,
    required TResult Function(String personId, String personName, String role)
        person,
  }) {
    return station(stationId, locationName);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String protocol, String version, String action,
            int itemId, String itemName)?
        equipment,
    TResult? Function(String stationId, String locationName)? station,
    TResult? Function(String personId, String personName, String role)? person,
  }) {
    return station?.call(stationId, locationName);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String protocol, String version, String action, int itemId,
            String itemName)?
        equipment,
    TResult Function(String stationId, String locationName)? station,
    TResult Function(String personId, String personName, String role)? person,
    required TResult orElse(),
  }) {
    if (station != null) {
      return station(stationId, locationName);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_EquipmentPayload value) equipment,
    required TResult Function(_StationPayload value) station,
    required TResult Function(_PersonPayload value) person,
  }) {
    return station(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_EquipmentPayload value)? equipment,
    TResult? Function(_StationPayload value)? station,
    TResult? Function(_PersonPayload value)? person,
  }) {
    return station?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_EquipmentPayload value)? equipment,
    TResult Function(_StationPayload value)? station,
    TResult Function(_PersonPayload value)? person,
    required TResult orElse(),
  }) {
    if (station != null) {
      return station(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$StationPayloadImplToJson(
      this,
    );
  }
}

abstract class _StationPayload extends LigtasQrPayload {
  const factory _StationPayload(
      {required final String stationId,
      required final String locationName}) = _$StationPayloadImpl;
  const _StationPayload._() : super._();

  factory _StationPayload.fromJson(Map<String, dynamic> json) =
      _$StationPayloadImpl.fromJson;

  String get stationId;
  String get locationName;
  @JsonKey(ignore: true)
  _$$StationPayloadImplCopyWith<_$StationPayloadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PersonPayloadImplCopyWith<$Res> {
  factory _$$PersonPayloadImplCopyWith(
          _$PersonPayloadImpl value, $Res Function(_$PersonPayloadImpl) then) =
      __$$PersonPayloadImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String personId, String personName, String role});
}

/// @nodoc
class __$$PersonPayloadImplCopyWithImpl<$Res>
    extends _$LigtasQrPayloadCopyWithImpl<$Res, _$PersonPayloadImpl>
    implements _$$PersonPayloadImplCopyWith<$Res> {
  __$$PersonPayloadImplCopyWithImpl(
      _$PersonPayloadImpl _value, $Res Function(_$PersonPayloadImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? personId = null,
    Object? personName = null,
    Object? role = null,
  }) {
    return _then(_$PersonPayloadImpl(
      personId: null == personId
          ? _value.personId
          : personId // ignore: cast_nullable_to_non_nullable
              as String,
      personName: null == personName
          ? _value.personName
          : personName // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PersonPayloadImpl extends _PersonPayload with DiagnosticableTreeMixin {
  const _$PersonPayloadImpl(
      {required this.personId,
      required this.personName,
      this.role = 'Field Staff',
      final String? $type})
      : $type = $type ?? 'person',
        super._();

  factory _$PersonPayloadImpl.fromJson(Map<String, dynamic> json) =>
      _$$PersonPayloadImplFromJson(json);

  @override
  final String personId;
  @override
  final String personName;
  @override
  @JsonKey()
  final String role;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'LigtasQrPayload.person(personId: $personId, personName: $personName, role: $role)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'LigtasQrPayload.person'))
      ..add(DiagnosticsProperty('personId', personId))
      ..add(DiagnosticsProperty('personName', personName))
      ..add(DiagnosticsProperty('role', role));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersonPayloadImpl &&
            (identical(other.personId, personId) ||
                other.personId == personId) &&
            (identical(other.personName, personName) ||
                other.personName == personName) &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, personId, personName, role);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PersonPayloadImplCopyWith<_$PersonPayloadImpl> get copyWith =>
      __$$PersonPayloadImplCopyWithImpl<_$PersonPayloadImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String protocol, String version, String action,
            int itemId, String itemName)
        equipment,
    required TResult Function(String stationId, String locationName) station,
    required TResult Function(String personId, String personName, String role)
        person,
  }) {
    return person(personId, personName, role);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String protocol, String version, String action,
            int itemId, String itemName)?
        equipment,
    TResult? Function(String stationId, String locationName)? station,
    TResult? Function(String personId, String personName, String role)? person,
  }) {
    return person?.call(personId, personName, role);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String protocol, String version, String action, int itemId,
            String itemName)?
        equipment,
    TResult Function(String stationId, String locationName)? station,
    TResult Function(String personId, String personName, String role)? person,
    required TResult orElse(),
  }) {
    if (person != null) {
      return person(personId, personName, role);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_EquipmentPayload value) equipment,
    required TResult Function(_StationPayload value) station,
    required TResult Function(_PersonPayload value) person,
  }) {
    return person(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_EquipmentPayload value)? equipment,
    TResult? Function(_StationPayload value)? station,
    TResult? Function(_PersonPayload value)? person,
  }) {
    return person?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_EquipmentPayload value)? equipment,
    TResult Function(_StationPayload value)? station,
    TResult Function(_PersonPayload value)? person,
    required TResult orElse(),
  }) {
    if (person != null) {
      return person(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$PersonPayloadImplToJson(
      this,
    );
  }
}

abstract class _PersonPayload extends LigtasQrPayload {
  const factory _PersonPayload(
      {required final String personId,
      required final String personName,
      final String role}) = _$PersonPayloadImpl;
  const _PersonPayload._() : super._();

  factory _PersonPayload.fromJson(Map<String, dynamic> json) =
      _$PersonPayloadImpl.fromJson;

  String get personId;
  String get personName;
  String get role;
  @JsonKey(ignore: true)
  _$$PersonPayloadImplCopyWith<_$PersonPayloadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
