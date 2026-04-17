// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'manager_action_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ManagerActionFormState {
// ── Active mode ──
  ManagerMode get mode =>
      throw _privateConstructorUsedError; // ── Shared across all modes ──
  String get note => throw _privateConstructorUsedError;
  String? get localImageUrl =>
      throw _privateConstructorUsedError; // ── Restock + Edit: bucket distribution ──
  int get qtyGood => throw _privateConstructorUsedError;
  int get qtyDamaged => throw _privateConstructorUsedError;
  int get qtyMaintenance => throw _privateConstructorUsedError;
  int get qtyLost => throw _privateConstructorUsedError;
  String get storageLocation => throw _privateConstructorUsedError;
  int? get locationRegistryId =>
      throw _privateConstructorUsedError; // ── Handover + Reserve: dispatch fields ──
  int get quantity => throw _privateConstructorUsedError;
  String get recipientName => throw _privateConstructorUsedError;
  String get recipientOffice => throw _privateConstructorUsedError;
  String get recipientContact => throw _privateConstructorUsedError;
  String get approvedBy => throw _privateConstructorUsedError;
  String get releasedBy => throw _privateConstructorUsedError;
  DateTime? get expectedReturnDate => throw _privateConstructorUsedError;
  DateTime? get pickupScheduledAt => throw _privateConstructorUsedError;
  bool get isDateReturn =>
      throw _privateConstructorUsedError; // ── Edit: metadata fields ──
  String get itemName => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get serial => throw _privateConstructorUsedError;
  String get model => throw _privateConstructorUsedError;
  int get targetStock => throw _privateConstructorUsedError;
  int get minStock => throw _privateConstructorUsedError; // ── UI lifecycle ──
  bool get isEditLoading => throw _privateConstructorUsedError;
  bool get isSubmitting => throw _privateConstructorUsedError;
  String? get submitError => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ManagerActionFormStateCopyWith<ManagerActionFormState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ManagerActionFormStateCopyWith<$Res> {
  factory $ManagerActionFormStateCopyWith(ManagerActionFormState value,
          $Res Function(ManagerActionFormState) then) =
      _$ManagerActionFormStateCopyWithImpl<$Res, ManagerActionFormState>;
  @useResult
  $Res call(
      {ManagerMode mode,
      String note,
      String? localImageUrl,
      int qtyGood,
      int qtyDamaged,
      int qtyMaintenance,
      int qtyLost,
      String storageLocation,
      int? locationRegistryId,
      int quantity,
      String recipientName,
      String recipientOffice,
      String recipientContact,
      String approvedBy,
      String releasedBy,
      DateTime? expectedReturnDate,
      DateTime? pickupScheduledAt,
      bool isDateReturn,
      String itemName,
      String category,
      String serial,
      String model,
      int targetStock,
      int minStock,
      bool isEditLoading,
      bool isSubmitting,
      String? submitError});
}

