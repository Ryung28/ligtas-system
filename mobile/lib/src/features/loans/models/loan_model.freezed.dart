// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'loan_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LoanModel _$LoanModelFromJson(Map<String, dynamic> json) {
  return _LoanModel.fromJson(json);
}

/// @nodoc
mixin _$LoanModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'inventory_item_id')
  String get inventoryItemId => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name')
  String get itemName => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_code')
  String get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'borrower_name')
  String get borrowerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'borrower_contact')
  String get borrowerContact => throw _privateConstructorUsedError;
  String get borrowerEmail => throw _privateConstructorUsedError;
  String get purpose => throw _privateConstructorUsedError;
  @JsonKey(name: 'quantity_borrowed')
  int get quantityBorrowed => throw _privateConstructorUsedError;
  @JsonKey(name: 'borrow_date')
  DateTime get borrowDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'expected_return_date')
  DateTime get expectedReturnDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'actual_return_date')
  DateTime? get actualReturnDate => throw _privateConstructorUsedError;
  LoanStatus get status => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'return_notes')
  String? get returnNotes => throw _privateConstructorUsedError;
  @JsonKey(name: 'borrowed_by')
  String get borrowedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'returned_by')
  String? get returnedBy => throw _privateConstructorUsedError;
  int get daysOverdue => throw _privateConstructorUsedError;
  int get daysBorrowed => throw _privateConstructorUsedError;
  bool get isPendingSync => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LoanModelCopyWith<LoanModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoanModelCopyWith<$Res> {
  factory $LoanModelCopyWith(LoanModel value, $Res Function(LoanModel) then) =
      _$LoanModelCopyWithImpl<$Res, LoanModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'inventory_item_id') String inventoryItemId,
      @JsonKey(name: 'item_name') String itemName,
      @JsonKey(name: 'item_code') String itemCode,
      @JsonKey(name: 'borrower_name') String borrowerName,
      @JsonKey(name: 'borrower_contact') String borrowerContact,
      String borrowerEmail,
      String purpose,
      @JsonKey(name: 'quantity_borrowed') int quantityBorrowed,
      @JsonKey(name: 'borrow_date') DateTime borrowDate,
      @JsonKey(name: 'expected_return_date') DateTime expectedReturnDate,
      @JsonKey(name: 'actual_return_date') DateTime? actualReturnDate,
      LoanStatus status,
      String? notes,
      @JsonKey(name: 'return_notes') String? returnNotes,
      @JsonKey(name: 'borrowed_by') String borrowedBy,
      @JsonKey(name: 'returned_by') String? returnedBy,
      int daysOverdue,
      int daysBorrowed,
      bool isPendingSync});
}

/// @nodoc
class _$LoanModelCopyWithImpl<$Res, $Val extends LoanModel>
    implements $LoanModelCopyWith<$Res> {
  _$LoanModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
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
abstract class _$$LoanModelImplCopyWith<$Res>
    implements $LoanModelCopyWith<$Res> {
  factory _$$LoanModelImplCopyWith(
          _$LoanModelImpl value, $Res Function(_$LoanModelImpl) then) =
      __$$LoanModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'inventory_item_id') String inventoryItemId,
      @JsonKey(name: 'item_name') String itemName,
      @JsonKey(name: 'item_code') String itemCode,
      @JsonKey(name: 'borrower_name') String borrowerName,
      @JsonKey(name: 'borrower_contact') String borrowerContact,
      String borrowerEmail,
      String purpose,
      @JsonKey(name: 'quantity_borrowed') int quantityBorrowed,
      @JsonKey(name: 'borrow_date') DateTime borrowDate,
      @JsonKey(name: 'expected_return_date') DateTime expectedReturnDate,
      @JsonKey(name: 'actual_return_date') DateTime? actualReturnDate,
      LoanStatus status,
      String? notes,
      @JsonKey(name: 'return_notes') String? returnNotes,
      @JsonKey(name: 'borrowed_by') String borrowedBy,
      @JsonKey(name: 'returned_by') String? returnedBy,
      int daysOverdue,
      int daysBorrowed,
      bool isPendingSync});
}

