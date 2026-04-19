// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$InventoryItem {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  int get totalStock => throw _privateConstructorUsedError;
  int get availableStock => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  String get qrCode => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get modelNumber => throw _privateConstructorUsedError;
  int get minStockLevel => throw _privateConstructorUsedError;
  int get targetStock => throw _privateConstructorUsedError;
  String get unit => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;
  DateTime? get expiryDate => throw _privateConstructorUsedError;
  int get expiryAlertDays => throw _privateConstructorUsedError;
  bool get isPendingSync => throw _privateConstructorUsedError;
  bool get restockAlertEnabled =>
      throw _privateConstructorUsedError; // Health buckets (mirrors web qty_* columns)
  int get qtyGood => throw _privateConstructorUsedError;
  int get qtyDamaged => throw _privateConstructorUsedError;
  int get qtyMaintenance => throw _privateConstructorUsedError;
  int get qtyLost =>
      throw _privateConstructorUsedError; // Hierarchical Location Support
  int? get parentId => throw _privateConstructorUsedError;
  int get aggregateTotal => throw _privateConstructorUsedError;
  int get aggregateAvailable => throw _privateConstructorUsedError;
  int? get locationRegistryId => throw _privateConstructorUsedError;
  List<InventoryVariant> get variants => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $InventoryItemCopyWith<InventoryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventoryItemCopyWith<$Res> {
  factory $InventoryItemCopyWith(
          InventoryItem value, $Res Function(InventoryItem) then) =
      _$InventoryItemCopyWithImpl<$Res, InventoryItem>;
  @useResult
  $Res call(
      {int id,
      String name,
      String description,
      String category,
      int totalStock,
      int availableStock,
      String location,
      String qrCode,
      String status,
      String code,
      String modelNumber,
      int minStockLevel,
      int targetStock,
      String unit,
      String? imageUrl,
      DateTime? lastUpdated,
      DateTime? expiryDate,
      int expiryAlertDays,
      bool isPendingSync,
      bool restockAlertEnabled,
      int qtyGood,
      int qtyDamaged,
      int qtyMaintenance,
      int qtyLost,
      int? parentId,
      int aggregateTotal,
      int aggregateAvailable,
      int? locationRegistryId,
      List<InventoryVariant> variants});
}

