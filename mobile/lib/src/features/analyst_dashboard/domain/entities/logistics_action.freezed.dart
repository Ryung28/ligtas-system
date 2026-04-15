// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'logistics_action.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LogisticsAction _$LogisticsActionFromJson(Map<String, dynamic> json) {
  return _LogisticsAction.fromJson(json);
}

/// @nodoc
mixin _$LogisticsAction {
  @JsonKey(fromJson: _idToString)
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name')
  String get itemName => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_id', fromJson: _idToString)
  String get itemId =>
      throw _privateConstructorUsedError; // 🛡️ SYNC: Changed from inventory_id to item_id
  @JsonKey(name: 'type', fromJson: _typeFromJson)
  ActionType get type =>
      throw _privateConstructorUsedError; // 🛡️ SYNC: Correct DB column name
  @JsonKey(fromJson: _statusFromJson)
  ActionStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'quantity', fromJson: _toInt)
  int get quantity =>
      throw _privateConstructorUsedError; // 🛡️ SYNC: Correct DB column name
  @JsonKey(name: 'requester_id', fromJson: _idToString)
  String? get requesterId => throw _privateConstructorUsedError;
  @JsonKey(name: 'requester_name', fromJson: _idToString)
  String? get requesterName => throw _privateConstructorUsedError;
  @JsonKey(name: 'recipient_name', fromJson: _idToString)
  String? get recipientName => throw _privateConstructorUsedError;
  @JsonKey(name: 'recipient_office', fromJson: _idToString)
  String? get recipientOffice => throw _privateConstructorUsedError;
  @JsonKey(name: 'warehouse_id', fromJson: _idToString)
  String? get warehouseId => throw _privateConstructorUsedError;
  @JsonKey(name: 'bin_location', fromJson: _idToString)
  String? get binLocation => throw _privateConstructorUsedError;
  @JsonKey(name: 'forensic_note', fromJson: _idToString)
  String? get forensicNote => throw _privateConstructorUsedError;
  @JsonKey(name: 'forensic_image_url', fromJson: _idToString)
  String? get forensicImageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LogisticsActionCopyWith<LogisticsAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LogisticsActionCopyWith<$Res> {
  factory $LogisticsActionCopyWith(
          LogisticsAction value, $Res Function(LogisticsAction) then) =
      _$LogisticsActionCopyWithImpl<$Res, LogisticsAction>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: _idToString) String id,
      @JsonKey(name: 'item_name') String itemName,
      @JsonKey(name: 'item_id', fromJson: _idToString) String itemId,
      @JsonKey(name: 'type', fromJson: _typeFromJson) ActionType type,
      @JsonKey(fromJson: _statusFromJson) ActionStatus status,
      @JsonKey(name: 'quantity', fromJson: _toInt) int quantity,
      @JsonKey(name: 'requester_id', fromJson: _idToString) String? requesterId,
      @JsonKey(name: 'requester_name', fromJson: _idToString)
      String? requesterName,
      @JsonKey(name: 'recipient_name', fromJson: _idToString)
      String? recipientName,
      @JsonKey(name: 'recipient_office', fromJson: _idToString)
      String? recipientOffice,
      @JsonKey(name: 'warehouse_id', fromJson: _idToString) String? warehouseId,
      @JsonKey(name: 'bin_location', fromJson: _idToString) String? binLocation,
      @JsonKey(name: 'forensic_note', fromJson: _idToString)
      String? forensicNote,
      @JsonKey(name: 'forensic_image_url', fromJson: _idToString)
      String? forensicImageUrl,
      @JsonKey(name: 'created_at') DateTime? createdAt});
}

