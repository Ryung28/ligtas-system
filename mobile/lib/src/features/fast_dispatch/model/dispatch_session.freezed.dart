// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dispatch_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BorrowerInfo _$BorrowerInfoFromJson(Map<String, dynamic> json) {
  return _BorrowerInfo.fromJson(json);
}

/// @nodoc
mixin _$BorrowerInfo {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get contact => throw _privateConstructorUsedError;
  String? get office => throw _privateConstructorUsedError;
  bool get isDraft => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BorrowerInfoCopyWith<BorrowerInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BorrowerInfoCopyWith<$Res> {
  factory $BorrowerInfoCopyWith(
          BorrowerInfo value, $Res Function(BorrowerInfo) then) =
      _$BorrowerInfoCopyWithImpl<$Res, BorrowerInfo>;
  @useResult
  $Res call(
      {String id, String name, String contact, String? office, bool isDraft});
}

/// @nodoc
class _$BorrowerInfoCopyWithImpl<$Res, $Val extends BorrowerInfo>
    implements $BorrowerInfoCopyWith<$Res> {
  _$BorrowerInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? contact = null,
    Object? office = freezed,
    Object? isDraft = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      contact: null == contact
          ? _value.contact
          : contact // ignore: cast_nullable_to_non_nullable
              as String,
      office: freezed == office
          ? _value.office
          : office // ignore: cast_nullable_to_non_nullable
              as String?,
      isDraft: null == isDraft
          ? _value.isDraft
          : isDraft // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BorrowerInfoImplCopyWith<$Res>
    implements $BorrowerInfoCopyWith<$Res> {
  factory _$$BorrowerInfoImplCopyWith(
          _$BorrowerInfoImpl value, $Res Function(_$BorrowerInfoImpl) then) =
      __$$BorrowerInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id, String name, String contact, String? office, bool isDraft});
}

/// @nodoc
class __$$BorrowerInfoImplCopyWithImpl<$Res>
    extends _$BorrowerInfoCopyWithImpl<$Res, _$BorrowerInfoImpl>
    implements _$$BorrowerInfoImplCopyWith<$Res> {
  __$$BorrowerInfoImplCopyWithImpl(
      _$BorrowerInfoImpl _value, $Res Function(_$BorrowerInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? contact = null,
    Object? office = freezed,
    Object? isDraft = null,
  }) {
    return _then(_$BorrowerInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      contact: null == contact
          ? _value.contact
          : contact // ignore: cast_nullable_to_non_nullable
              as String,
      office: freezed == office
          ? _value.office
          : office // ignore: cast_nullable_to_non_nullable
              as String?,
      isDraft: null == isDraft
          ? _value.isDraft
          : isDraft // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BorrowerInfoImpl implements _BorrowerInfo {
  const _$BorrowerInfoImpl(
      {required this.id,
      required this.name,
      required this.contact,
      this.office,
      this.isDraft = false});

  factory _$BorrowerInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$BorrowerInfoImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String contact;
  @override
  final String? office;
  @override
  @JsonKey()
  final bool isDraft;

  @override
  String toString() {
    return 'BorrowerInfo(id: $id, name: $name, contact: $contact, office: $office, isDraft: $isDraft)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BorrowerInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.contact, contact) || other.contact == contact) &&
            (identical(other.office, office) || other.office == office) &&
            (identical(other.isDraft, isDraft) || other.isDraft == isDraft));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, contact, office, isDraft);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BorrowerInfoImplCopyWith<_$BorrowerInfoImpl> get copyWith =>
      __$$BorrowerInfoImplCopyWithImpl<_$BorrowerInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BorrowerInfoImplToJson(
      this,
    );
  }
}

abstract class _BorrowerInfo implements BorrowerInfo {
  const factory _BorrowerInfo(
      {required final String id,
      required final String name,
      required final String contact,
      final String? office,
      final bool isDraft}) = _$BorrowerInfoImpl;