/// @nodoc
class __$$LoanModelImplCopyWithImpl<$Res>
    extends _$LoanModelCopyWithImpl<$Res, _$LoanModelImpl>
    implements _$$LoanModelImplCopyWith<$Res> {
  __$$LoanModelImplCopyWithImpl(
      _$LoanModelImpl _value, $Res Function(_$LoanModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
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
    return _then(_$LoanModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
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
@JsonSerializable()
class _$LoanModelImpl implements _LoanModel {
  const _$LoanModelImpl(
      {required this.id,
      @JsonKey(name: 'inventory_item_id') required this.inventoryItemId,
      @JsonKey(name: 'item_name') required this.itemName,
      @JsonKey(name: 'item_code') required this.itemCode,
      @JsonKey(name: 'borrower_name') required this.borrowerName,
      @JsonKey(name: 'borrower_contact') required this.borrowerContact,
      this.borrowerEmail = '',
      required this.purpose,
      @JsonKey(name: 'quantity_borrowed') required this.quantityBorrowed,
      @JsonKey(name: 'borrow_date') required this.borrowDate,
      @JsonKey(name: 'expected_return_date') required this.expectedReturnDate,
      @JsonKey(name: 'actual_return_date') this.actualReturnDate,
      this.status = LoanStatus.active,
      this.notes,
      @JsonKey(name: 'return_notes') this.returnNotes,
      @JsonKey(name: 'borrowed_by') required this.borrowedBy,
      @JsonKey(name: 'returned_by') this.returnedBy,
      this.daysOverdue = 0,
      this.daysBorrowed = 0,
      this.isPendingSync = false});

  factory _$LoanModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoanModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'inventory_item_id')
  final String inventoryItemId;
  @override
  @JsonKey(name: 'item_name')
  final String itemName;
  @override
  @JsonKey(name: 'item_code')
  final String itemCode;
  @override
  @JsonKey(name: 'borrower_name')
  final String borrowerName;
  @override
  @JsonKey(name: 'borrower_contact')
  final String borrowerContact;
  @override
  @JsonKey()
  final String borrowerEmail;
  @override
  final String purpose;
  @override
  @JsonKey(name: 'quantity_borrowed')
  final int quantityBorrowed;
  @override
  @JsonKey(name: 'borrow_date')
  final DateTime borrowDate;
  @override
  @JsonKey(name: 'expected_return_date')
  final DateTime expectedReturnDate;
  @override
  @JsonKey(name: 'actual_return_date')
  final DateTime? actualReturnDate;
  @override
  @JsonKey()
  final LoanStatus status;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'return_notes')
  final String? returnNotes;
  @override
  @JsonKey(name: 'borrowed_by')
  final String borrowedBy;
  @override
  @JsonKey(name: 'returned_by')
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
    return 'LoanModel(id: $id, inventoryItemId: $inventoryItemId, itemName: $itemName, itemCode: $itemCode, borrowerName: $borrowerName, borrowerContact: $borrowerContact, borrowerEmail: $borrowerEmail, purpose: $purpose, quantityBorrowed: $quantityBorrowed, borrowDate: $borrowDate, expectedReturnDate: $expectedReturnDate, actualReturnDate: $actualReturnDate, status: $status, notes: $notes, returnNotes: $returnNotes, borrowedBy: $borrowedBy, returnedBy: $returnedBy, daysOverdue: $daysOverdue, daysBorrowed: $daysBorrowed, isPendingSync: $isPendingSync)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoanModelImpl &&
            (identical(other.id, id) || other.id == id) &&
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

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
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
  _$$LoanModelImplCopyWith<_$LoanModelImpl> get copyWith =>
      __$$LoanModelImplCopyWithImpl<_$LoanModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoanModelImplToJson(
      this,
    );
  }
}

abstract class _LoanModel implements LoanModel {
  const factory _LoanModel(
      {required final String id,
      @JsonKey(name: 'inventory_item_id') required final String inventoryItemId,
      @JsonKey(name: 'item_name') required final String itemName,
      @JsonKey(name: 'item_code') required final String itemCode,
      @JsonKey(name: 'borrower_name') required final String borrowerName,
      @JsonKey(name: 'borrower_contact') required final String borrowerContact,
      final String borrowerEmail,
      required final String purpose,
      @JsonKey(name: 'quantity_borrowed') required final int quantityBorrowed,
      @JsonKey(name: 'borrow_date') required final DateTime borrowDate,
      @JsonKey(name: 'expected_return_date')
      required final DateTime expectedReturnDate,
      @JsonKey(name: 'actual_return_date') final DateTime? actualReturnDate,
      final LoanStatus status,
      final String? notes,
      @JsonKey(name: 'return_notes') final String? returnNotes,
      @JsonKey(name: 'borrowed_by') required final String borrowedBy,
      @JsonKey(name: 'returned_by') final String? returnedBy,
      final int daysOverdue,
      final int daysBorrowed,
      final bool isPendingSync}) = _$LoanModelImpl;

  factory _LoanModel.fromJson(Map<String, dynamic> json) =
      _$LoanModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'inventory_item_id')
  String get inventoryItemId;
  @override
  @JsonKey(name: 'item_name')
  String get itemName;
  @override
  @JsonKey(name: 'item_code')
  String get itemCode;
  @override
  @JsonKey(name: 'borrower_name')
  String get borrowerName;
  @override
  @JsonKey(name: 'borrower_contact')
  String get borrowerContact;
  @override
  String get borrowerEmail;
  @override
  String get purpose;
  @override
  @JsonKey(name: 'quantity_borrowed')
  int get quantityBorrowed;
  @override
  @JsonKey(name: 'borrow_date')
  DateTime get borrowDate;
  @override
  @JsonKey(name: 'expected_return_date')
  DateTime get expectedReturnDate;
  @override
  @JsonKey(name: 'actual_return_date')
  DateTime? get actualReturnDate;
  @override
  LoanStatus get status;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'return_notes')
  String? get returnNotes;
  @override
  @JsonKey(name: 'borrowed_by')
  String get borrowedBy;
  @override
  @JsonKey(name: 'returned_by')
  String? get returnedBy;
  @override
  int get daysOverdue;
  @override
  int get daysBorrowed;
  @override
  bool get isPendingSync;
  @override
  @JsonKey(ignore: true)
  _$$LoanModelImplCopyWith<_$LoanModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