/// @nodoc
class _$LogisticsActionCopyWithImpl<$Res, $Val extends LogisticsAction>
    implements $LogisticsActionCopyWith<$Res> {
  _$LogisticsActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? itemName = null,
    Object? itemId = null,
    Object? type = null,
    Object? status = null,
    Object? quantity = null,
    Object? requesterId = freezed,
    Object? requesterName = freezed,
    Object? recipientName = freezed,
    Object? recipientOffice = freezed,
    Object? warehouseId = freezed,
    Object? binLocation = freezed,
    Object? forensicNote = freezed,
    Object? forensicImageUrl = freezed,
    Object? createdAt = freezed,
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
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ActionType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ActionStatus,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      requesterId: freezed == requesterId
          ? _value.requesterId
          : requesterId // ignore: cast_nullable_to_non_nullable
              as String?,
      requesterName: freezed == requesterName
          ? _value.requesterName
          : requesterName // ignore: cast_nullable_to_non_nullable
              as String?,
      recipientName: freezed == recipientName
          ? _value.recipientName
          : recipientName // ignore: cast_nullable_to_non_nullable
              as String?,
      recipientOffice: freezed == recipientOffice
          ? _value.recipientOffice
          : recipientOffice // ignore: cast_nullable_to_non_nullable
              as String?,
      warehouseId: freezed == warehouseId
          ? _value.warehouseId
          : warehouseId // ignore: cast_nullable_to_non_nullable
              as String?,
      binLocation: freezed == binLocation
          ? _value.binLocation
          : binLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      forensicNote: freezed == forensicNote
          ? _value.forensicNote
          : forensicNote // ignore: cast_nullable_to_non_nullable
              as String?,
      forensicImageUrl: freezed == forensicImageUrl
          ? _value.forensicImageUrl
          : forensicImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LogisticsActionImplCopyWith<$Res>
    implements $LogisticsActionCopyWith<$Res> {
  factory _$$LogisticsActionImplCopyWith(_$LogisticsActionImpl value,
          $Res Function(_$LogisticsActionImpl) then) =
      __$$LogisticsActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: _idToString) String id,
      @JsonKey(name: 'item_name') String itemName,
      @JsonKey(name: 'item_id', fromJson: _idToString) String itemId,
      @JsonKey(name: 'type', fromJson: _typeFromJson) ActionType type,
      @JsonKey(fromJson: _statusFromJson) ActionStatus status,
      @JsonKey(name: 'quantity', fromJson: _toInt) int quantity,
      @JsonKey(name: 'requester_id', fromJson: _idToString) String? requesterId,
      @JsonKey(name: 'requester_name', fromJson: _idToString)
      String? requesterName,
      @JsonKey(name: 'recipient_name', fromJson: _idToString)
      String? recipientName,
      @JsonKey(name: 'recipient_office', fromJson: _idToString)
      String? recipientOffice,
      @JsonKey(name: 'warehouse_id', fromJson: _idToString) String? warehouseId,
      @JsonKey(name: 'bin_location', fromJson: _idToString) String? binLocation,
      @JsonKey(name: 'forensic_note', fromJson: _idToString)
      String? forensicNote,
      @JsonKey(name: 'forensic_image_url', fromJson: _idToString)
      String? forensicImageUrl,
      @JsonKey(name: 'created_at') DateTime? createdAt});
}