  factory _BorrowerInfo.fromJson(Map<String, dynamic> json) =
      _$BorrowerInfoImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get contact;
  @override
  String? get office;
  @override
  bool get isDraft;
  @override
  @JsonKey(ignore: true)
  _$$BorrowerInfoImplCopyWith<_$BorrowerInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DispatchItem _$DispatchItemFromJson(Map<String, dynamic> json) {
  return _DispatchItem.fromJson(json);
}

/// @nodoc
mixin _$DispatchItem {
  int get inventoryId => throw _privateConstructorUsedError;
  String get itemName => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  int get stockAvailable => throw _privateConstructorUsedError;
  int get targetStock => throw _privateConstructorUsedError;
  int get lowStockThreshold => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DispatchItemCopyWith<DispatchItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DispatchItemCopyWith<$Res> {
  factory $DispatchItemCopyWith(
          DispatchItem value, $Res Function(DispatchItem) then) =
      _$DispatchItemCopyWithImpl<$Res, DispatchItem>;
  @useResult
  $Res call(
      {int inventoryId,
      String itemName,
      String? imageUrl,
      int quantity,
      int stockAvailable,
      int targetStock,
      int lowStockThreshold});
}

/// @nodoc
class _$DispatchItemCopyWithImpl<$Res, $Val extends DispatchItem>
    implements $DispatchItemCopyWith<$Res> {
  _$DispatchItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inventoryId = null,
    Object? itemName = null,
    Object? imageUrl = freezed,
    Object? quantity = null,
    Object? stockAvailable = null,
    Object? targetStock = null,
    Object? lowStockThreshold = null,
  }) {
    return _then(_value.copyWith(
      inventoryId: null == inventoryId
          ? _value.inventoryId
          : inventoryId // ignore: cast_nullable_to_non_nullable
              as int,
      itemName: null == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      stockAvailable: null == stockAvailable
          ? _value.stockAvailable
          : stockAvailable // ignore: cast_nullable_to_non_nullable
              as int,
      targetStock: null == targetStock
          ? _value.targetStock
          : targetStock // ignore: cast_nullable_to_non_nullable
              as int,
      lowStockThreshold: null == lowStockThreshold
          ? _value.lowStockThreshold
          : lowStockThreshold // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DispatchItemImplCopyWith<$Res>
    implements $DispatchItemCopyWith<$Res> {
  factory _$$DispatchItemImplCopyWith(
          _$DispatchItemImpl value, $Res Function(_$DispatchItemImpl) then) =
      __$$DispatchItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int inventoryId,
      String itemName,
      String? imageUrl,
      int quantity,
      int stockAvailable,
      int targetStock,
      int lowStockThreshold});
}

/// @nodoc
class __$$DispatchItemImplCopyWithImpl<$Res>
    extends _$DispatchItemCopyWithImpl<$Res, _$DispatchItemImpl>
    implements _$$DispatchItemImplCopyWith<$Res> {
  __$$DispatchItemImplCopyWithImpl(
      _$DispatchItemImpl _value, $Res Function(_$DispatchItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inventoryId = null,
    Object? itemName = null,
    Object? imageUrl = freezed,
    Object? quantity = null,
    Object? stockAvailable = null,
    Object? targetStock = null,
    Object? lowStockThreshold = null,
  }) {
    return _then(_$DispatchItemImpl(
      inventoryId: null == inventoryId
          ? _value.inventoryId
          : inventoryId // ignore: cast_nullable_to_non_nullable
              as int,
      itemName: null == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      stockAvailable: null == stockAvailable
          ? _value.stockAvailable
          : stockAvailable // ignore: cast_nullable_to_non_nullable
              as int,
      targetStock: null == targetStock
          ? _value.targetStock
          : targetStock // ignore: cast_nullable_to_non_nullable
              as int,
      lowStockThreshold: null == lowStockThreshold
          ? _value.lowStockThreshold
          : lowStockThreshold // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DispatchItemImpl implements _DispatchItem {
  const _$DispatchItemImpl(
      {required this.inventoryId,
      required this.itemName,
      this.imageUrl,
      this.quantity = 1,
      this.stockAvailable = 0,
      this.targetStock = 0,
      this.lowStockThreshold = 20});

  factory _$DispatchItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$DispatchItemImplFromJson(json);

  @override
  final int inventoryId;
  @override
  final String itemName;
  @override
  final String? imageUrl;
  @override
  @JsonKey()
  final int quantity;
  @override
  @JsonKey()
  final int stockAvailable;
  @override
  @JsonKey()
  final int targetStock;
  @override
  @JsonKey()
  final int lowStockThreshold;

  @override
  String toString() {
    return 'DispatchItem(inventoryId: $inventoryId, itemName: $itemName, imageUrl: $imageUrl, quantity: $quantity, stockAvailable: $stockAvailable, targetStock: $targetStock, lowStockThreshold: $lowStockThreshold)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DispatchItemImpl &&
            (identical(other.inventoryId, inventoryId) ||
                other.inventoryId == inventoryId) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.stockAvailable, stockAvailable) ||
                other.stockAvailable == stockAvailable) &&
            (identical(other.targetStock, targetStock) ||
                other.targetStock == targetStock) &&
            (identical(other.lowStockThreshold, lowStockThreshold) ||
                other.lowStockThreshold == lowStockThreshold));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, inventoryId, itemName, imageUrl,
      quantity, stockAvailable, targetStock, lowStockThreshold);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DispatchItemImplCopyWith<_$DispatchItemImpl> get copyWith =>
      __$$DispatchItemImplCopyWithImpl<_$DispatchItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DispatchItemImplToJson(
      this,
    );
  }
}

abstract class _DispatchItem implements DispatchItem {
  const factory _DispatchItem(
      {required final int inventoryId,
      required final String itemName,
      final String? imageUrl,
      final int quantity,
      final int stockAvailable,
      final int targetStock,
      final int lowStockThreshold}) = _$DispatchItemImpl;

