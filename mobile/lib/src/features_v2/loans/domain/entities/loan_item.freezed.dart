// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'loan_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LoanItem {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String? get userId =>
      throw _privateConstructorUsedError; // Supports multi-tenant isolation
  String get inventoryItemId => throw _privateConstructorUsedError;
  String get itemName => throw _privateConstructorUsedError;
  String get itemCode => throw _privateConstructorUsedError;
  String get borrowerName => throw _privateConstructorUsedError;
  String get borrowerContact => throw _privateConstructorUsedError;
  String get borrowerEmail => throw _privateConstructorUsedError;
  String get purpose => throw _privateConstructorUsedError;
  int get quantityBorrowed => throw _privateConstructorUsedError;
  DateTime get borrowDate => throw _privateConstructorUsedError;
  DateTime get expectedReturnDate => throw _privateConstructorUsedError;
  DateTime? get actualReturnDate => throw _privateConstructorUsedError;
  LoanStatus get status => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get returnNotes => throw _privateConstructorUsedError;
  String get borrowedBy => throw _privateConstructorUsedError;
  String? get returnedBy => throw _privateConstructorUsedError;
  int get daysOverdue => throw _privateConstructorUsedError;
  int get daysBorrowed => throw _privateConstructorUsedError;
  bool get isPendingSync => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LoanItemCopyWith<LoanItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoanItemCopyWith<$Res> {
  factory $LoanItemCopyWith(LoanItem value, $Res Function(LoanItem) then) =
      _$LoanItemCopyWithImpl<$Res, LoanItem>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String? userId,
      String inventoryItemId,
      String itemName,
      String itemCode,
      String borrowerName,
      String borrowerContact,
      String borrowerEmail,
      String purpose,
      int quantityBorrowed,
      DateTime borrowDate,
      DateTime expectedReturnDate,
      DateTime? actualReturnDate,
      LoanStatus status,
      String? notes,
      String? returnNotes,
      String borrowedBy,
      String? returnedBy,
      int daysOverdue,
      int daysBorrowed,
      bool isPendingSync});
}

/// @nodoc
class _$LoanItemCopyWithImpl<$Res, $Val extends LoanItem>
    implements $LoanItemCopyWith<$Res> {
  _$LoanItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? inventoryItemId = null,
    Object? itemName = null,
    Object? itemCode = null,
    Object? borrowerName = null,
    Object? borrowerContact = null,
    Object? borrowerEmail = null,
    Object? purpose = null,
    Object? quantityBorrowed = null,
    Object? borrowDate = null,
    Object? expectedReturnDate = null,
    Object? actualReturnDate = freezed,
    Object? status = null,
    Object? notes = freezed,
    Object? returnNotes = freezed,
    Object? borrowedBy = null,
    Object? returnedBy = freezed,
    Object? daysOverdue = null,
    Object? daysBorrowed = null,
    Object? isPendingSync = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      inventoryItemId: null == inventoryItemId
          ? _value.inventoryItemId
          : inventoryItemId // ignore: cast_nullable_to_non_nullable
              as String,
      itemName: null == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String,
      itemCode: null == itemCode
          ? _value.itemCode
          : itemCode // ignore: cast_nullable_to_non_nullable
              as String,
      borrowerName: null == borrowerName
          ? _value.borrowerName
          : borrowerName // ignore: cast_nullable_to_non_nullable
              as String,
      borrowerContact: null == borrowerContact
          ? _value.borrowerContact
          : borrowerContact // ignore: cast_nullable_to_non_nullable
              as String,
      borrowerEmail: null == borrowerEmail
          ? _value.borrowerEmail
          : borrowerEmail // ignore: cast_nullable_to_non_nullable
              as String,
      purpose: null == purpose
          ? _value.purpose
          : purpose // ignore: cast_nullable_to_non_nullable
              as String,
      quantityBorrowed: null == quantityBorrowed
          ? _value.quantityBorrowed
          : quantityBorrowed // ignore: cast_nullable_to_non_nullable
              as int,
      borrowDate: null == borrowDate
          ? _value.borrowDate
          : borrowDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expectedReturnDate: null == expectedReturnDate
          ? _value.expectedReturnDate
          : expectedReturnDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      actualReturnDate: freezed == actualReturnDate
          ? _value.actualReturnDate
          : actualReturnDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as LoanStatus,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      returnNotes: freezed == returnNotes
          ? _value.returnNotes
          : returnNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      borrowedBy: null == borrowedBy
          ? _value.borrowedBy
          : borrowedBy // ignore: cast_nullable_to_non_nullable
              as String,
      returnedBy: freezed == returnedBy
          ? _value.returnedBy
          : returnedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      daysOverdue: null == daysOverdue
          ? _value.daysOverdue
          : daysOverdue // ignore: cast_nullable_to_non_nullable
              as int,
      daysBorrowed: null == daysBorrowed
          ? _value.daysBorrowed
          : daysBorrowed // ignore: cast_nullable_to_non_nullable
              as int,
      isPendingSync: null == isPendingSync
          ? _value.isPendingSync
          : isPendingSync // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoanItemImplCopyWith<$Res>
    implements $LoanItemCopyWith<$Res> {
  factory _$$LoanItemImplCopyWith(
          _$LoanItemImpl value, $Res Function(_$LoanItemImpl) then) =
      __$$LoanItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String? userId,
      String inventoryItemId,
      String itemName,
      String itemCode,
      String borrowerName,
      String borrowerContact,
      String borrowerEmail,
      String purpose,
      int quantityBorrowed,
      DateTime borrowDate,
      DateTime expectedReturnDate,
      DateTime? actualReturnDate,
      LoanStatus status,
      String? notes,
      String? returnNotes,
      String borrowedBy,
      String? returnedBy,
      int daysOverdue,
      int daysBorrowed,
      bool isPendingSync});
}