/// @nodoc
class _$InventoryItemCopyWithImpl<$Res, $Val extends InventoryItem>
    implements $InventoryItemCopyWith<$Res> {
  _$InventoryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? category = null,
    Object? totalStock = null,
    Object? availableStock = null,
    Object? location = null,
    Object? qrCode = null,
    Object? status = null,
    Object? code = null,
    Object? modelNumber = null,
    Object? minStockLevel = null,
    Object? targetStock = null,
    Object? unit = null,
    Object? imageUrl = freezed,
    Object? lastUpdated = freezed,
    Object? expiryDate = freezed,
    Object? expiryAlertDays = null,
    Object? isPendingSync = null,
    Object? restockAlertEnabled = null,
    Object? qtyGood = null,
    Object? qtyDamaged = null,
    Object? qtyMaintenance = null,
    Object? qtyLost = null,
    Object? parentId = freezed,
    Object? aggregateTotal = null,
    Object? aggregateAvailable = null,
    Object? locationRegistryId = freezed,
    Object? variants = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      totalStock: null == totalStock
          ? _value.totalStock
          : totalStock // ignore: cast_nullable_to_non_nullable
              as int,
      availableStock: null == availableStock
          ? _value.availableStock
          : availableStock // ignore: cast_nullable_to_non_nullable
              as int,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      qrCode: null == qrCode
          ? _value.qrCode
          : qrCode // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      modelNumber: null == modelNumber
          ? _value.modelNumber
          : modelNumber // ignore: cast_nullable_to_non_nullable
              as String,
      minStockLevel: null == minStockLevel
          ? _value.minStockLevel
          : minStockLevel // ignore: cast_nullable_to_non_nullable
              as int,
      targetStock: null == targetStock
          ? _value.targetStock
          : targetStock // ignore: cast_nullable_to_non_nullable
              as int,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expiryDate: freezed == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expiryAlertDays: null == expiryAlertDays
          ? _value.expiryAlertDays
          : expiryAlertDays // ignore: cast_nullable_to_non_nullable
              as int,
      isPendingSync: null == isPendingSync
          ? _value.isPendingSync
          : isPendingSync // ignore: cast_nullable_to_non_nullable
              as bool,
      restockAlertEnabled: null == restockAlertEnabled
          ? _value.restockAlertEnabled
          : restockAlertEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
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
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as int?,
      aggregateTotal: null == aggregateTotal
          ? _value.aggregateTotal
          : aggregateTotal // ignore: cast_nullable_to_non_nullable
              as int,
      aggregateAvailable: null == aggregateAvailable
          ? _value.aggregateAvailable
          : aggregateAvailable // ignore: cast_nullable_to_non_nullable
              as int,
      locationRegistryId: freezed == locationRegistryId
          ? _value.locationRegistryId
          : locationRegistryId // ignore: cast_nullable_to_non_nullable
              as int?,
      variants: null == variants
          ? _value.variants
          : variants // ignore: cast_nullable_to_non_nullable
              as List<InventoryVariant>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InventoryItemImplCopyWith<$Res>
    implements $InventoryItemCopyWith<$Res> {
  factory _$$InventoryItemImplCopyWith(
          _$InventoryItemImpl value, $Res Function(_$InventoryItemImpl) then) =
      __$$InventoryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String description,
      String category,
      int totalStock,
      int availableStock,
      String location,
      String qrCode,
      String status,
      String code,
      String modelNumber,
      int minStockLevel,
      int targetStock,
      String unit,
      String? imageUrl,
      DateTime? lastUpdated,
      DateTime? expiryDate,
      int expiryAlertDays,
      bool isPendingSync,
      bool restockAlertEnabled,
      int qtyGood,
      int qtyDamaged,
      int qtyMaintenance,
      int qtyLost,
      int? parentId,
      int aggregateTotal,
      int aggregateAvailable,
      int? locationRegistryId,
      List<InventoryVariant> variants});
}

/// @nodoc
class __$$InventoryItemImplCopyWithImpl<$Res>
    extends _$InventoryItemCopyWithImpl<$Res, _$InventoryItemImpl>
    implements _$$InventoryItemImplCopyWith<$Res> {
  __$$InventoryItemImplCopyWithImpl(
      _$InventoryItemImpl _value, $Res Function(_$InventoryItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? category = null,
    Object? totalStock = null,
    Object? availableStock = null,
    Object? location = null,
    Object? qrCode = null,
    Object? status = null,
    Object? code = null,
    Object? modelNumber = null,
    Object? minStockLevel = null,
    Object? targetStock = null,
    Object? unit = null,
    Object? imageUrl = freezed,
    Object? lastUpdated = freezed,
    Object? expiryDate = freezed,
    Object? expiryAlertDays = null,
    Object? isPendingSync = null,
    Object? restockAlertEnabled = null,
    Object? qtyGood = null,
    Object? qtyDamaged = null,
    Object? qtyMaintenance = null,
    Object? qtyLost = null,
    Object? parentId = freezed,
    Object? aggregateTotal = null,
    Object? aggregateAvailable = null,
    Object? locationRegistryId = freezed,
    Object? variants = null,
  }) {
    return _then(_$InventoryItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      totalStock: null == totalStock
          ? _value.totalStock
          : totalStock // ignore: cast_nullable_to_non_nullable
              as int,
      availableStock: null == availableStock
          ? _value.availableStock
          : availableStock // ignore: cast_nullable_to_non_nullable
              as int,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      qrCode: null == qrCode
          ? _value.qrCode
          : qrCode // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      modelNumber: null == modelNumber
          ? _value.modelNumber
          : modelNumber // ignore: cast_nullable_to_non_nullable
              as String,
      minStockLevel: null == minStockLevel
          ? _value.minStockLevel
          : minStockLevel // ignore: cast_nullable_to_non_nullable
              as int,
      targetStock: null == targetStock
          ? _value.targetStock
          : targetStock // ignore: cast_nullable_to_non_nullable
              as int,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expiryDate: freezed == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expiryAlertDays: null == expiryAlertDays
          ? _value.expiryAlertDays
          : expiryAlertDays // ignore: cast_nullable_to_non_nullable
              as int,
      isPendingSync: null == isPendingSync
          ? _value.isPendingSync
          : isPendingSync // ignore: cast_nullable_to_non_nullable
              as bool,
      restockAlertEnabled: null == restockAlertEnabled
          ? _value.restockAlertEnabled
          : restockAlertEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
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
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as int?,
      aggregateTotal: null == aggregateTotal
          ? _value.aggregateTotal
          : aggregateTotal // ignore: cast_nullable_to_non_nullable
              as int,
      aggregateAvailable: null == aggregateAvailable
          ? _value.aggregateAvailable
          : aggregateAvailable // ignore: cast_nullable_to_non_nullable
              as int,
      locationRegistryId: freezed == locationRegistryId
          ? _value.locationRegistryId
          : locationRegistryId // ignore: cast_nullable_to_non_nullable
              as int?,
      variants: null == variants
          ? _value._variants
          : variants // ignore: cast_nullable_to_non_nullable
              as List<InventoryVariant>,
    ));
  }
}