  factory _DispatchItem.fromJson(Map<String, dynamic> json) =
      _$DispatchItemImpl.fromJson;

  @override
  int get inventoryId;
  @override
  String get itemName;
  @override
  String? get imageUrl;
  @override
  int get quantity;
  @override
  int get stockAvailable;
  @override
  int get targetStock;
  @override
  int get lowStockThreshold;
  @override
  @JsonKey(ignore: true)
  _$$DispatchItemImplCopyWith<_$DispatchItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DispatchState {
  BorrowerInfo? get borrower => throw _privateConstructorUsedError;
  DispatchItem? get selectedItem => throw _privateConstructorUsedError;
  String? get approvedBy => throw _privateConstructorUsedError;
  bool get isSubmitting => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DispatchStateCopyWith<DispatchState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DispatchStateCopyWith<$Res> {
  factory $DispatchStateCopyWith(
          DispatchState value, $Res Function(DispatchState) then) =
      _$DispatchStateCopyWithImpl<$Res, DispatchState>;
  @useResult
  $Res call(
      {BorrowerInfo? borrower,
      DispatchItem? selectedItem,
      String? approvedBy,
      bool isSubmitting,
      String? error});

  $BorrowerInfoCopyWith<$Res>? get borrower;
  $DispatchItemCopyWith<$Res>? get selectedItem;
}

/// @nodoc
class _$DispatchStateCopyWithImpl<$Res, $Val extends DispatchState>
    implements $DispatchStateCopyWith<$Res> {
  _$DispatchStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? borrower = freezed,
    Object? selectedItem = freezed,
    Object? approvedBy = freezed,
    Object? isSubmitting = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      borrower: freezed == borrower
          ? _value.borrower
          : borrower // ignore: cast_nullable_to_non_nullable
              as BorrowerInfo?,
      selectedItem: freezed == selectedItem
          ? _value.selectedItem
          : selectedItem // ignore: cast_nullable_to_non_nullable
              as DispatchItem?,
      approvedBy: freezed == approvedBy
          ? _value.approvedBy
          : approvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BorrowerInfoCopyWith<$Res>? get borrower {
    if (_value.borrower == null) {
      return null;
    }

    return $BorrowerInfoCopyWith<$Res>(_value.borrower!, (value) {
      return _then(_value.copyWith(borrower: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $DispatchItemCopyWith<$Res>? get selectedItem {
    if (_value.selectedItem == null) {
      return null;
    }

    return $DispatchItemCopyWith<$Res>(_value.selectedItem!, (value) {
      return _then(_value.copyWith(selectedItem: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DispatchStateImplCopyWith<$Res>
    implements $DispatchStateCopyWith<$Res> {
  factory _$$DispatchStateImplCopyWith(
          _$DispatchStateImpl value, $Res Function(_$DispatchStateImpl) then) =
      __$$DispatchStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {BorrowerInfo? borrower,
      DispatchItem? selectedItem,
      String? approvedBy,
      bool isSubmitting,
      String? error});

  @override
  $BorrowerInfoCopyWith<$Res>? get borrower;
  @override
  $DispatchItemCopyWith<$Res>? get selectedItem;
}

/// @nodoc
class __$$DispatchStateImplCopyWithImpl<$Res>
    extends _$DispatchStateCopyWithImpl<$Res, _$DispatchStateImpl>
    implements _$$DispatchStateImplCopyWith<$Res> {
  __$$DispatchStateImplCopyWithImpl(
      _$DispatchStateImpl _value, $Res Function(_$DispatchStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? borrower = freezed,
    Object? selectedItem = freezed,
    Object? approvedBy = freezed,
    Object? isSubmitting = null,
    Object? error = freezed,
  }) {
    return _then(_$DispatchStateImpl(
      borrower: freezed == borrower
          ? _value.borrower
          : borrower // ignore: cast_nullable_to_non_nullable
              as BorrowerInfo?,
      selectedItem: freezed == selectedItem
          ? _value.selectedItem
          : selectedItem // ignore: cast_nullable_to_non_nullable
              as DispatchItem?,
      approvedBy: freezed == approvedBy
          ? _value.approvedBy
          : approvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$DispatchStateImpl implements _DispatchState {
  const _$DispatchStateImpl(
      {this.borrower,
      this.selectedItem,
      this.approvedBy,
      this.isSubmitting = false,
      this.error});

  @override
  final BorrowerInfo? borrower;
  @override
  final DispatchItem? selectedItem;
  @override
  final String? approvedBy;
  @override
  @JsonKey()
  final bool isSubmitting;
  @override
  final String? error;

  @override
  String toString() {
    return 'DispatchState(borrower: $borrower, selectedItem: $selectedItem, approvedBy: $approvedBy, isSubmitting: $isSubmitting, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DispatchStateImpl &&
            (identical(other.borrower, borrower) ||
                other.borrower == borrower) &&
            (identical(other.selectedItem, selectedItem) ||
                other.selectedItem == selectedItem) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, borrower, selectedItem, approvedBy, isSubmitting, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DispatchStateImplCopyWith<_$DispatchStateImpl> get copyWith =>
      __$$DispatchStateImplCopyWithImpl<_$DispatchStateImpl>(this, _$identity);
}

abstract class _DispatchState implements DispatchState {
  const factory _DispatchState(
      {final BorrowerInfo? borrower,
      final DispatchItem? selectedItem,
      final String? approvedBy,
      final bool isSubmitting,
      final String? error}) = _$DispatchStateImpl;

  @override
  BorrowerInfo? get borrower;
  @override
  DispatchItem? get selectedItem;
  @override
  String? get approvedBy;
  @override
  bool get isSubmitting;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$DispatchStateImplCopyWith<_$DispatchStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
