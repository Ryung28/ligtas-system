// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) {
  return _TransactionModel.fromJson(json);
}

/// @nodoc
mixin _$TransactionModel {
  int? get id => throw _privateConstructorUsedError;
  int get inventoryId => throw _privateConstructorUsedError;
  String get borrowerName => throw _privateConstructorUsedError;
  String get borrowerContact => throw _privateConstructorUsedError;
  String get purpose => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  DateTime get borrowDate => throw _privateConstructorUsedError;
  DateTime? get returnDate => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // 'borrowed', 'returned', 'overdue'
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  bool get isPendingSync => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TransactionModelCopyWith<TransactionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionModelCopyWith<$Res> {
  factory $TransactionModelCopyWith(
          TransactionModel value, $Res Function(TransactionModel) then) =
      _$TransactionModelCopyWithImpl<$Res, TransactionModel>;
  @useResult
  $Res call(
      {int? id,
      int inventoryId,
      String borrowerName,
      String borrowerContact,
      String purpose,
      int quantity,
      DateTime borrowDate,
      DateTime? returnDate,
      String status,
      DateTime createdAt,
      DateTime? updatedAt,
      bool isPendingSync});
}

/// @nodoc
class _$TransactionModelCopyWithImpl<$Res, $Val extends TransactionModel>
    implements $TransactionModelCopyWith<$Res> {
  _$TransactionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? inventoryId = null,
    Object? borrowerName = null,
    Object? borrowerContact = null,
    Object? purpose = null,
    Object? quantity = null,
    Object? borrowDate = null,
    Object? returnDate = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? isPendingSync = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      inventoryId: null == inventoryId
          ? _value.inventoryId
          : inventoryId // ignore: cast_nullable_to_non_nullable
              as int,
      borrowerName: null == borrowerName
          ? _value.borrowerName
          : borrowerName // ignore: cast_nullable_to_non_nullable
              as String,
      borrowerContact: null == borrowerContact
          ? _value.borrowerContact
          : borrowerContact // ignore: cast_nullable_to_non_nullable
              as String,
      purpose: null == purpose
          ? _value.purpose
          : purpose // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      borrowDate: null == borrowDate
          ? _value.borrowDate
          : borrowDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      returnDate: freezed == returnDate
          ? _value.returnDate
          : returnDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isPendingSync: null == isPendingSync
          ? _value.isPendingSync
          : isPendingSync // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransactionModelImplCopyWith<$Res>
    implements $TransactionModelCopyWith<$Res> {
  factory _$$TransactionModelImplCopyWith(_$TransactionModelImpl value,
          $Res Function(_$TransactionModelImpl) then) =
      __$$TransactionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      int inventoryId,
      String borrowerName,
      String borrowerContact,
      String purpose,
      int quantity,
      DateTime borrowDate,
      DateTime? returnDate,
      String status,
      DateTime createdAt,
      DateTime? updatedAt,
      bool isPendingSync});
}

/// @nodoc
class __$$TransactionModelImplCopyWithImpl<$Res>
    extends _$TransactionModelCopyWithImpl<$Res, _$TransactionModelImpl>
    implements _$$TransactionModelImplCopyWith<$Res> {
  __$$TransactionModelImplCopyWithImpl(_$TransactionModelImpl _value,
      $Res Function(_$TransactionModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? inventoryId = null,
    Object? borrowerName = null,
    Object? borrowerContact = null,
    Object? purpose = null,
    Object? quantity = null,
    Object? borrowDate = null,
    Object? returnDate = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? isPendingSync = null,
  }) {
    return _then(_$TransactionModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      inventoryId: null == inventoryId
          ? _value.inventoryId
          : inventoryId // ignore: cast_nullable_to_non_nullable
              as int,
      borrowerName: null == borrowerName
          ? _value.borrowerName
          : borrowerName // ignore: cast_nullable_to_non_nullable
              as String,
      borrowerContact: null == borrowerContact
          ? _value.borrowerContact
          : borrowerContact // ignore: cast_nullable_to_non_nullable
              as String,
      purpose: null == purpose
          ? _value.purpose
          : purpose // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      borrowDate: null == borrowDate
          ? _value.borrowDate
          : borrowDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      returnDate: freezed == returnDate
          ? _value.returnDate
          : returnDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isPendingSync: null == isPendingSync
          ? _value.isPendingSync
          : isPendingSync // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TransactionModelImpl implements _TransactionModel {
  const _$TransactionModelImpl(
      {this.id,
      required this.inventoryId,
      required this.borrowerName,
      required this.borrowerContact,
      required this.purpose,
      required this.quantity,
      required this.borrowDate,
      this.returnDate,
      required this.status,
      required this.createdAt,
      this.updatedAt,
      this.isPendingSync = false});

  factory _$TransactionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionModelImplFromJson(json);

  @override
  final int? id;
  @override
  final int inventoryId;
  @override
  final String borrowerName;
  @override
  final String borrowerContact;
  @override
  final String purpose;
  @override
  final int quantity;
  @override
  final DateTime borrowDate;
  @override
  final DateTime? returnDate;
  @override
  final String status;
// 'borrowed', 'returned', 'overdue'
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final bool isPendingSync;

  @override
  String toString() {
    return 'TransactionModel(id: $id, inventoryId: $inventoryId, borrowerName: $borrowerName, borrowerContact: $borrowerContact, purpose: $purpose, quantity: $quantity, borrowDate: $borrowDate, returnDate: $returnDate, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, isPendingSync: $isPendingSync)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.inventoryId, inventoryId) ||
                other.inventoryId == inventoryId) &&
            (identical(other.borrowerName, borrowerName) ||
                other.borrowerName == borrowerName) &&
            (identical(other.borrowerContact, borrowerContact) ||
                other.borrowerContact == borrowerContact) &&
            (identical(other.purpose, purpose) || other.purpose == purpose) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.borrowDate, borrowDate) ||
                other.borrowDate == borrowDate) &&
            (identical(other.returnDate, returnDate) ||
                other.returnDate == returnDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isPendingSync, isPendingSync) ||
                other.isPendingSync == isPendingSync));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      inventoryId,
      borrowerName,
      borrowerContact,
      purpose,
      quantity,
      borrowDate,
      returnDate,
      status,
      createdAt,
      updatedAt,
      isPendingSync);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionModelImplCopyWith<_$TransactionModelImpl> get copyWith =>
      __$$TransactionModelImplCopyWithImpl<_$TransactionModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionModelImplToJson(
      this,
    );
  }
}

abstract class _TransactionModel implements TransactionModel {
  const factory _TransactionModel(
      {final int? id,
      required final int inventoryId,
      required final String borrowerName,
      required final String borrowerContact,
      required final String purpose,
      required final int quantity,
      required final DateTime borrowDate,
      final DateTime? returnDate,
      required final String status,
      required final DateTime createdAt,
      final DateTime? updatedAt,
      final bool isPendingSync}) = _$TransactionModelImpl;

  factory _TransactionModel.fromJson(Map<String, dynamic> json) =
      _$TransactionModelImpl.fromJson;

  @override
  int? get id;
  @override
  int get inventoryId;
  @override
  String get borrowerName;
  @override
  String get borrowerContact;
  @override
  String get purpose;
  @override
  int get quantity;
  @override
  DateTime get borrowDate;
  @override
  DateTime? get returnDate;
  @override
  String get status;
  @override // 'borrowed', 'returned', 'overdue'
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  bool get isPendingSync;
  @override
  @JsonKey(ignore: true)
  _$$TransactionModelImplCopyWith<_$TransactionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