/// @nodoc

class _$InventoryItemImpl extends _InventoryItem {
  const _$InventoryItemImpl(
      {required this.id,
      required this.name,
      this.description = '',
      required this.category,
      this.totalStock = 0,
      this.availableStock = 0,
      this.location = '',
      this.qrCode = '',
      this.status = 'Good',
      this.code = '',
      this.modelNumber = '',
      this.minStockLevel = 10,
      this.targetStock = 0,
      this.unit = 'pcs',
      this.imageUrl,
      this.lastUpdated,
      this.expiryDate,
      this.expiryAlertDays = 15,
      this.isPendingSync = false,
      this.restockAlertEnabled = true,
      this.qtyGood = 0,
      this.qtyDamaged = 0,
      this.qtyMaintenance = 0,
      this.qtyLost = 0,
      this.parentId,
      this.aggregateTotal = 0,
      this.aggregateAvailable = 0,
      this.locationRegistryId,
      final List<InventoryVariant> variants = const []})
      : _variants = variants,
        super._();

  @override
  final int id;
  @override
  final String name;
  @override
  @JsonKey()
  final String description;
  @override
  final String category;
  @override
  @JsonKey()
  final int totalStock;
  @override
  @JsonKey()
  final int availableStock;
  @override
  @JsonKey()
  final String location;
  @override
  @JsonKey()
  final String qrCode;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final String code;
  @override
  @JsonKey()
  final String modelNumber;
  @override
  @JsonKey()
  final int minStockLevel;
  @override
  @JsonKey()
  final int targetStock;
  @override
  @JsonKey()
  final String unit;
  @override
  final String? imageUrl;
  @override
  final DateTime? lastUpdated;
  @override
  final DateTime? expiryDate;
  @override
  @JsonKey()
  final int expiryAlertDays;
  @override
  @JsonKey()
  final bool isPendingSync;
  @override
  @JsonKey()
  final bool restockAlertEnabled;
// Health buckets (mirrors web qty_* columns)
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
// Hierarchical Location Support
  @override
  final int? parentId;
  @override
  @JsonKey()
  final int aggregateTotal;
  @override
  @JsonKey()
  final int aggregateAvailable;
  @override
  final int? locationRegistryId;
  final List<InventoryVariant> _variants;
  @override
  @JsonKey()
  List<InventoryVariant> get variants {
    if (_variants is EqualUnmodifiableListView) return _variants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_variants);
  }

  @override
  String toString() {
    return 'InventoryItem(id: $id, name: $name, description: $description, category: $category, totalStock: $totalStock, availableStock: $availableStock, location: $location, qrCode: $qrCode, status: $status, code: $code, modelNumber: $modelNumber, minStockLevel: $minStockLevel, targetStock: $targetStock, unit: $unit, imageUrl: $imageUrl, lastUpdated: $lastUpdated, expiryDate: $expiryDate, expiryAlertDays: $expiryAlertDays, isPendingSync: $isPendingSync, restockAlertEnabled: $restockAlertEnabled, qtyGood: $qtyGood, qtyDamaged: $qtyDamaged, qtyMaintenance: $qtyMaintenance, qtyLost: $qtyLost, parentId: $parentId, aggregateTotal: $aggregateTotal, aggregateAvailable: $aggregateAvailable, locationRegistryId: $locationRegistryId, variants: $variants)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InventoryItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.totalStock, totalStock) ||
                other.totalStock == totalStock) &&
            (identical(other.availableStock, availableStock) ||
                other.availableStock == availableStock) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.qrCode, qrCode) || other.qrCode == qrCode) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.modelNumber, modelNumber) ||
                other.modelNumber == modelNumber) &&
            (identical(other.minStockLevel, minStockLevel) ||
                other.minStockLevel == minStockLevel) &&
            (identical(other.targetStock, targetStock) ||
                other.targetStock == targetStock) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.expiryAlertDays, expiryAlertDays) ||
                other.expiryAlertDays == expiryAlertDays) &&
            (identical(other.isPendingSync, isPendingSync) ||
                other.isPendingSync == isPendingSync) &&
            (identical(other.restockAlertEnabled, restockAlertEnabled) ||
                other.restockAlertEnabled == restockAlertEnabled) &&
            (identical(other.qtyGood, qtyGood) || other.qtyGood == qtyGood) &&
            (identical(other.qtyDamaged, qtyDamaged) ||
                other.qtyDamaged == qtyDamaged) &&
            (identical(other.qtyMaintenance, qtyMaintenance) ||
                other.qtyMaintenance == qtyMaintenance) &&
            (identical(other.qtyLost, qtyLost) || other.qtyLost == qtyLost) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.aggregateTotal, aggregateTotal) ||
                other.aggregateTotal == aggregateTotal) &&
            (identical(other.aggregateAvailable, aggregateAvailable) ||
                other.aggregateAvailable == aggregateAvailable) &&
            (identical(other.locationRegistryId, locationRegistryId) ||
                other.locationRegistryId == locationRegistryId) &&
            const DeepCollectionEquality().equals(other._variants, _variants));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        description,
        category,
        totalStock,
        availableStock,
        location,
        qrCode,
        status,
        code,
        modelNumber,
        minStockLevel,
        targetStock,
        unit,
        imageUrl,
        lastUpdated,
        expiryDate,
        expiryAlertDays,
        isPendingSync,
        restockAlertEnabled,
        qtyGood,
        qtyDamaged,
        qtyMaintenance,
        qtyLost,
        parentId,
        aggregateTotal,
        aggregateAvailable,
        locationRegistryId,
        const DeepCollectionEquality().hash(_variants)
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InventoryItemImplCopyWith<_$InventoryItemImpl> get copyWith =>
      __$$InventoryItemImplCopyWithImpl<_$InventoryItemImpl>(this, _$identity);
}