/// @nodoc
class _$ManagerActionFormStateCopyWithImpl<$Res,
        $Val extends ManagerActionFormState>
    implements $ManagerActionFormStateCopyWith<$Res> {
  _$ManagerActionFormStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? note = null,
    Object? localImageUrl = freezed,
    Object? qtyGood = null,
    Object? qtyDamaged = null,
    Object? qtyMaintenance = null,
    Object? qtyLost = null,
    Object? storageLocation = null,
    Object? locationRegistryId = freezed,
    Object? quantity = null,
    Object? recipientName = null,
    Object? recipientOffice = null,
    Object? recipientContact = null,
    Object? approvedBy = null,
    Object? releasedBy = null,
    Object? expectedReturnDate = freezed,
    Object? pickupScheduledAt = freezed,
    Object? isDateReturn = null,
    Object? itemName = null,
    Object? category = null,
    Object? serial = null,
    Object? model = null,
    Object? targetStock = null,
    Object? minStock = null,
    Object? isEditLoading = null,
    Object? isSubmitting = null,
    Object? submitError = freezed,
  }) {
    return _then(_value.copyWith(
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as ManagerMode,
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
      localImageUrl: freezed == localImageUrl
          ? _value.localImageUrl
          : localImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      qtyGood: null == qtyGood
          ? _value.qtyGood
          : qtyGood // ignore: cast_nullable_to_non_nullable
              as int,
      qtyDamaged: null == qtyDamaged
          ? _value.qtyDamaged
          : qtyDamaged // ignore: cast_nullable_to_non_nullable
              as int,
      qtyMaintenance: null == qtyMaintenance
          ? _value.qtyMaintenance
          : qtyMaintenance // ignore: cast_nullable_to_non_nullable
              as int,
      qtyLost: null == qtyLost
          ? _value.qtyLost
          : qtyLost // ignore: cast_nullable_to_non_nullable
              as int,
      storageLocation: null == storageLocation
          ? _value.storageLocation
          : storageLocation // ignore: cast_nullable_to_non_nullable
              as String,
      locationRegistryId: freezed == locationRegistryId
          ? _value.locationRegistryId
          : locationRegistryId // ignore: cast_nullable_to_non_nullable
              as int?,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      recipientName: null == recipientName
          ? _value.recipientName
          : recipientName // ignore: cast_nullable_to_non_nullable
              as String,
      recipientOffice: null == recipientOffice
          ? _value.recipientOffice
          : recipientOffice // ignore: cast_nullable_to_non_nullable
              as String,
      recipientContact: null == recipientContact
          ? _value.recipientContact
          : recipientContact // ignore: cast_nullable_to_non_nullable
              as String,
      approvedBy: null == approvedBy
          ? _value.approvedBy
          : approvedBy // ignore: cast_nullable_to_non_nullable
              as String,
      releasedBy: null == releasedBy
          ? _value.releasedBy
          : releasedBy // ignore: cast_nullable_to_non_nullable
              as String,
      expectedReturnDate: freezed == expectedReturnDate
          ? _value.expectedReturnDate
          : expectedReturnDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pickupScheduledAt: freezed == pickupScheduledAt
          ? _value.pickupScheduledAt
          : pickupScheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isDateReturn: null == isDateReturn
          ? _value.isDateReturn
          : isDateReturn // ignore: cast_nullable_to_non_nullable
              as bool,
      itemName: null == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      serial: null == serial
          ? _value.serial
          : serial // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      targetStock: null == targetStock
          ? _value.targetStock
          : targetStock // ignore: cast_nullable_to_non_nullable
              as int,
      minStock: null == minStock
          ? _value.minStock
          : minStock // ignore: cast_nullable_to_non_nullable
              as int,
      isEditLoading: null == isEditLoading
          ? _value.isEditLoading
          : isEditLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      submitError: freezed == submitError
          ? _value.submitError
          : submitError // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ManagerActionFormStateImplCopyWith<$Res>
    implements $ManagerActionFormStateCopyWith<$Res> {
  factory _$$ManagerActionFormStateImplCopyWith(
          _$ManagerActionFormStateImpl value,
          $Res Function(_$ManagerActionFormStateImpl) then) =
      __$$ManagerActionFormStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ManagerMode mode,
      String note,
      String? localImageUrl,
      int qtyGood,
      int qtyDamaged,
      int qtyMaintenance,
      int qtyLost,
      String storageLocation,
      int? locationRegistryId,
      int quantity,
      String recipientName,
      String recipientOffice,
      String recipientContact,
      String approvedBy,
      String releasedBy,
      DateTime? expectedReturnDate,
      DateTime? pickupScheduledAt,
      bool isDateReturn,
      String itemName,
      String category,
      String serial,
      String model,
      int targetStock,
      int minStock,
      bool isEditLoading,
      bool isSubmitting,
      String? submitError});
}

/// @nodoc
class __$$ManagerActionFormStateImplCopyWithImpl<$Res>
    extends _$ManagerActionFormStateCopyWithImpl<$Res,
        _$ManagerActionFormStateImpl>
    implements _$$ManagerActionFormStateImplCopyWith<$Res> {
  __$$ManagerActionFormStateImplCopyWithImpl(
      _$ManagerActionFormStateImpl _value,
      $Res Function(_$ManagerActionFormStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? note = null,
    Object? localImageUrl = freezed,
    Object? qtyGood = null,
    Object? qtyDamaged = null,
    Object? qtyMaintenance = null,
    Object? qtyLost = null,
    Object? storageLocation = null,
    Object? locationRegistryId = freezed,
    Object? quantity = null,
    Object? recipientName = null,
    Object? recipientOffice = null,
    Object? recipientContact = null,
    Object? approvedBy = null,
    Object? releasedBy = null,
    Object? expectedReturnDate = freezed,
    Object? pickupScheduledAt = freezed,
    Object? isDateReturn = null,
    Object? itemName = null,
    Object? category = null,
    Object? serial = null,
    Object? model = null,
    Object? targetStock = null,
    Object? minStock = null,
    Object? isEditLoading = null,
    Object? isSubmitting = null,
    Object? submitError = freezed,
  }) {
    return _then(_$ManagerActionFormStateImpl(
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as ManagerMode,
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
      localImageUrl: freezed == localImageUrl
          ? _value.localImageUrl
          : localImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      qtyGood: null == qtyGood
          ? _value.qtyGood
          : qtyGood // ignore: cast_nullable_to_non_nullable
              as int,
      qtyDamaged: null == qtyDamaged
          ? _value.qtyDamaged
          : qtyDamaged // ignore: cast_nullable_to_non_nullable
              as int,
      qtyMaintenance: null == qtyMaintenance
          ? _value.qtyMaintenance
          : qtyMaintenance // ignore: cast_nullable_to_non_nullable
              as int,
      qtyLost: null == qtyLost
          ? _value.qtyLost
          : qtyLost // ignore: cast_nullable_to_non_nullable
              as int,
      storageLocation: null == storageLocation
          ? _value.storageLocation
          : storageLocation // ignore: cast_nullable_to_non_nullable
              as String,
      locationRegistryId: freezed == locationRegistryId
          ? _value.locationRegistryId
          : locationRegistryId // ignore: cast_nullable_to_non_nullable
              as int?,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      recipientName: null == recipientName
          ? _value.recipientName
          : recipientName // ignore: cast_nullable_to_non_nullable
              as String,
      recipientOffice: null == recipientOffice
          ? _value.recipientOffice
          : recipientOffice // ignore: cast_nullable_to_non_nullable
              as String,
      recipientContact: null == recipientContact
          ? _value.recipientContact
          : recipientContact // ignore: cast_nullable_to_non_nullable
              as String,
      approvedBy: null == approvedBy
          ? _value.approvedBy
          : approvedBy // ignore: cast_nullable_to_non_nullable
              as String,
      releasedBy: null == releasedBy
          ? _value.releasedBy
          : releasedBy // ignore: cast_nullable_to_non_nullable
              as String,
      expectedReturnDate: freezed == expectedReturnDate
          ? _value.expectedReturnDate
          : expectedReturnDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pickupScheduledAt: freezed == pickupScheduledAt
          ? _value.pickupScheduledAt
          : pickupScheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isDateReturn: null == isDateReturn
          ? _value.isDateReturn
          : isDateReturn // ignore: cast_nullable_to_non_nullable
              as bool,
      itemName: null == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      serial: null == serial
          ? _value.serial
          : serial // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      targetStock: null == targetStock
          ? _value.targetStock
          : targetStock // ignore: cast_nullable_to_non_nullable
              as int,
      minStock: null == minStock
          ? _value.minStock
          : minStock // ignore: cast_nullable_to_non_nullable
              as int,
      isEditLoading: null == isEditLoading
          ? _value.isEditLoading
          : isEditLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      submitError: freezed == submitError
          ? _value.submitError
          : submitError // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ManagerActionFormStateImpl implements _ManagerActionFormState {
  const _$ManagerActionFormStateImpl(
      {this.mode = ManagerMode.edit,
      this.note = '',
      this.localImageUrl,
      this.qtyGood = 0,
      this.qtyDamaged = 0,
      this.qtyMaintenance = 0,
      this.qtyLost = 0,
      this.storageLocation = '',
      this.locationRegistryId,
      this.quantity = 1,
      this.recipientName = '',
      this.recipientOffice = '',
      this.recipientContact = '',
      this.approvedBy = '',
      this.releasedBy = '',
      this.expectedReturnDate,
      this.pickupScheduledAt,
      this.isDateReturn = false,
      this.itemName = '',
      this.category = '',
      this.serial = '',
      this.model = '',
      this.targetStock = 0,
      this.minStock = 0,
      this.isEditLoading = false,
      this.isSubmitting = false,
      this.submitError});

// ── Active mode ──
  @override
  @JsonKey()
  final ManagerMode mode;
// ── Shared across all modes ──
  @override
  @JsonKey()
  final String note;
  @override
  final String? localImageUrl;
// ── Restock + Edit: bucket distribution ──
  @override
  @JsonKey()
  final int qtyGood;
  @override
  @JsonKey()
  final int qtyDamaged;
  @override
  @JsonKey()
  final int qtyMaintenance;
  @override
  @JsonKey()
  final int qtyLost;
  @override
  @JsonKey()
  final String storageLocation;
  @override
  final int? locationRegistryId;
// ── Handover + Reserve: dispatch fields ──
  @override
  @JsonKey()
  final int quantity;
  @override
  @JsonKey()
  final String recipientName;
  @override
  @JsonKey()
  final String recipientOffice;
  @override
  @JsonKey()
  final String recipientContact;
  @override
  @JsonKey()
  final String approvedBy;
  @override
  @JsonKey()
  final String releasedBy;
  @override
  final DateTime? expectedReturnDate;
  @override
  final DateTime? pickupScheduledAt;
  @override
  @JsonKey()
  final bool isDateReturn;
// ── Edit: metadata fields ──
  @override
  @JsonKey()
  final String itemName;
  @override
  @JsonKey()
  final String category;
  @override
  @JsonKey()
  final String serial;
  @override
  @JsonKey()
  final String model;
  @override
  @JsonKey()
  final int targetStock;
  @override
  @JsonKey()
  final int minStock;
// ── UI lifecycle ──
  @override
  @JsonKey()
  final bool isEditLoading;
  @override
  @JsonKey()
  final bool isSubmitting;
  @override
  final String? submitError;

  @override
  String toString() {
    return 'ManagerActionFormState(mode: $mode, note: $note, localImageUrl: $localImageUrl, qtyGood: $qtyGood, qtyDamaged: $qtyDamaged, qtyMaintenance: $qtyMaintenance, qtyLost: $qtyLost, storageLocation: $storageLocation, locationRegistryId: $locationRegistryId, quantity: $quantity, recipientName: $recipientName, recipientOffice: $recipientOffice, recipientContact: $recipientContact, approvedBy: $approvedBy, releasedBy: $releasedBy, expectedReturnDate: $expectedReturnDate, pickupScheduledAt: $pickupScheduledAt, isDateReturn: $isDateReturn, itemName: $itemName, category: $category, serial: $serial, model: $model, targetStock: $targetStock, minStock: $minStock, isEditLoading: $isEditLoading, isSubmitting: $isSubmitting, submitError: $submitError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ManagerActionFormStateImpl &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.localImageUrl, localImageUrl) ||
                other.localImageUrl == localImageUrl) &&
            (identical(other.qtyGood, qtyGood) || other.qtyGood == qtyGood) &&
            (identical(other.qtyDamaged, qtyDamaged) ||
                other.qtyDamaged == qtyDamaged) &&
            (identical(other.qtyMaintenance, qtyMaintenance) ||
                other.qtyMaintenance == qtyMaintenance) &&
            (identical(other.qtyLost, qtyLost) || other.qtyLost == qtyLost) &&
            (identical(other.storageLocation, storageLocation) ||
                other.storageLocation == storageLocation) &&
            (identical(other.locationRegistryId, locationRegistryId) ||
                other.locationRegistryId == locationRegistryId) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.recipientName, recipientName) ||
                other.recipientName == recipientName) &&
            (identical(other.recipientOffice, recipientOffice) ||
                other.recipientOffice == recipientOffice) &&
            (identical(other.recipientContact, recipientContact) ||
                other.recipientContact == recipientContact) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy) &&
            (identical(other.releasedBy, releasedBy) ||
                other.releasedBy == releasedBy) &&
            (identical(other.expectedReturnDate, expectedReturnDate) ||
                other.expectedReturnDate == expectedReturnDate) &&
            (identical(other.pickupScheduledAt, pickupScheduledAt) ||
                other.pickupScheduledAt == pickupScheduledAt) &&
            (identical(other.isDateReturn, isDateReturn) ||
                other.isDateReturn == isDateReturn) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.serial, serial) || other.serial == serial) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.targetStock, targetStock) ||
                other.targetStock == targetStock) &&
            (identical(other.minStock, minStock) ||
                other.minStock == minStock) &&
            (identical(other.isEditLoading, isEditLoading) ||
                other.isEditLoading == isEditLoading) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.submitError, submitError) ||
                other.submitError == submitError));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        mode,
        note,
        localImageUrl,
        qtyGood,
        qtyDamaged,
        qtyMaintenance,
        qtyLost,
        storageLocation,
        locationRegistryId,
        quantity,
        recipientName,
        recipientOffice,
        recipientContact,
        approvedBy,
        releasedBy,
        expectedReturnDate,
        pickupScheduledAt,
        isDateReturn,
        itemName,
        category,
        serial,
        model,
        targetStock,
        minStock,
        isEditLoading,
        isSubmitting,
        submitError
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ManagerActionFormStateImplCopyWith<_$ManagerActionFormStateImpl>
      get copyWith => __$$ManagerActionFormStateImplCopyWithImpl<
          _$ManagerActionFormStateImpl>(this, _$identity);
}