/// @nodoc
class __$$LogisticsActionImplCopyWithImpl<$Res>
    extends _$LogisticsActionCopyWithImpl<$Res, _$LogisticsActionImpl>
    implements _$$LogisticsActionImplCopyWith<$Res> {
  __$$LogisticsActionImplCopyWithImpl(
      _$LogisticsActionImpl _value, $Res Function(_$LogisticsActionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? itemName = null,
    Object? itemId = null,
    Object? type = null,
    Object? status = null,
    Object? quantity = null,
    Object? requesterId = freezed,
    Object? requesterName = freezed,
    Object? recipientName = freezed,
    Object? recipientOffice = freezed,
    Object? warehouseId = freezed,
    Object? binLocation = freezed,
    Object? forensicNote = freezed,
    Object? forensicImageUrl = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$LogisticsActionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      itemName: null == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ActionType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ActionStatus,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      requesterId: freezed == requesterId
          ? _value.requesterId
          : requesterId // ignore: cast_nullable_to_non_nullable
              as String?,
      requesterName: freezed == requesterName
          ? _value.requesterName
          : requesterName // ignore: cast_nullable_to_non_nullable
              as String?,
      recipientName: freezed == recipientName
          ? _value.recipientName
          : recipientName // ignore: cast_nullable_to_non_nullable
              as String?,
      recipientOffice: freezed == recipientOffice
          ? _value.recipientOffice
          : recipientOffice // ignore: cast_nullable_to_non_nullable
              as String?,
      warehouseId: freezed == warehouseId
          ? _value.warehouseId
          : warehouseId // ignore: cast_nullable_to_non_nullable
              as String?,
      binLocation: freezed == binLocation
          ? _value.binLocation
          : binLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      forensicNote: freezed == forensicNote
          ? _value.forensicNote
          : forensicNote // ignore: cast_nullable_to_non_nullable
              as String?,
      forensicImageUrl: freezed == forensicImageUrl
          ? _value.forensicImageUrl
          : forensicImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LogisticsActionImpl extends _LogisticsAction {
  const _$LogisticsActionImpl(
      {@JsonKey(fromJson: _idToString) required this.id,
      @JsonKey(name: 'item_name') required this.itemName,
      @JsonKey(name: 'item_id', fromJson: _idToString) required this.itemId,
      @JsonKey(name: 'type', fromJson: _typeFromJson) required this.type,
      @JsonKey(fromJson: _statusFromJson) this.status = ActionStatus.pending,
      @JsonKey(name: 'quantity', fromJson: _toInt) required this.quantity,
      @JsonKey(name: 'requester_id', fromJson: _idToString) this.requesterId,
      @JsonKey(name: 'requester_name', fromJson: _idToString)
      this.requesterName,
      @JsonKey(name: 'recipient_name', fromJson: _idToString)
      this.recipientName,
      @JsonKey(name: 'recipient_office', fromJson: _idToString)
      this.recipientOffice,
      @JsonKey(name: 'warehouse_id', fromJson: _idToString) this.warehouseId,
      @JsonKey(name: 'bin_location', fromJson: _idToString) this.binLocation,
      @JsonKey(name: 'forensic_note', fromJson: _idToString) this.forensicNote,
      @JsonKey(name: 'forensic_image_url', fromJson: _idToString)
      this.forensicImageUrl,
      @JsonKey(name: 'created_at') this.createdAt})
      : super._();

  factory _$LogisticsActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$LogisticsActionImplFromJson(json);

  @override
  @JsonKey(fromJson: _idToString)
  final String id;
  @override
  @JsonKey(name: 'item_name')
  final String itemName;
  @override
  @JsonKey(name: 'item_id', fromJson: _idToString)
  final String itemId;
// 🛡️ SYNC: Changed from inventory_id to item_id
  @override
  @JsonKey(name: 'type', fromJson: _typeFromJson)
  final ActionType type;
// 🛡️ SYNC: Correct DB column name
  @override
  @JsonKey(fromJson: _statusFromJson)
  final ActionStatus status;
  @override
  @JsonKey(name: 'quantity', fromJson: _toInt)
  final int quantity;
// 🛡️ SYNC: Correct DB column name
  @override
  @JsonKey(name: 'requester_id', fromJson: _idToString)
  final String? requesterId;
  @override
  @JsonKey(name: 'requester_name', fromJson: _idToString)
  final String? requesterName;
  @override
  @JsonKey(name: 'recipient_name', fromJson: _idToString)
  final String? recipientName;
  @override
  @JsonKey(name: 'recipient_office', fromJson: _idToString)
  final String? recipientOffice;
  @override
  @JsonKey(name: 'warehouse_id', fromJson: _idToString)
  final String? warehouseId;
  @override
  @JsonKey(name: 'bin_location', fromJson: _idToString)
  final String? binLocation;
  @override
  @JsonKey(name: 'forensic_note', fromJson: _idToString)
  final String? forensicNote;
  @override
  @JsonKey(name: 'forensic_image_url', fromJson: _idToString)
  final String? forensicImageUrl;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'LogisticsAction(id: $id, itemName: $itemName, itemId: $itemId, type: $type, status: $status, quantity: $quantity, requesterId: $requesterId, requesterName: $requesterName, recipientName: $recipientName, recipientOffice: $recipientOffice, warehouseId: $warehouseId, binLocation: $binLocation, forensicNote: $forensicNote, forensicImageUrl: $forensicImageUrl, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LogisticsActionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.requesterId, requesterId) ||
                other.requesterId == requesterId) &&
            (identical(other.requesterName, requesterName) ||
                other.requesterName == requesterName) &&
            (identical(other.recipientName, recipientName) ||
                other.recipientName == recipientName) &&
            (identical(other.recipientOffice, recipientOffice) ||
                other.recipientOffice == recipientOffice) &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.binLocation, binLocation) ||
                other.binLocation == binLocation) &&
            (identical(other.forensicNote, forensicNote) ||
                other.forensicNote == forensicNote) &&
            (identical(other.forensicImageUrl, forensicImageUrl) ||
                other.forensicImageUrl == forensicImageUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      itemName,
      itemId,
      type,
      status,
      quantity,
      requesterId,
      requesterName,
      recipientName,
      recipientOffice,
      warehouseId,
      binLocation,
      forensicNote,
      forensicImageUrl,
      createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LogisticsActionImplCopyWith<_$LogisticsActionImpl> get copyWith =>
      __$$LogisticsActionImplCopyWithImpl<_$LogisticsActionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LogisticsActionImplToJson(
      this,
    );
  }
}