abstract class _InventoryItem extends InventoryItem {
  const factory _InventoryItem(
      {required final int id,
      required final String name,
      final String description,
      required final String category,
      final int totalStock,
      final int availableStock,
      final String location,
      final String qrCode,
      final String status,
      final String code,
      final String modelNumber,
      final int minStockLevel,
      final int targetStock,
      final String unit,
      final String? imageUrl,
      final DateTime? lastUpdated,
      final DateTime? expiryDate,
      final int expiryAlertDays,
      final bool isPendingSync,
      final bool restockAlertEnabled,
      final int qtyGood,
      final int qtyDamaged,
      final int qtyMaintenance,
      final int qtyLost,
      final int? parentId,
      final int aggregateTotal,
      final int aggregateAvailable,
      final int? locationRegistryId,
      final List<InventoryVariant> variants}) = _$InventoryItemImpl;
  const _InventoryItem._() : super._();

  @override
  int get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String get category;
  @override
  int get totalStock;
  @override
  int get availableStock;
  @override
  String get location;
  @override
  String get qrCode;
  @override
  String get status;
  @override
  String get code;
  @override
  String get modelNumber;
  @override
  int get minStockLevel;
  @override
  int get targetStock;
  @override
  String get unit;
  @override
  String? get imageUrl;
  @override
  DateTime? get lastUpdated;
  @override
  DateTime? get expiryDate;
  @override
  int get expiryAlertDays;
  @override
  bool get isPendingSync;
  @override
  bool get restockAlertEnabled;
  @override // Health buckets (mirrors web qty_* columns)
  int get qtyGood;
  @override
  int get qtyDamaged;
  @override
  int get qtyMaintenance;
  @override
  int get qtyLost;
  @override // Hierarchical Location Support
  int? get parentId;
  @override
  int get aggregateTotal;
  @override
  int get aggregateAvailable;
  @override
  int? get locationRegistryId;
  @override
  List<InventoryVariant> get variants;
  @override
  @JsonKey(ignore: true)
  _$$InventoryItemImplCopyWith<_$InventoryItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$InventoryVariant {
  int get id => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  int get stockAvailable => throw _privateConstructorUsedError;
  int get stockTotal => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int? get locationRegistryId =>
      throw _privateConstructorUsedError; // REGISTRY LINK
  /// Per-site health buckets (from `inventory` row / `active_inventory.variants` JSON).
  int get qtyGood => throw _privateConstructorUsedError;
  int get qtyDamaged => throw _privateConstructorUsedError;
  int get qtyMaintenance => throw _privateConstructorUsedError;
  int get qtyLost => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $InventoryVariantCopyWith<InventoryVariant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventoryVariantCopyWith<$Res> {
  factory $InventoryVariantCopyWith(
          InventoryVariant value, $Res Function(InventoryVariant) then) =
      _$InventoryVariantCopyWithImpl<$Res, InventoryVariant>;
  @useResult
  $Res call(
      {int id,
      String location,
      int stockAvailable,
      int stockTotal,
      String status,
      int? locationRegistryId,
      int qtyGood,
      int qtyDamaged,
      int qtyMaintenance,
      int qtyLost});
}

/// @nodoc
class _$InventoryVariantCopyWithImpl<$Res, $Val extends InventoryVariant>
    implements $InventoryVariantCopyWith<$Res> {
  _$InventoryVariantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? location = null,
    Object? stockAvailable = null,
    Object? stockTotal = null,
    Object? status = null,
    Object? locationRegistryId = freezed,
    Object? qtyGood = null,
    Object? qtyDamaged = null,
    Object? qtyMaintenance = null,
    Object? qtyLost = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      stockAvailable: null == stockAvailable
          ? _value.stockAvailable
          : stockAvailable // ignore: cast_nullable_to_non_nullable
              as int,
      stockTotal: null == stockTotal
          ? _value.stockTotal
          : stockTotal // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      locationRegistryId: freezed == locationRegistryId
          ? _value.locationRegistryId
          : locationRegistryId // ignore: cast_nullable_to_non_nullable
              as int?,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InventoryVariantImplCopyWith<$Res>
    implements $InventoryVariantCopyWith<$Res> {
  factory _$$InventoryVariantImplCopyWith(_$InventoryVariantImpl value,
          $Res Function(_$InventoryVariantImpl) then) =
      __$$InventoryVariantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String location,
      int stockAvailable,
      int stockTotal,
      String status,
      int? locationRegistryId,
      int qtyGood,
      int qtyDamaged,
      int qtyMaintenance,
      int qtyLost});
}

/// @nodoc
class __$$InventoryVariantImplCopyWithImpl<$Res>
    extends _$InventoryVariantCopyWithImpl<$Res, _$InventoryVariantImpl>
    implements _$$InventoryVariantImplCopyWith<$Res> {
  __$$InventoryVariantImplCopyWithImpl(_$InventoryVariantImpl _value,
      $Res Function(_$InventoryVariantImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? location = null,
    Object? stockAvailable = null,
    Object? stockTotal = null,
    Object? status = null,
    Object? locationRegistryId = freezed,
    Object? qtyGood = null,
    Object? qtyDamaged = null,
    Object? qtyMaintenance = null,
    Object? qtyLost = null,
  }) {
    return _then(_$InventoryVariantImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      stockAvailable: null == stockAvailable
          ? _value.stockAvailable
          : stockAvailable // ignore: cast_nullable_to_non_nullable
              as int,
      stockTotal: null == stockTotal
          ? _value.stockTotal
          : stockTotal // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      locationRegistryId: freezed == locationRegistryId
          ? _value.locationRegistryId
          : locationRegistryId // ignore: cast_nullable_to_non_nullable
              as int?,
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
    ));
  }
}

