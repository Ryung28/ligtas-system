// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

InventoryModel _$InventoryModelFromJson(Map<String, dynamic> json) {
  return _InventoryModel.fromJson(json);
}

/// @nodoc
mixin _$InventoryModel {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name')
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_total')
  int get quantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_available')
  int get available => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  String get qrCode => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  int get minStockLevel => throw _privateConstructorUsedError;
  String get unit => throw _privateConstructorUsedError;
  String get supplier => throw _privateConstructorUsedError;
  String get supplierContact => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String get imageUrl =>
      throw _privateConstructorUsedError; // Multi-location fields
  @JsonKey(name: 'aggregate_total')
  int get aggregateTotal => throw _privateConstructorUsedError;
  @JsonKey(name: 'aggregate_available')
  int get aggregateAvailable => throw _privateConstructorUsedError;
  @JsonKey(name: 'primary_location')
  String? get primaryLocation => throw _privateConstructorUsedError;
  @JsonKey(name: 'primary_stock_available')
  int get primaryAvailable => throw _privateConstructorUsedError;
  @JsonKey(name: 'location_registry_id')
  int? get locationRegistryId =>
      throw _privateConstructorUsedError; // MASTER IDENTITY ANCHOR
  List<Map<String, dynamic>> get variants => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InventoryModelCopyWith<InventoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventoryModelCopyWith<$Res> {
  factory $InventoryModelCopyWith(
          InventoryModel value, $Res Function(InventoryModel) then) =
      _$InventoryModelCopyWithImpl<$Res, InventoryModel>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'item_name') String name,
      String description,
      String category,
      @JsonKey(name: 'stock_total') int quantity,
      @JsonKey(name: 'stock_available') int available,
      String location,
      String qrCode,
      String status,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      String code,
      int minStockLevel,
      String unit,
      String supplier,
      String supplierContact,
      String notes,
      @JsonKey(name: 'image_url') String imageUrl,
      @JsonKey(name: 'aggregate_total') int aggregateTotal,
      @JsonKey(name: 'aggregate_available') int aggregateAvailable,
      @JsonKey(name: 'primary_location') String? primaryLocation,
      @JsonKey(name: 'primary_stock_available') int primaryAvailable,
      @JsonKey(name: 'location_registry_id') int? locationRegistryId,
      List<Map<String, dynamic>> variants});
}

/// @nodoc
class _$InventoryModelCopyWithImpl<$Res, $Val extends InventoryModel>
    implements $InventoryModelCopyWith<$Res> {
  _$InventoryModelCopyWithImpl(this._value, this._then);

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
    Object? quantity = null,
    Object? available = null,
    Object? location = null,
    Object? qrCode = null,
    Object? status = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? code = null,
    Object? minStockLevel = null,
    Object? unit = null,
    Object? supplier = null,
    Object? supplierContact = null,
    Object? notes = null,
    Object? imageUrl = null,
    Object? aggregateTotal = null,
    Object? aggregateAvailable = null,
    Object? primaryLocation = freezed,
    Object? primaryAvailable = null,
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
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      available: null == available
          ? _value.available
          : available // ignore: cast_nullable_to_non_nullable
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
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      minStockLevel: null == minStockLevel
          ? _value.minStockLevel
          : minStockLevel // ignore: cast_nullable_to_non_nullable
              as int,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      supplier: null == supplier
          ? _value.supplier
          : supplier // ignore: cast_nullable_to_non_nullable
              as String,
      supplierContact: null == supplierContact
          ? _value.supplierContact
          : supplierContact // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      aggregateTotal: null == aggregateTotal
          ? _value.aggregateTotal
          : aggregateTotal // ignore: cast_nullable_to_non_nullable
              as int,
      aggregateAvailable: null == aggregateAvailable
          ? _value.aggregateAvailable
          : aggregateAvailable // ignore: cast_nullable_to_non_nullable
              as int,
      primaryLocation: freezed == primaryLocation
          ? _value.primaryLocation
          : primaryLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      primaryAvailable: null == primaryAvailable
          ? _value.primaryAvailable
          : primaryAvailable // ignore: cast_nullable_to_non_nullable
              as int,
      locationRegistryId: freezed == locationRegistryId
          ? _value.locationRegistryId
          : locationRegistryId // ignore: cast_nullable_to_non_nullable
              as int?,
      variants: null == variants
          ? _value.variants
          : variants // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InventoryModelImplCopyWith<$Res>
    implements $InventoryModelCopyWith<$Res> {
  factory _$$InventoryModelImplCopyWith(_$InventoryModelImpl value,
          $Res Function(_$InventoryModelImpl) then) =
      __$$InventoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'item_name') String name,
      String description,
      String category,
      @JsonKey(name: 'stock_total') int quantity,
      @JsonKey(name: 'stock_available') int available,
      String location,
      String qrCode,
      String status,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      String code,
      int minStockLevel,
      String unit,
      String supplier,
      String supplierContact,
      String notes,
      @JsonKey(name: 'image_url') String imageUrl,
      @JsonKey(name: 'aggregate_total') int aggregateTotal,
      @JsonKey(name: 'aggregate_available') int aggregateAvailable,
      @JsonKey(name: 'primary_location') String? primaryLocation,
      @JsonKey(name: 'primary_stock_available') int primaryAvailable,
      @JsonKey(name: 'location_registry_id') int? locationRegistryId,
      List<Map<String, dynamic>> variants});
}