/// @nodoc
class __$$LoanItemImplCopyWithImpl<$Res>
    extends _$LoanItemCopyWithImpl<$Res, _$LoanItemImpl>
    implements _$$LoanItemImplCopyWith<$Res> {
  __$$LoanItemImplCopyWithImpl(
      _$LoanItemImpl _value, $Res Function(_$LoanItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? inventoryItemId = null,
    Object? itemName = null,
    Object? itemCode = null,
    Object? borrowerName = null,
    Object? borrowerContact = null,
    Object? borrowerEmail = null,
    Object? purpose = null,
    Object? quantityBorrowed = null,
    Object? borrowDate = null,
    Object? expectedReturnDate = null,
    Object? actualReturnDate = freezed,
    Object? status = null,
    Object? notes = freezed,
    Object? returnNotes = freezed,
    Object? borrowedBy = null,
    Object? returnedBy = freezed,
    Object? daysOverdue = null,
    Object? daysBorrowed = null,
    Object? isPendingSync = null,
  }) {
    return _then(_$LoanItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      inventoryItemId: null == inventoryItemId
          ? _value.inventoryItemId
          : inventoryItemId // ignore: cast_nullable_to_non_nullable
              as String,
      itemName: null == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String,
      itemCode: null == itemCode
          ? _value.itemCode
          : itemCode // ignore: cast_nullable_to_non_nullable
              as String,
      borrowerName: null == borrowerName
          ? _value.borrowerName
          : borrowerName // ignore: cast_nullable_to_non_nullable
              as String,
      borrowerContact: null == borrowerContact
          ? _value.borrowerContact
          : borrowerContact // ignore: cast_nullable_to_non_nullable
              as String,
      borrowerEmail: null == borrowerEmail
          ? _value.borrowerEmail
          : borrowerEmail // ignore: cast_nullable_to_non_nullable
              as String,
      purpose: null == purpose
          ? _value.purpose
          : purpose // ignore: cast_nullable_to_non_nullable
              as String,
      quantityBorrowed: null == quantityBorrowed
          ? _value.quantityBorrowed
          : quantityBorrowed // ignore: cast_nullable_to_non_nullable
              as int,
      borrowDate: null == borrowDate
          ? _value.borrowDate
          : borrowDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expectedReturnDate: null == expectedReturnDate
          ? _value.expectedReturnDate
          : expectedReturnDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      actualReturnDate: freezed == actualReturnDate
          ? _value.actualReturnDate
          : actualReturnDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as LoanStatus,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      returnNotes: freezed == returnNotes
          ? _value.returnNotes
          : returnNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      borrowedBy: null == borrowedBy
          ? _value.borrowedBy
          : borrowedBy // ignore: cast_nullable_to_non_nullable
              as String,
      returnedBy: freezed == returnedBy
          ? _value.returnedBy
          : returnedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      daysOverdue: null == daysOverdue
          ? _value.daysOverdue
          : daysOverdue // ignore: cast_nullable_to_non_nullable
              as int,
      daysBorrowed: null == daysBorrowed
          ? _value.daysBorrowed
          : daysBorrowed // ignore: cast_nullable_to_non_nullable
              as int,
      isPendingSync: null == isPendingSync
          ? _value.isPendingSync
          : isPendingSync // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$LoanItemImpl extends _LoanItem {
  const _$LoanItemImpl(
      {required this.id,
      @JsonKey(name: 'user_id') this.userId,
      required this.inventoryItemId,
      required this.itemName,
      required this.itemCode,
      required this.borrowerName,
      required this.borrowerContact,
      this.borrowerEmail = '',
      required this.purpose,
      required this.quantityBorrowed,
      required this.borrowDate,
      required this.expectedReturnDate,
      this.actualReturnDate,
      this.status = LoanStatus.active,
      this.notes,
      this.returnNotes,
      required this.borrowedBy,
      this.returnedBy,
      this.daysOverdue = 0,
      this.daysBorrowed = 0,
      this.isPendingSync = false})
      : super._();

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String? userId;
// Supports multi-tenant isolation
  @override
  final String inventoryItemId;
  @override
  final String itemName;
  @override
  final String itemCode;
  @override
  final String borrowerName;
  @override
  final String borrowerContact;
  @override
  @JsonKey()
  final String borrowerEmail;
  @override
  final String purpose;
  @override
  final int quantityBorrowed;
  @override
  final DateTime borrowDate;
  @override
  final DateTime expectedReturnDate;
  @override
  final DateTime? actualReturnDate;
  @override
  @JsonKey()
  final LoanStatus status;
  @override
  final String? notes;
  @override
  final String? returnNotes;
  @override
  final String borrowedBy;
  @override
  final String? returnedBy;
  @override
  @JsonKey()
  final int daysOverdue;
  @override
  @JsonKey()
  final int daysBorrowed;
  @override
  @JsonKey()
  final bool isPendingSync;

  @override
  String toString() {
    return 'LoanItem(id: $id, userId: $userId, inventoryItemId: $inventoryItemId, itemName: $itemName, itemCode: $itemCode, borrowerName: $borrowerName, borrowerContact: $borrowerContact, borrowerEmail: $borrowerEmail, purpose: $purpose, quantityBorrowed: $quantityBorrowed, borrowDate: $borrowDate, expectedReturnDate: $expectedReturnDate, actualReturnDate: $actualReturnDate, status: $status, notes: $notes, returnNotes: $returnNotes, borrowedBy: $borrowedBy, returnedBy: $returnedBy, daysOverdue: $daysOverdue, daysBorrowed: $daysBorrowed, isPendingSync: $isPendingSync)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoanItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.inventoryItemId, inventoryItemId) ||
                other.inventoryItemId == inventoryItemId) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.borrowerName, borrowerName) ||
                other.borrowerName == borrowerName) &&
            (identical(other.borrowerContact, borrowerContact) ||
                other.borrowerContact == borrowerContact) &&
            (identical(other.borrowerEmail, borrowerEmail) ||
                other.borrowerEmail == borrowerEmail) &&
            (identical(other.purpose, purpose) || other.purpose == purpose) &&
            (identical(other.quantityBorrowed, quantityBorrowed) ||
                other.quantityBorrowed == quantityBorrowed) &&
            (identical(other.borrowDate, borrowDate) ||
                other.borrowDate == borrowDate) &&
            (identical(other.expectedReturnDate, expectedReturnDate) ||
                other.expectedReturnDate == expectedReturnDate) &&
            (identical(other.actualReturnDate, actualReturnDate) ||
                other.actualReturnDate == actualReturnDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.returnNotes, returnNotes) ||
                other.returnNotes == returnNotes) &&
            (identical(other.borrowedBy, borrowedBy) ||
                other.borrowedBy == borrowedBy) &&
            (identical(other.returnedBy, returnedBy) ||
                other.returnedBy == returnedBy) &&
            (identical(other.daysOverdue, daysOverdue) ||
                other.daysOverdue == daysOverdue) &&
            (identical(other.daysBorrowed, daysBorrowed) ||
                other.daysBorrowed == daysBorrowed) &&
            (identical(other.isPendingSync, isPendingSync) ||
                other.isPendingSync == isPendingSync));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        inventoryItemId,
        itemName,
        itemCode,
        borrowerName,
        borrowerContact,
        borrowerEmail,
        purpose,
        quantityBorrowed,
        borrowDate,
        expectedReturnDate,
        actualReturnDate,
        status,
        notes,
        returnNotes,
        borrowedBy,
        returnedBy,
        daysOverdue,
        daysBorrowed,
        isPendingSync
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoanItemImplCopyWith<_$LoanItemImpl> get copyWith =>
      __$$LoanItemImplCopyWithImpl<_$LoanItemImpl>(this, _$identity);
}

