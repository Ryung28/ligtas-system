// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'station_manifest.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StationManifestItem _$StationManifestItemFromJson(Map<String, dynamic> json) {
  return _StationManifestItem.fromJson(json);
}

/// @nodoc
mixin _$StationManifestItem {
  String get id => throw _privateConstructorUsedError;
  String get stationId => throw _privateConstructorUsedError;
  int get inventoryId => throw _privateConstructorUsedError;
  int get quantityRequired => throw _privateConstructorUsedError;
  String get itemName => throw _privateConstructorUsedError;
  String? get itemCategory => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  int get currentStock => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StationManifestItemCopyWith<StationManifestItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StationManifestItemCopyWith<$Res> {
  factory $StationManifestItemCopyWith(
          StationManifestItem value, $Res Function(StationManifestItem) then) =
      _$StationManifestItemCopyWithImpl<$Res, StationManifestItem>;
  @useResult
  $Res call(
      {String id,
      String stationId,
      int inventoryId,
      int quantityRequired,
      String itemName,
      String? itemCategory,
      String? imageUrl,
      int currentStock});
}

/// @nodoc
class _$StationManifestItemCopyWithImpl<$Res, $Val extends StationManifestItem>
    implements $StationManifestItemCopyWith<$Res> {
  _$StationManifestItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stationId = null,
    Object? inventoryId = null,
    Object? quantityRequired = null,
    Object? itemName = null,
    Object? itemCategory = freezed,
    Object? imageUrl = freezed,
    Object? currentStock = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      stationId: null == stationId
          ? _value.stationId
          : stationId // ignore: cast_nullable_to_non_nullable
              as String,
      inventoryId: null == inventoryId
          ? _value.inventoryId
          : inventoryId // ignore: cast_nullable_to_non_nullable
              as int,
      quantityRequired: null == quantityRequired
          ? _value.quantityRequired
          : quantityRequired // ignore: cast_nullable_to_non_nullable
              as int,
      itemName: null == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String,
      itemCategory: freezed == itemCategory
          ? _value.itemCategory
          : itemCategory // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      currentStock: null == currentStock
          ? _value.currentStock
          : currentStock // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StationManifestItemImplCopyWith<$Res>
    implements $StationManifestItemCopyWith<$Res> {
  factory _$$StationManifestItemImplCopyWith(_$StationManifestItemImpl value,
          $Res Function(_$StationManifestItemImpl) then) =
      __$$StationManifestItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String stationId,
      int inventoryId,
      int quantityRequired,
      String itemName,
      String? itemCategory,
      String? imageUrl,
      int currentStock});
}

/// @nodoc
class __$$StationManifestItemImplCopyWithImpl<$Res>
    extends _$StationManifestItemCopyWithImpl<$Res, _$StationManifestItemImpl>
    implements _$$StationManifestItemImplCopyWith<$Res> {
  __$$StationManifestItemImplCopyWithImpl(_$StationManifestItemImpl _value,
      $Res Function(_$StationManifestItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stationId = null,
    Object? inventoryId = null,
    Object? quantityRequired = null,
    Object? itemName = null,
    Object? itemCategory = freezed,
    Object? imageUrl = freezed,
    Object? currentStock = null,
  }) {
    return _then(_$StationManifestItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      stationId: null == stationId
          ? _value.stationId
          : stationId // ignore: cast_nullable_to_non_nullable
              as String,
      inventoryId: null == inventoryId
          ? _value.inventoryId
          : inventoryId // ignore: cast_nullable_to_non_nullable
              as int,
      quantityRequired: null == quantityRequired
          ? _value.quantityRequired
          : quantityRequired // ignore: cast_nullable_to_non_nullable
              as int,
      itemName: null == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String,
      itemCategory: freezed == itemCategory
          ? _value.itemCategory
          : itemCategory // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      currentStock: null == currentStock
          ? _value.currentStock
          : currentStock // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StationManifestItemImpl implements _StationManifestItem {
  const _$StationManifestItemImpl(
      {required this.id,
      required this.stationId,
      required this.inventoryId,
      required this.quantityRequired,
      required this.itemName,
      this.itemCategory,
      this.imageUrl,
      this.currentStock = 0});

  factory _$StationManifestItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$StationManifestItemImplFromJson(json);

  @override
  final String id;
  @override
  final String stationId;
  @override
  final int inventoryId;
  @override
  final int quantityRequired;
  @override
  final String itemName;
  @override
  final String? itemCategory;
  @override
  final String? imageUrl;
  @override
  @JsonKey()
  final int currentStock;

  @override
  String toString() {
    return 'StationManifestItem(id: $id, stationId: $stationId, inventoryId: $inventoryId, quantityRequired: $quantityRequired, itemName: $itemName, itemCategory: $itemCategory, imageUrl: $imageUrl, currentStock: $currentStock)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StationManifestItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.stationId, stationId) ||
                other.stationId == stationId) &&
            (identical(other.inventoryId, inventoryId) ||
                other.inventoryId == inventoryId) &&
            (identical(other.quantityRequired, quantityRequired) ||
                other.quantityRequired == quantityRequired) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.itemCategory, itemCategory) ||
                other.itemCategory == itemCategory) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.currentStock, currentStock) ||
                other.currentStock == currentStock));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, stationId, inventoryId,
      quantityRequired, itemName, itemCategory, imageUrl, currentStock);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StationManifestItemImplCopyWith<_$StationManifestItemImpl> get copyWith =>
      __$$StationManifestItemImplCopyWithImpl<_$StationManifestItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StationManifestItemImplToJson(
      this,
    );
  }
}

abstract class _StationManifestItem implements StationManifestItem {
  const factory _StationManifestItem(
      {required final String id,
      required final String stationId,
      required final int inventoryId,
      required final int quantityRequired,
      required final String itemName,
      final String? itemCategory,
      final String? imageUrl,
      final int currentStock}) = _$StationManifestItemImpl;

  factory _StationManifestItem.fromJson(Map<String, dynamic> json) =
      _$StationManifestItemImpl.fromJson;

  @override
  String get id;
  @override
  String get stationId;
  @override
  int get inventoryId;
  @override
  int get quantityRequired;
  @override
  String get itemName;
  @override
  String? get itemCategory;
  @override
  String? get imageUrl;
  @override
  int get currentStock;
  @override
  @JsonKey(ignore: true)
  _$$StationManifestItemImplCopyWith<_$StationManifestItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