abstract class _ManagerActionFormState implements ManagerActionFormState {
  const factory _ManagerActionFormState(
      {final ManagerMode mode,
      final String note,
      final String? localImageUrl,
      final int qtyGood,
      final int qtyDamaged,
      final int qtyMaintenance,
      final int qtyLost,
      final String storageLocation,
      final int? locationRegistryId,
      final int quantity,
      final String recipientName,
      final String recipientOffice,
      final String recipientContact,
      final String approvedBy,
      final String releasedBy,
      final DateTime? expectedReturnDate,
      final DateTime? pickupScheduledAt,
      final bool isDateReturn,
      final String itemName,
      final String category,
      final String serial,
      final String model,
      final int targetStock,
      final int minStock,
      final bool isEditLoading,
      final bool isSubmitting,
      final String? submitError}) = _$ManagerActionFormStateImpl;

  @override // ── Active mode ──
  ManagerMode get mode;
  @override // ── Shared across all modes ──
  String get note;
  @override
  String? get localImageUrl;
  @override // ── Restock + Edit: bucket distribution ──
  int get qtyGood;
  @override
  int get qtyDamaged;
  @override
  int get qtyMaintenance;
  @override
  int get qtyLost;
  @override
  String get storageLocation;
  @override
  int? get locationRegistryId;
  @override // ── Handover + Reserve: dispatch fields ──
  int get quantity;
  @override
  String get recipientName;
  @override
  String get recipientOffice;
  @override
  String get recipientContact;
  @override
  String get approvedBy;
  @override
  String get releasedBy;
  @override
  DateTime? get expectedReturnDate;
  @override
  DateTime? get pickupScheduledAt;
  @override
  bool get isDateReturn;
  @override // ── Edit: metadata fields ──
  String get itemName;
  @override
  String get category;
  @override
  String get serial;
  @override
  String get model;
  @override
  int get targetStock;
  @override
  int get minStock;
  @override // ── UI lifecycle ──
  bool get isEditLoading;
  @override
  bool get isSubmitting;
  @override
  String? get submitError;
  @override
  @JsonKey(ignore: true)
  _$$ManagerActionFormStateImplCopyWith<_$ManagerActionFormStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