abstract class _LoanItem extends LoanItem {
  const factory _LoanItem(
      {required final String id,
      @JsonKey(name: 'user_id') final String? userId,
      required final String inventoryItemId,
      required final String itemName,
      required final String itemCode,
      required final String borrowerName,
      required final String borrowerContact,
      final String borrowerEmail,
      required final String purpose,
      required final int quantityBorrowed,
      required final DateTime borrowDate,
      required final DateTime expectedReturnDate,
      final DateTime? actualReturnDate,
      final LoanStatus status,
      final String? notes,
      final String? returnNotes,
      required final String borrowedBy,
      final String? returnedBy,
      final int daysOverdue,
      final int daysBorrowed,
      final bool isPendingSync}) = _$LoanItemImpl;
  const _LoanItem._() : super._();

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String? get userId;
  @override // Supports multi-tenant isolation
  String get inventoryItemId;
  @override
  String get itemName;
  @override
  String get itemCode;
  @override
  String get borrowerName;
  @override
  String get borrowerContact;
  @override
  String get borrowerEmail;
  @override
  String get purpose;
  @override
  int get quantityBorrowed;
  @override
  DateTime get borrowDate;
  @override
  DateTime get expectedReturnDate;
  @override
  DateTime? get actualReturnDate;
  @override
  LoanStatus get status;
  @override
  String? get notes;
  @override
  String? get returnNotes;
  @override
  String get borrowedBy;
  @override
  String? get returnedBy;
  @override
  int get daysOverdue;
  @override
  int get daysBorrowed;
  @override
  bool get isPendingSync;
  @override
  @JsonKey(ignore: true)
  _$$LoanItemImplCopyWith<_$LoanItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
