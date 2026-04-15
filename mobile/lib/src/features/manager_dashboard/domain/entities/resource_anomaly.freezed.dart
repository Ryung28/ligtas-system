// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resource_anomaly.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ResourceAnomaly _$ResourceAnomalyFromJson(Map<String, dynamic> json) {
  return _ResourceAnomaly.fromJson(json);
}

/// @nodoc
mixin _$ResourceAnomaly {
  String get id => throw _privateConstructorUsedError;
  String get itemName => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  AnomalySeverity get severity => throw _privateConstructorUsedError;
  AnomalyType get type => throw _privateConstructorUsedError;
  DateTime get detectedAt => throw _privateConstructorUsedError;
  int get currentStock => throw _privateConstructorUsedError;
  int get threshold => throw _privateConstructorUsedError;
  String? get secondaryDetail =>
      throw _privateConstructorUsedError; // e.g. "Due in 2 days" or "Borrower: Juan"
  String? get referenceId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ResourceAnomalyCopyWith<ResourceAnomaly> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResourceAnomalyCopyWith<$Res> {
  factory $ResourceAnomalyCopyWith(
          ResourceAnomaly value, $Res Function(ResourceAnomaly) then) =
      _$ResourceAnomalyCopyWithImpl<$Res, ResourceAnomaly>;
  @useResult
  $Res call(
      {String id,
      String itemName,
      String reason,
      AnomalySeverity severity,
      AnomalyType type,
      DateTime detectedAt,
      int currentStock,
      int threshold,
      String? secondaryDetail,
      String? referenceId});
}

/// @nodoc
class _$ResourceAnomalyCopyWithImpl<$Res, $Val extends ResourceAnomaly>
    implements $ResourceAnomalyCopyWith<$Res> {
  _$ResourceAnomalyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? itemName = null,
    Object? reason = null,
    Object? severity = null,
    Object? type = null,
    Object? detectedAt = null,
    Object? currentStock = null,
    Object? threshold = null,
    Object? secondaryDetail = freezed,
    Object? referenceId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      itemName: null == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as AnomalySeverity,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AnomalyType,
      detectedAt: null == detectedAt
          ? _value.detectedAt
          : detectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      currentStock: null == currentStock
          ? _value.currentStock
          : currentStock // ignore: cast_nullable_to_non_nullable
              as int,
      threshold: null == threshold
          ? _value.threshold
          : threshold // ignore: cast_nullable_to_non_nullable
              as int,
      secondaryDetail: freezed == secondaryDetail
          ? _value.secondaryDetail
          : secondaryDetail // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceId: freezed == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ResourceAnomalyImplCopyWith<$Res>
    implements $ResourceAnomalyCopyWith<$Res> {
  factory _$$ResourceAnomalyImplCopyWith(_$ResourceAnomalyImpl value,
          $Res Function(_$ResourceAnomalyImpl) then) =
      __$$ResourceAnomalyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String itemName,
      String reason,
      AnomalySeverity severity,
      AnomalyType type,
      DateTime detectedAt,
      int currentStock,
      int threshold,
      String? secondaryDetail,
      String? referenceId});
}

/// @nodoc
class __$$ResourceAnomalyImplCopyWithImpl<$Res>
    extends _$ResourceAnomalyCopyWithImpl<$Res, _$ResourceAnomalyImpl>
    implements _$$ResourceAnomalyImplCopyWith<$Res> {
  __$$ResourceAnomalyImplCopyWithImpl(
      _$ResourceAnomalyImpl _value, $Res Function(_$ResourceAnomalyImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? itemName = null,
    Object? reason = null,
    Object? severity = null,
    Object? type = null,
    Object? detectedAt = null,
    Object? currentStock = null,
    Object? threshold = null,
    Object? secondaryDetail = freezed,
    Object? referenceId = freezed,
  }) {
    return _then(_$ResourceAnomalyImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      itemName: null == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as AnomalySeverity,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AnomalyType,
      detectedAt: null == detectedAt
          ? _value.detectedAt
          : detectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      currentStock: null == currentStock
          ? _value.currentStock
          : currentStock // ignore: cast_nullable_to_non_nullable
              as int,
      threshold: null == threshold
          ? _value.threshold
          : threshold // ignore: cast_nullable_to_non_nullable
              as int,
      secondaryDetail: freezed == secondaryDetail
          ? _value.secondaryDetail
          : secondaryDetail // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceId: freezed == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ResourceAnomalyImpl extends _ResourceAnomaly {
  const _$ResourceAnomalyImpl(
      {required this.id,
      required this.itemName,
      required this.reason,
      this.severity = AnomalySeverity.warning,
      this.type = AnomalyType.lowStock,
      required this.detectedAt,
      this.currentStock = 0,
      this.threshold = 0,
      this.secondaryDetail,
      this.referenceId})
      : super._();

  factory _$ResourceAnomalyImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResourceAnomalyImplFromJson(json);

  @override
  final String id;
  @override
  final String itemName;
  @override
  final String reason;
  @override
  @JsonKey()
  final AnomalySeverity severity;
  @override
  @JsonKey()
  final AnomalyType type;
  @override
  final DateTime detectedAt;
  @override
  @JsonKey()
  final int currentStock;
  @override
  @JsonKey()
  final int threshold;
  @override
  final String? secondaryDetail;
// e.g. "Due in 2 days" or "Borrower: Juan"
  @override
  final String? referenceId;

  @override
  String toString() {
    return 'ResourceAnomaly(id: $id, itemName: $itemName, reason: $reason, severity: $severity, type: $type, detectedAt: $detectedAt, currentStock: $currentStock, threshold: $threshold, secondaryDetail: $secondaryDetail, referenceId: $referenceId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResourceAnomalyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.detectedAt, detectedAt) ||
                other.detectedAt == detectedAt) &&
            (identical(other.currentStock, currentStock) ||
                other.currentStock == currentStock) &&
            (identical(other.threshold, threshold) ||
                other.threshold == threshold) &&
            (identical(other.secondaryDetail, secondaryDetail) ||
                other.secondaryDetail == secondaryDetail) &&
            (identical(other.referenceId, referenceId) ||
                other.referenceId == referenceId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, itemName, reason, severity,
      type, detectedAt, currentStock, threshold, secondaryDetail, referenceId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ResourceAnomalyImplCopyWith<_$ResourceAnomalyImpl> get copyWith =>
      __$$ResourceAnomalyImplCopyWithImpl<_$ResourceAnomalyImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ResourceAnomalyImplToJson(
      this,
    );
  }
}

abstract class _ResourceAnomaly extends ResourceAnomaly {
  const factory _ResourceAnomaly(
      {required final String id,
      required final String itemName,
      required final String reason,
      final AnomalySeverity severity,
      final AnomalyType type,
      required final DateTime detectedAt,
      final int currentStock,
      final int threshold,
      final String? secondaryDetail,
      final String? referenceId}) = _$ResourceAnomalyImpl;
  const _ResourceAnomaly._() : super._();

  factory _ResourceAnomaly.fromJson(Map<String, dynamic> json) =
      _$ResourceAnomalyImpl.fromJson;

  @override
  String get id;
  @override
  String get itemName;
  @override
  String get reason;
  @override
  AnomalySeverity get severity;
  @override
  AnomalyType get type;
  @override
  DateTime get detectedAt;
  @override
  int get currentStock;
  @override
  int get threshold;
  @override
  String? get secondaryDetail;
  @override // e.g. "Due in 2 days" or "Borrower: Juan"
  String? get referenceId;
  @override
  @JsonKey(ignore: true)
  _$$ResourceAnomalyImplCopyWith<_$ResourceAnomalyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
