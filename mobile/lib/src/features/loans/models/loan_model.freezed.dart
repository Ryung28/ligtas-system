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
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  bool get isPendingSync => throw _privateConstructorUsedError;
  int get daysOverdue => throw _privateConstructorUsedError;
  int get daysBorrowed => throw _privateConstructorUsedError;

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
      DateTime createdAt,
      DateTime? updatedAt,
      bool isPendingSync,
      int daysOverdue,
      int daysBorrowed});
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
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? isPendingSync = null,
    Object? daysOverdue = null,
    Object? daysBorrowed = null,
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
      daysOverdue: null == daysOverdue
          ? _value.daysOverdue
          : daysOverdue // ignore: cast_nullable_to_non_nullable
              as int,
      daysBorrowed: null == daysBorrowed
          ? _value.daysBorrowed
          : daysBorrowed // ignore: cast_nullable_to_non_nullable
              as int,
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
      DateTime createdAt,
      DateTime? updatedAt,
      bool isPendingSync,
      int daysOverdue,
      int daysBorrowed});
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
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? isPendingSync = null,
    Object? daysOverdue = null,
    Object? daysBorrowed = null,
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
      daysOverdue: null == daysOverdue
          ? _value.daysOverdue
          : daysOverdue // ignore: cast_nullable_to_non_nullable
              as int,
      daysBorrowed: null == daysBorrowed
          ? _value.daysBorrowed
          : daysBorrowed // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$LoanModelImpl implements _LoanModel {
  const _$LoanModelImpl(
      {required this.id,
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
      required this.createdAt,
      this.updatedAt,
      this.isPendingSync = false,
      this.daysOverdue = 0,
      this.daysBorrowed = 0});

  factory _$LoanModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoanModelImplFromJson(json);

  @override
  final String id;
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
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final bool isPendingSync;
  @override
  @JsonKey()
  final int daysOverdue;
  @override
  @JsonKey()
  final int daysBorrowed;

  @override
  String toString() {
    return 'LoanModel(id: $id, inventoryItemId: $inventoryItemId, itemName: $itemName, itemCode: $itemCode, borrowerName: $borrowerName, borrowerContact: $borrowerContact, borrowerEmail: $borrowerEmail, purpose: $purpose, quantityBorrowed: $quantityBorrowed, borrowDate: $borrowDate, expectedReturnDate: $expectedReturnDate, actualReturnDate: $actualReturnDate, status: $status, notes: $notes, returnNotes: $returnNotes, borrowedBy: $borrowedBy, returnedBy: $returnedBy, createdAt: $createdAt, updatedAt: $updatedAt, isPendingSync: $isPendingSync, daysOverdue: $daysOverdue, daysBorrowed: $daysBorrowed)';
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
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isPendingSync, isPendingSync) ||
                other.isPendingSync == isPendingSync) &&
            (identical(other.daysOverdue, daysOverdue) ||
                other.daysOverdue == daysOverdue) &&
            (identical(other.daysBorrowed, daysBorrowed) ||
                other.daysBorrowed == daysBorrowed));
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
        createdAt,
        updatedAt,
        isPendingSync,
        daysOverdue,
        daysBorrowed
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
      required final DateTime createdAt,
      final DateTime? updatedAt,
      final bool isPendingSync,
      final int daysOverdue,
      final int daysBorrowed}) = _$LoanModelImpl;

  factory _LoanModel.fromJson(Map<String, dynamic> json) =
      _$LoanModelImpl.fromJson;

  @override
  String get id;
  @override
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
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  bool get isPendingSync;
  @override
  int get daysOverdue;
  @override
  int get daysBorrowed;
  @override
  @JsonKey(ignore: true)
  _$$LoanModelImplCopyWith<_$LoanModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateLoanRequest _$CreateLoanRequestFromJson(Map<String, dynamic> json) {
  return _CreateLoanRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateLoanRequest {
  String get inventoryItemId => throw _privateConstructorUsedError;
  int? get inventoryId => throw _privateConstructorUsedError;
  String get itemName => throw _privateConstructorUsedError;
  String? get itemCode => throw _privateConstructorUsedError;
  String get borrowerName => throw _privateConstructorUsedError;
  String get borrowerContact => throw _privateConstructorUsedError;
  String get borrowerEmail => throw _privateConstructorUsedError;
  String get borrowerOrganization => throw _privateConstructorUsedError;
  String get purpose => throw _privateConstructorUsedError;
  int get quantityBorrowed => throw _privateConstructorUsedError;
  DateTime get expectedReturnDate => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateLoanRequestCopyWith<CreateLoanRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateLoanRequestCopyWith<$Res> {
  factory $CreateLoanRequestCopyWith(
          CreateLoanRequest value, $Res Function(CreateLoanRequest) then) =
      _$CreateLoanRequestCopyWithImpl<$Res, CreateLoanRequest>;
  @useResult
  $Res call(
      {String inventoryItemId,
      int? inventoryId,
      String itemName,
      String? itemCode,
      String borrowerName,
      String borrowerContact,
      String borrowerEmail,
      String borrowerOrganization,
      String purpose,
      int quantityBorrowed,
      DateTime expectedReturnDate,
      String? notes});
}

/// @nodoc
class _$CreateLoanRequestCopyWithImpl<$Res, $Val extends CreateLoanRequest>
    implements $CreateLoanRequestCopyWith<$Res> {
  _$CreateLoanRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inventoryItemId = null,
    Object? inventoryId = freezed,
    Object? itemName = null,
    Object? itemCode = freezed,
    Object? borrowerName = null,
    Object? borrowerContact = null,
    Object? borrowerEmail = null,
    Object? borrowerOrganization = null,
    Object? purpose = null,
    Object? quantityBorrowed = null,
    Object? expectedReturnDate = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      inventoryItemId: null == inventoryItemId
          ? _value.inventoryItemId
          : inventoryItemId // ignore: cast_nullable_to_non_nullable
              as String,
      inventoryId: freezed == inventoryId
          ? _value.inventoryId
          : inventoryId // ignore: cast_nullable_to_non_nullable
              as int?,
      itemName: null == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String,
      itemCode: freezed == itemCode
          ? _value.itemCode
          : itemCode // ignore: cast_nullable_to_non_nullable
              as String?,
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
      borrowerOrganization: null == borrowerOrganization
          ? _value.borrowerOrganization
          : borrowerOrganization // ignore: cast_nullable_to_non_nullable
              as String,
      purpose: null == purpose
          ? _value.purpose
          : purpose // ignore: cast_nullable_to_non_nullable
              as String,
      quantityBorrowed: null == quantityBorrowed
          ? _value.quantityBorrowed
          : quantityBorrowed // ignore: cast_nullable_to_non_nullable
              as int,
      expectedReturnDate: null == expectedReturnDate
          ? _value.expectedReturnDate
          : expectedReturnDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateLoanRequestImplCopyWith<$Res>
    implements $CreateLoanRequestCopyWith<$Res> {
  factory _$$CreateLoanRequestImplCopyWith(_$CreateLoanRequestImpl value,
          $Res Function(_$CreateLoanRequestImpl) then) =
      __$$CreateLoanRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String inventoryItemId,
      int? inventoryId,
      String itemName,
      String? itemCode,
      String borrowerName,
      String borrowerContact,
      String borrowerEmail,
      String borrowerOrganization,
      String purpose,
      int quantityBorrowed,
      DateTime expectedReturnDate,
      String? notes});
}

/// @nodoc
class __$$CreateLoanRequestImplCopyWithImpl<$Res>
    extends _$CreateLoanRequestCopyWithImpl<$Res, _$CreateLoanRequestImpl>
    implements _$$CreateLoanRequestImplCopyWith<$Res> {
  __$$CreateLoanRequestImplCopyWithImpl(_$CreateLoanRequestImpl _value,
      $Res Function(_$CreateLoanRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inventoryItemId = null,
    Object? inventoryId = freezed,
    Object? itemName = null,
    Object? itemCode = freezed,
    Object? borrowerName = null,
    Object? borrowerContact = null,
    Object? borrowerEmail = null,
    Object? borrowerOrganization = null,
    Object? purpose = null,
    Object? quantityBorrowed = null,
    Object? expectedReturnDate = null,
    Object? notes = freezed,
  }) {
    return _then(_$CreateLoanRequestImpl(
      inventoryItemId: null == inventoryItemId
          ? _value.inventoryItemId
          : inventoryItemId // ignore: cast_nullable_to_non_nullable
              as String,
      inventoryId: freezed == inventoryId
          ? _value.inventoryId
          : inventoryId // ignore: cast_nullable_to_non_nullable
              as int?,
      itemName: null == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String,
      itemCode: freezed == itemCode
          ? _value.itemCode
          : itemCode // ignore: cast_nullable_to_non_nullable
              as String?,
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
      borrowerOrganization: null == borrowerOrganization
          ? _value.borrowerOrganization
          : borrowerOrganization // ignore: cast_nullable_to_non_nullable
              as String,
      purpose: null == purpose
          ? _value.purpose
          : purpose // ignore: cast_nullable_to_non_nullable
              as String,
      quantityBorrowed: null == quantityBorrowed
          ? _value.quantityBorrowed
          : quantityBorrowed // ignore: cast_nullable_to_non_nullable
              as int,
      expectedReturnDate: null == expectedReturnDate
          ? _value.expectedReturnDate
          : expectedReturnDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$CreateLoanRequestImpl implements _CreateLoanRequest {
  const _$CreateLoanRequestImpl(
      {required this.inventoryItemId,
      this.inventoryId,
      required this.itemName,
      this.itemCode,
      required this.borrowerName,
      required this.borrowerContact,
      required this.borrowerEmail,
      required this.borrowerOrganization,
      required this.purpose,
      required this.quantityBorrowed,
      required this.expectedReturnDate,
      this.notes});

  factory _$CreateLoanRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateLoanRequestImplFromJson(json);

  @override
  final String inventoryItemId;
  @override
  final int? inventoryId;
  @override
  final String itemName;
  @override
  final String? itemCode;
  @override
  final String borrowerName;
  @override
  final String borrowerContact;
  @override
  final String borrowerEmail;
  @override
  final String borrowerOrganization;
  @override
  final String purpose;
  @override
  final int quantityBorrowed;
  @override
  final DateTime expectedReturnDate;
  @override
  final String? notes;

  @override
  String toString() {
    return 'CreateLoanRequest(inventoryItemId: $inventoryItemId, inventoryId: $inventoryId, itemName: $itemName, itemCode: $itemCode, borrowerName: $borrowerName, borrowerContact: $borrowerContact, borrowerEmail: $borrowerEmail, borrowerOrganization: $borrowerOrganization, purpose: $purpose, quantityBorrowed: $quantityBorrowed, expectedReturnDate: $expectedReturnDate, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateLoanRequestImpl &&
            (identical(other.inventoryItemId, inventoryItemId) ||
                other.inventoryItemId == inventoryItemId) &&
            (identical(other.inventoryId, inventoryId) ||
                other.inventoryId == inventoryId) &&
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
            (identical(other.borrowerOrganization, borrowerOrganization) ||
                other.borrowerOrganization == borrowerOrganization) &&
            (identical(other.purpose, purpose) || other.purpose == purpose) &&
            (identical(other.quantityBorrowed, quantityBorrowed) ||
                other.quantityBorrowed == quantityBorrowed) &&
            (identical(other.expectedReturnDate, expectedReturnDate) ||
                other.expectedReturnDate == expectedReturnDate) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      inventoryItemId,
      inventoryId,
      itemName,
      itemCode,
      borrowerName,
      borrowerContact,
      borrowerEmail,
      borrowerOrganization,
      purpose,
      quantityBorrowed,
      expectedReturnDate,
      notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateLoanRequestImplCopyWith<_$CreateLoanRequestImpl> get copyWith =>
      __$$CreateLoanRequestImplCopyWithImpl<_$CreateLoanRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateLoanRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateLoanRequest implements CreateLoanRequest {
  const factory _CreateLoanRequest(
      {required final String inventoryItemId,
      final int? inventoryId,
      required final String itemName,
      final String? itemCode,
      required final String borrowerName,
      required final String borrowerContact,
      required final String borrowerEmail,
      required final String borrowerOrganization,
      required final String purpose,
      required final int quantityBorrowed,
      required final DateTime expectedReturnDate,
      final String? notes}) = _$CreateLoanRequestImpl;

  factory _CreateLoanRequest.fromJson(Map<String, dynamic> json) =
      _$CreateLoanRequestImpl.fromJson;

  @override
  String get inventoryItemId;
  @override
  int? get inventoryId;
  @override
  String get itemName;
  @override
  String? get itemCode;
  @override
  String get borrowerName;
  @override
  String get borrowerContact;
  @override
  String get borrowerEmail;
  @override
  String get borrowerOrganization;
  @override
  String get purpose;
  @override
  int get quantityBorrowed;
  @override
  DateTime get expectedReturnDate;
  @override
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$CreateLoanRequestImplCopyWith<_$CreateLoanRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReturnLoanRequest _$ReturnLoanRequestFromJson(Map<String, dynamic> json) {
  return _ReturnLoanRequest.fromJson(json);
}

/// @nodoc
mixin _$ReturnLoanRequest {
  String get loanId => throw _privateConstructorUsedError;
  int get quantityReturned => throw _privateConstructorUsedError;
  String? get returnNotes => throw _privateConstructorUsedError;
  String? get condition => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReturnLoanRequestCopyWith<ReturnLoanRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReturnLoanRequestCopyWith<$Res> {
  factory $ReturnLoanRequestCopyWith(
          ReturnLoanRequest value, $Res Function(ReturnLoanRequest) then) =
      _$ReturnLoanRequestCopyWithImpl<$Res, ReturnLoanRequest>;
  @useResult
  $Res call(
      {String loanId,
      int quantityReturned,
      String? returnNotes,
      String? condition});
}

/// @nodoc
class _$ReturnLoanRequestCopyWithImpl<$Res, $Val extends ReturnLoanRequest>
    implements $ReturnLoanRequestCopyWith<$Res> {
  _$ReturnLoanRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loanId = null,
    Object? quantityReturned = null,
    Object? returnNotes = freezed,
    Object? condition = freezed,
  }) {
    return _then(_value.copyWith(
      loanId: null == loanId
          ? _value.loanId
          : loanId // ignore: cast_nullable_to_non_nullable
              as String,
      quantityReturned: null == quantityReturned
          ? _value.quantityReturned
          : quantityReturned // ignore: cast_nullable_to_non_nullable
              as int,
      returnNotes: freezed == returnNotes
          ? _value.returnNotes
          : returnNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      condition: freezed == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReturnLoanRequestImplCopyWith<$Res>
    implements $ReturnLoanRequestCopyWith<$Res> {
  factory _$$ReturnLoanRequestImplCopyWith(_$ReturnLoanRequestImpl value,
          $Res Function(_$ReturnLoanRequestImpl) then) =
      __$$ReturnLoanRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String loanId,
      int quantityReturned,
      String? returnNotes,
      String? condition});
}

/// @nodoc
class __$$ReturnLoanRequestImplCopyWithImpl<$Res>
    extends _$ReturnLoanRequestCopyWithImpl<$Res, _$ReturnLoanRequestImpl>
    implements _$$ReturnLoanRequestImplCopyWith<$Res> {
  __$$ReturnLoanRequestImplCopyWithImpl(_$ReturnLoanRequestImpl _value,
      $Res Function(_$ReturnLoanRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loanId = null,
    Object? quantityReturned = null,
    Object? returnNotes = freezed,
    Object? condition = freezed,
  }) {
    return _then(_$ReturnLoanRequestImpl(
      loanId: null == loanId
          ? _value.loanId
          : loanId // ignore: cast_nullable_to_non_nullable
              as String,
      quantityReturned: null == quantityReturned
          ? _value.quantityReturned
          : quantityReturned // ignore: cast_nullable_to_non_nullable
              as int,
      returnNotes: freezed == returnNotes
          ? _value.returnNotes
          : returnNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      condition: freezed == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$ReturnLoanRequestImpl implements _ReturnLoanRequest {
  const _$ReturnLoanRequestImpl(
      {required this.loanId,
      required this.quantityReturned,
      this.returnNotes,
      this.condition});

  factory _$ReturnLoanRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReturnLoanRequestImplFromJson(json);

  @override
  final String loanId;
  @override
  final int quantityReturned;
  @override
  final String? returnNotes;
  @override
  final String? condition;

  @override
  String toString() {
    return 'ReturnLoanRequest(loanId: $loanId, quantityReturned: $quantityReturned, returnNotes: $returnNotes, condition: $condition)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReturnLoanRequestImpl &&
            (identical(other.loanId, loanId) || other.loanId == loanId) &&
            (identical(other.quantityReturned, quantityReturned) ||
                other.quantityReturned == quantityReturned) &&
            (identical(other.returnNotes, returnNotes) ||
                other.returnNotes == returnNotes) &&
            (identical(other.condition, condition) ||
                other.condition == condition));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, loanId, quantityReturned, returnNotes, condition);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReturnLoanRequestImplCopyWith<_$ReturnLoanRequestImpl> get copyWith =>
      __$$ReturnLoanRequestImplCopyWithImpl<_$ReturnLoanRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReturnLoanRequestImplToJson(
      this,
    );
  }
}

abstract class _ReturnLoanRequest implements ReturnLoanRequest {
  const factory _ReturnLoanRequest(
      {required final String loanId,
      required final int quantityReturned,
      final String? returnNotes,
      final String? condition}) = _$ReturnLoanRequestImpl;

  factory _ReturnLoanRequest.fromJson(Map<String, dynamic> json) =
      _$ReturnLoanRequestImpl.fromJson;

  @override
  String get loanId;
  @override
  int get quantityReturned;
  @override
  String? get returnNotes;
  @override
  String? get condition;
  @override
  @JsonKey(ignore: true)
  _$$ReturnLoanRequestImplCopyWith<_$ReturnLoanRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LoanStatistics _$LoanStatisticsFromJson(Map<String, dynamic> json) {
  return _LoanStatistics.fromJson(json);
}

/// @nodoc
mixin _$LoanStatistics {
  int get totalActiveLoans => throw _privateConstructorUsedError;
  int get totalOverdueLoans => throw _privateConstructorUsedError;
  int get totalReturnedToday => throw _privateConstructorUsedError;
  int get totalItemsBorrowed => throw _privateConstructorUsedError;
  double get averageLoanDuration => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LoanStatisticsCopyWith<LoanStatistics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoanStatisticsCopyWith<$Res> {
  factory $LoanStatisticsCopyWith(
          LoanStatistics value, $Res Function(LoanStatistics) then) =
      _$LoanStatisticsCopyWithImpl<$Res, LoanStatistics>;
  @useResult
  $Res call(
      {int totalActiveLoans,
      int totalOverdueLoans,
      int totalReturnedToday,
      int totalItemsBorrowed,
      double averageLoanDuration});
}

/// @nodoc
class _$LoanStatisticsCopyWithImpl<$Res, $Val extends LoanStatistics>
    implements $LoanStatisticsCopyWith<$Res> {
  _$LoanStatisticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalActiveLoans = null,
    Object? totalOverdueLoans = null,
    Object? totalReturnedToday = null,
    Object? totalItemsBorrowed = null,
    Object? averageLoanDuration = null,
  }) {
    return _then(_value.copyWith(
      totalActiveLoans: null == totalActiveLoans
          ? _value.totalActiveLoans
          : totalActiveLoans // ignore: cast_nullable_to_non_nullable
              as int,
      totalOverdueLoans: null == totalOverdueLoans
          ? _value.totalOverdueLoans
          : totalOverdueLoans // ignore: cast_nullable_to_non_nullable
              as int,
      totalReturnedToday: null == totalReturnedToday
          ? _value.totalReturnedToday
          : totalReturnedToday // ignore: cast_nullable_to_non_nullable
              as int,
      totalItemsBorrowed: null == totalItemsBorrowed
          ? _value.totalItemsBorrowed
          : totalItemsBorrowed // ignore: cast_nullable_to_non_nullable
              as int,
      averageLoanDuration: null == averageLoanDuration
          ? _value.averageLoanDuration
          : averageLoanDuration // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoanStatisticsImplCopyWith<$Res>
    implements $LoanStatisticsCopyWith<$Res> {
  factory _$$LoanStatisticsImplCopyWith(_$LoanStatisticsImpl value,
          $Res Function(_$LoanStatisticsImpl) then) =
      __$$LoanStatisticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalActiveLoans,
      int totalOverdueLoans,
      int totalReturnedToday,
      int totalItemsBorrowed,
      double averageLoanDuration});
}

/// @nodoc
class __$$LoanStatisticsImplCopyWithImpl<$Res>
    extends _$LoanStatisticsCopyWithImpl<$Res, _$LoanStatisticsImpl>
    implements _$$LoanStatisticsImplCopyWith<$Res> {
  __$$LoanStatisticsImplCopyWithImpl(
      _$LoanStatisticsImpl _value, $Res Function(_$LoanStatisticsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalActiveLoans = null,
    Object? totalOverdueLoans = null,
    Object? totalReturnedToday = null,
    Object? totalItemsBorrowed = null,
    Object? averageLoanDuration = null,
  }) {
    return _then(_$LoanStatisticsImpl(
      totalActiveLoans: null == totalActiveLoans
          ? _value.totalActiveLoans
          : totalActiveLoans // ignore: cast_nullable_to_non_nullable
              as int,
      totalOverdueLoans: null == totalOverdueLoans
          ? _value.totalOverdueLoans
          : totalOverdueLoans // ignore: cast_nullable_to_non_nullable
              as int,
      totalReturnedToday: null == totalReturnedToday
          ? _value.totalReturnedToday
          : totalReturnedToday // ignore: cast_nullable_to_non_nullable
              as int,
      totalItemsBorrowed: null == totalItemsBorrowed
          ? _value.totalItemsBorrowed
          : totalItemsBorrowed // ignore: cast_nullable_to_non_nullable
              as int,
      averageLoanDuration: null == averageLoanDuration
          ? _value.averageLoanDuration
          : averageLoanDuration // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoanStatisticsImpl implements _LoanStatistics {
  const _$LoanStatisticsImpl(
      {this.totalActiveLoans = 0,
      this.totalOverdueLoans = 0,
      this.totalReturnedToday = 0,
      this.totalItemsBorrowed = 0,
      this.averageLoanDuration = 0.0});

  factory _$LoanStatisticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoanStatisticsImplFromJson(json);

  @override
  @JsonKey()
  final int totalActiveLoans;
  @override
  @JsonKey()
  final int totalOverdueLoans;
  @override
  @JsonKey()
  final int totalReturnedToday;
  @override
  @JsonKey()
  final int totalItemsBorrowed;
  @override
  @JsonKey()
  final double averageLoanDuration;

  @override
  String toString() {
    return 'LoanStatistics(totalActiveLoans: $totalActiveLoans, totalOverdueLoans: $totalOverdueLoans, totalReturnedToday: $totalReturnedToday, totalItemsBorrowed: $totalItemsBorrowed, averageLoanDuration: $averageLoanDuration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoanStatisticsImpl &&
            (identical(other.totalActiveLoans, totalActiveLoans) ||
                other.totalActiveLoans == totalActiveLoans) &&
            (identical(other.totalOverdueLoans, totalOverdueLoans) ||
                other.totalOverdueLoans == totalOverdueLoans) &&
            (identical(other.totalReturnedToday, totalReturnedToday) ||
                other.totalReturnedToday == totalReturnedToday) &&
            (identical(other.totalItemsBorrowed, totalItemsBorrowed) ||
                other.totalItemsBorrowed == totalItemsBorrowed) &&
            (identical(other.averageLoanDuration, averageLoanDuration) ||
                other.averageLoanDuration == averageLoanDuration));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalActiveLoans,
      totalOverdueLoans,
      totalReturnedToday,
      totalItemsBorrowed,
      averageLoanDuration);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoanStatisticsImplCopyWith<_$LoanStatisticsImpl> get copyWith =>
      __$$LoanStatisticsImplCopyWithImpl<_$LoanStatisticsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoanStatisticsImplToJson(
      this,
    );
  }
}

abstract class _LoanStatistics implements LoanStatistics {
  const factory _LoanStatistics(
      {final int totalActiveLoans,
      final int totalOverdueLoans,
      final int totalReturnedToday,
      final int totalItemsBorrowed,
      final double averageLoanDuration}) = _$LoanStatisticsImpl;

  factory _LoanStatistics.fromJson(Map<String, dynamic> json) =
      _$LoanStatisticsImpl.fromJson;

  @override
  int get totalActiveLoans;
  @override
  int get totalOverdueLoans;
  @override
  int get totalReturnedToday;
  @override
  int get totalItemsBorrowed;
  @override
  double get averageLoanDuration;
  @override
  @JsonKey(ignore: true)
  _$$LoanStatisticsImplCopyWith<_$LoanStatisticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