abstract class _LogisticsAction extends LogisticsAction {
  const factory _LogisticsAction(
      {@JsonKey(fromJson: _idToString) required final String id,
      @JsonKey(name: 'item_name') required final String itemName,
      @JsonKey(name: 'item_id', fromJson: _idToString)
      required final String itemId,
      @JsonKey(name: 'type', fromJson: _typeFromJson)
      required final ActionType type,
      @JsonKey(fromJson: _statusFromJson) final ActionStatus status,
      @JsonKey(name: 'quantity', fromJson: _toInt) required final int quantity,
      @JsonKey(name: 'requester_id', fromJson: _idToString)
      final String? requesterId,
      @JsonKey(name: 'requester_name', fromJson: _idToString)
      final String? requesterName,
      @JsonKey(name: 'recipient_name', fromJson: _idToString)
      final String? recipientName,
      @JsonKey(name: 'recipient_office', fromJson: _idToString)
      final String? recipientOffice,
      @JsonKey(name: 'warehouse_id', fromJson: _idToString)
      final String? warehouseId,
      @JsonKey(name: 'bin_location', fromJson: _idToString)
      final String? binLocation,
      @JsonKey(name: 'forensic_note', fromJson: _idToString)
      final String? forensicNote,
      @JsonKey(name: 'forensic_image_url', fromJson: _idToString)
      final String? forensicImageUrl,
      @JsonKey(name: 'created_at')
      final DateTime? createdAt}) = _$LogisticsActionImpl;
  const _LogisticsAction._() : super._();

  factory _LogisticsAction.fromJson(Map<String, dynamic> json) =
      _$LogisticsActionImpl.fromJson;

  @override
  @JsonKey(fromJson: _idToString)
  String get id;
  @override
  @JsonKey(name: 'item_name')
  String get itemName;
  @override
  @JsonKey(name: 'item_id', fromJson: _idToString)
  String get itemId;
  @override // 🛡️ SYNC: Changed from inventory_id to item_id
  @JsonKey(name: 'type', fromJson: _typeFromJson)
  ActionType get type;
  @override // 🛡️ SYNC: Correct DB column name
  @JsonKey(fromJson: _statusFromJson)
  ActionStatus get status;
  @override
  @JsonKey(name: 'quantity', fromJson: _toInt)
  int get quantity;
  @override // 🛡️ SYNC: Correct DB column name
  @JsonKey(name: 'requester_id', fromJson: _idToString)
  String? get requesterId;
  @override
  @JsonKey(name: 'requester_name', fromJson: _idToString)
  String? get requesterName;
  @override
  @JsonKey(name: 'recipient_name', fromJson: _idToString)
  String? get recipientName;
  @override
  @JsonKey(name: 'recipient_office', fromJson: _idToString)
  String? get recipientOffice;
  @override
  @JsonKey(name: 'warehouse_id', fromJson: _idToString)
  String? get warehouseId;
  @override
  @JsonKey(name: 'bin_location', fromJson: _idToString)
  String? get binLocation;
  @override
  @JsonKey(name: 'forensic_note', fromJson: _idToString)
  String? get forensicNote;
  @override
  @JsonKey(name: 'forensic_image_url', fromJson: _idToString)
  String? get forensicImageUrl;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$LogisticsActionImplCopyWith<_$LogisticsActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