/// @nodoc
class __$$InventoryModelImplCopyWithImpl<$Res>
    extends _$InventoryModelCopyWithImpl<$Res, _$InventoryModelImpl>
    implements _$$InventoryModelImplCopyWith<$Res> {
  __$$InventoryModelImplCopyWithImpl(
      _$InventoryModelImpl _value, $Res Function(_$InventoryModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? category = null,
    Object? quantity = null,
    Object? available = null,
    Object? location = null,
    Object? qrCode = null,
    Object? status = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? code = null,
    Object? minStockLevel = null,
    Object? unit = null,
    Object? supplier = null,
    Object? supplierContact = null,
    Object? notes = null,
    Object? imageUrl = null,
    Object? aggregateTotal = null,
    Object? aggregateAvailable = null,
    Object? primaryLocation = freezed,
    Object? primaryAvailable = null,
    Object? locationRegistryId = freezed,
    Object? variants = null,
  }) {
    return _then(_$InventoryModelImpl(
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
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      available: null == available
          ? _value.available
          : available // ignore: cast_nullable_to_non_nullable
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
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      minStockLevel: null == minStockLevel
          ? _value.minStockLevel
          : minStockLevel // ignore: cast_nullable_to_non_nullable
              as int,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      supplier: null == supplier
          ? _value.supplier
          : supplier // ignore: cast_nullable_to_non_nullable
              as String,
      supplierContact: null == supplierContact
          ? _value.supplierContact
          : supplierContact // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      aggregateTotal: null == aggregateTotal
          ? _value.aggregateTotal
          : aggregateTotal // ignore: cast_nullable_to_non_nullable
              as int,
      aggregateAvailable: null == aggregateAvailable
          ? _value.aggregateAvailable
          : aggregateAvailable // ignore: cast_nullable_to_non_nullable
              as int,
      primaryLocation: freezed == primaryLocation
          ? _value.primaryLocation
          : primaryLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      primaryAvailable: null == primaryAvailable
          ? _value.primaryAvailable
          : primaryAvailable // ignore: cast_nullable_to_non_nullable
              as int,
      locationRegistryId: freezed == locationRegistryId
          ? _value.locationRegistryId
          : locationRegistryId // ignore: cast_nullable_to_non_nullable
              as int?,
      variants: null == variants
          ? _value._variants
          : variants // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InventoryModelImpl implements _InventoryModel {
  const _$InventoryModelImpl(
      {required this.id,
      @JsonKey(name: 'item_name') required this.name,
      this.description = '',
      required this.category,
      @JsonKey(name: 'stock_total') this.quantity = 0,
      @JsonKey(name: 'stock_available') this.available = 0,
      this.location = '',
      this.qrCode = '',
      this.status = 'Good',
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      this.code = '',
      this.minStockLevel = 10,
      this.unit = 'pcs',
      this.supplier = '',
      this.supplierContact = '',
      this.notes = '',
      @JsonKey(name: 'image_url') this.imageUrl = '',
      @JsonKey(name: 'aggregate_total') this.aggregateTotal = 0,
      @JsonKey(name: 'aggregate_available') this.aggregateAvailable = 0,
      @JsonKey(name: 'primary_location') this.primaryLocation,
      @JsonKey(name: 'primary_stock_available') this.primaryAvailable = 0,
      @JsonKey(name: 'location_registry_id') this.locationRegistryId,
      final List<Map<String, dynamic>> variants = const []})
      : _variants = variants;

  factory _$InventoryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$InventoryModelImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'item_name')
  final String name;
  @override
  @JsonKey()
  final String description;
  @override
  final String category;
  @override
  @JsonKey(name: 'stock_total')
  final int quantity;
  @override
  @JsonKey(name: 'stock_available')
  final int available;
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
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final String code;
  @override
  @JsonKey()
  final int minStockLevel;
  @override
  @JsonKey()
  final String unit;
  @override
  @JsonKey()
  final String supplier;
  @override
  @JsonKey()
  final String supplierContact;
  @override
  @JsonKey()
  final String notes;
  @override
  @JsonKey(name: 'image_url')
  final String imageUrl;
// Multi-location fields
  @override
  @JsonKey(name: 'aggregate_total')
  final int aggregateTotal;
  @override
  @JsonKey(name: 'aggregate_available')
  final int aggregateAvailable;
  @override
  @JsonKey(name: 'primary_location')
  final String? primaryLocation;
  @override
  @JsonKey(name: 'primary_stock_available')
  final int primaryAvailable;
  @override
  @JsonKey(name: 'location_registry_id')
  final int? locationRegistryId;
// MASTER IDENTITY ANCHOR
  final List<Map<String, dynamic>> _variants;
// MASTER IDENTITY ANCHOR
  @override
  @JsonKey()
  List<Map<String, dynamic>> get variants {
    if (_variants is EqualUnmodifiableListView) return _variants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_variants);
  }

  @override
  String toString() {
    return 'InventoryModel(id: $id, name: $name, description: $description, category: $category, quantity: $quantity, available: $available, location: $location, qrCode: $qrCode, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, code: $code, minStockLevel: $minStockLevel, unit: $unit, supplier: $supplier, supplierContact: $supplierContact, notes: $notes, imageUrl: $imageUrl, aggregateTotal: $aggregateTotal, aggregateAvailable: $aggregateAvailable, primaryLocation: $primaryLocation, primaryAvailable: $primaryAvailable, locationRegistryId: $locationRegistryId, variants: $variants)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InventoryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.available, available) ||
                other.available == available) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.qrCode, qrCode) || other.qrCode == qrCode) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.minStockLevel, minStockLevel) ||
                other.minStockLevel == minStockLevel) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.supplier, supplier) ||
                other.supplier == supplier) &&
            (identical(other.supplierContact, supplierContact) ||
                other.supplierContact == supplierContact) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.aggregateTotal, aggregateTotal) ||
                other.aggregateTotal == aggregateTotal) &&
            (identical(other.aggregateAvailable, aggregateAvailable) ||
                other.aggregateAvailable == aggregateAvailable) &&
            (identical(other.primaryLocation, primaryLocation) ||
                other.primaryLocation == primaryLocation) &&
            (identical(other.primaryAvailable, primaryAvailable) ||
                other.primaryAvailable == primaryAvailable) &&
            (identical(other.locationRegistryId, locationRegistryId) ||
                other.locationRegistryId == locationRegistryId) &&
            const DeepCollectionEquality().equals(other._variants, _variants));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        description,
        category,
        quantity,
        available,
        location,
        qrCode,
        status,
        createdAt,
        updatedAt,
        code,
        minStockLevel,
        unit,
        supplier,
        supplierContact,
        notes,
        imageUrl,
        aggregateTotal,
        aggregateAvailable,
        primaryLocation,
        primaryAvailable,
        locationRegistryId,
        const DeepCollectionEquality().hash(_variants)
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InventoryModelImplCopyWith<_$InventoryModelImpl> get copyWith =>
      __$$InventoryModelImplCopyWithImpl<_$InventoryModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InventoryModelImplToJson(
      this,
    );
  }
}