/// @nodoc

class _$InventoryVariantImpl implements _InventoryVariant {
  const _$InventoryVariantImpl(
      {required this.id,
      required this.location,
      required this.stockAvailable,
      required this.stockTotal,
      required this.status,
      this.locationRegistryId,
      this.qtyGood = 0,
      this.qtyDamaged = 0,
      this.qtyMaintenance = 0,
      this.qtyLost = 0});

  @override
  final int id;
  @override
  final String location;
  @override
  final int stockAvailable;
  @override
  final int stockTotal;
  @override
  final String status;
  @override
  final int? locationRegistryId;
// REGISTRY LINK
  /// Per-site health buckets (from `inventory` row / `active_inventory.variants` JSON).
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
  String toString() {
    return 'InventoryVariant(id: $id, location: $location, stockAvailable: $stockAvailable, stockTotal: $stockTotal, status: $status, locationRegistryId: $locationRegistryId, qtyGood: $qtyGood, qtyDamaged: $qtyDamaged, qtyMaintenance: $qtyMaintenance, qtyLost: $qtyLost)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InventoryVariantImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.stockAvailable, stockAvailable) ||
                other.stockAvailable == stockAvailable) &&
            (identical(other.stockTotal, stockTotal) ||
                other.stockTotal == stockTotal) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.locationRegistryId, locationRegistryId) ||
                other.locationRegistryId == locationRegistryId) &&
            (identical(other.qtyGood, qtyGood) || other.qtyGood == qtyGood) &&
            (identical(other.qtyDamaged, qtyDamaged) ||
                other.qtyDamaged == qtyDamaged) &&
            (identical(other.qtyMaintenance, qtyMaintenance) ||
                other.qtyMaintenance == qtyMaintenance) &&
            (identical(other.qtyLost, qtyLost) || other.qtyLost == qtyLost));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      location,
      stockAvailable,
      stockTotal,
      status,
      locationRegistryId,
      qtyGood,
      qtyDamaged,
      qtyMaintenance,
      qtyLost);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InventoryVariantImplCopyWith<_$InventoryVariantImpl> get copyWith =>
      __$$InventoryVariantImplCopyWithImpl<_$InventoryVariantImpl>(
          this, _$identity);
}

abstract class _InventoryVariant implements InventoryVariant {
  const factory _InventoryVariant(
      {required final int id,
      required final String location,
      required final int stockAvailable,
      required final int stockTotal,
      required final String status,
      final int? locationRegistryId,
      final int qtyGood,
      final int qtyDamaged,
      final int qtyMaintenance,
      final int qtyLost}) = _$InventoryVariantImpl;

  @override
  int get id;
  @override
  String get location;
  @override
  int get stockAvailable;
  @override
  int get stockTotal;
  @override
  String get status;
  @override
  int? get locationRegistryId;
  @override // REGISTRY LINK
  /// Per-site health buckets (from `inventory` row / `active_inventory.variants` JSON).
  int get qtyGood;
  @override
  int get qtyDamaged;
  @override
  int get qtyMaintenance;
  @override
  int get qtyLost;
  @override
  @JsonKey(ignore: true)
  _$$InventoryVariantImplCopyWith<_$InventoryVariantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