abstract class _InventoryModel implements InventoryModel {
  const factory _InventoryModel(
      {required final int id,
      @JsonKey(name: 'item_name') required final String name,
      final String description,
      required final String category,
      @JsonKey(name: 'stock_total') final int quantity,
      @JsonKey(name: 'stock_available') final int available,
      final String location,
      final String qrCode,
      final String status,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt,
      final String code,
      final int minStockLevel,
      final String unit,
      final String supplier,
      final String supplierContact,
      final String notes,
      @JsonKey(name: 'image_url') final String imageUrl,
      @JsonKey(name: 'aggregate_total') final int aggregateTotal,
      @JsonKey(name: 'aggregate_available') final int aggregateAvailable,
      @JsonKey(name: 'primary_location') final String? primaryLocation,
      @JsonKey(name: 'primary_stock_available') final int primaryAvailable,
      @JsonKey(name: 'location_registry_id') final int? locationRegistryId,
      final List<Map<String, dynamic>> variants}) = _$InventoryModelImpl;

  factory _InventoryModel.fromJson(Map<String, dynamic> json) =
      _$InventoryModelImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'item_name')
  String get name;
  @override
  String get description;
  @override
  String get category;
  @override
  @JsonKey(name: 'stock_total')
  int get quantity;
  @override
  @JsonKey(name: 'stock_available')
  int get available;
  @override
  String get location;
  @override
  String get qrCode;
  @override
  String get status;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  String get code;
  @override
  int get minStockLevel;
  @override
  String get unit;
  @override
  String get supplier;
  @override
  String get supplierContact;
  @override
  String get notes;
  @override
  @JsonKey(name: 'image_url')
  String get imageUrl;
  @override // Multi-location fields
  @JsonKey(name: 'aggregate_total')
  int get aggregateTotal;
  @override
  @JsonKey(name: 'aggregate_available')
  int get aggregateAvailable;
  @override
  @JsonKey(name: 'primary_location')
  String? get primaryLocation;
  @override
  @JsonKey(name: 'primary_stock_available')
  int get primaryAvailable;
  @override
  @JsonKey(name: 'location_registry_id')
  int? get locationRegistryId;
  @override // MASTER IDENTITY ANCHOR
  List<Map<String, dynamic>> get variants;
  @override
  @JsonKey(ignore: true)
  _$$InventoryModelImplCopyWith<_$InventoryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
