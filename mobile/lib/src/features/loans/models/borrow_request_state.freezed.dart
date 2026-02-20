// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'borrow_request_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BorrowRequestState {
// ── Step in the multi-step flow ──
  BorrowStep get currentStep =>
      throw _privateConstructorUsedError; // ── Selected inventory item (the item being requested) ──
  InventoryModel? get selectedItem =>
      throw _privateConstructorUsedError; // ── Form data (Immutable copies of what the user typed) ──
  String get borrowerName => throw _privateConstructorUsedError;
  String get borrowerContact => throw _privateConstructorUsedError;
  String get borrowerEmail => throw _privateConstructorUsedError;
  String get borrowerOrganization => throw _privateConstructorUsedError;
  String get purpose => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  String get notes =>
      throw _privateConstructorUsedError; // ── Borrow logistics ──
  DateTime? get expectedReturnDate =>
      throw _privateConstructorUsedError; // ── Async submission tracking ──
  bool get isSubmitting => throw _privateConstructorUsedError;
  String? get submissionError => throw _privateConstructorUsedError;
  bool get isSuccess => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BorrowRequestStateCopyWith<BorrowRequestState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BorrowRequestStateCopyWith<$Res> {
  factory $BorrowRequestStateCopyWith(
          BorrowRequestState value, $Res Function(BorrowRequestState) then) =
      _$BorrowRequestStateCopyWithImpl<$Res, BorrowRequestState>;
  @useResult
  $Res call(
      {BorrowStep currentStep,
      InventoryModel? selectedItem,
      String borrowerName,
      String borrowerContact,
      String borrowerEmail,
      String borrowerOrganization,
      String purpose,
      int quantity,
      String notes,
      DateTime? expectedReturnDate,
      bool isSubmitting,
      String? submissionError,
      bool isSuccess});

  $InventoryModelCopyWith<$Res>? get selectedItem;
}

/// @nodoc
class _$BorrowRequestStateCopyWithImpl<$Res, $Val extends BorrowRequestState>
    implements $BorrowRequestStateCopyWith<$Res> {
  _$BorrowRequestStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? selectedItem = freezed,
    Object? borrowerName = null,
    Object? borrowerContact = null,
    Object? borrowerEmail = null,
    Object? borrowerOrganization = null,
    Object? purpose = null,
    Object? quantity = null,
    Object? notes = null,
    Object? expectedReturnDate = freezed,
    Object? isSubmitting = null,
    Object? submissionError = freezed,
    Object? isSuccess = null,
  }) {
    return _then(_value.copyWith(
      currentStep: null == currentStep
          ? _value.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as BorrowStep,
      selectedItem: freezed == selectedItem
          ? _value.selectedItem
          : selectedItem // ignore: cast_nullable_to_non_nullable
              as InventoryModel?,
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
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      expectedReturnDate: freezed == expectedReturnDate
          ? _value.expectedReturnDate
          : expectedReturnDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      submissionError: freezed == submissionError
          ? _value.submissionError
          : submissionError // ignore: cast_nullable_to_non_nullable
              as String?,
      isSuccess: null == isSuccess
          ? _value.isSuccess
          : isSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $InventoryModelCopyWith<$Res>? get selectedItem {
    if (_value.selectedItem == null) {
      return null;
    }

    return $InventoryModelCopyWith<$Res>(_value.selectedItem!, (value) {
      return _then(_value.copyWith(selectedItem: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BorrowRequestStateImplCopyWith<$Res>
    implements $BorrowRequestStateCopyWith<$Res> {
  factory _$$BorrowRequestStateImplCopyWith(_$BorrowRequestStateImpl value,
          $Res Function(_$BorrowRequestStateImpl) then) =
      __$$BorrowRequestStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {BorrowStep currentStep,
      InventoryModel? selectedItem,
      String borrowerName,
      String borrowerContact,
      String borrowerEmail,
      String borrowerOrganization,
      String purpose,
      int quantity,
      String notes,
      DateTime? expectedReturnDate,
      bool isSubmitting,
      String? submissionError,
      bool isSuccess});

  @override
  $InventoryModelCopyWith<$Res>? get selectedItem;
}

/// @nodoc
class __$$BorrowRequestStateImplCopyWithImpl<$Res>
    extends _$BorrowRequestStateCopyWithImpl<$Res, _$BorrowRequestStateImpl>
    implements _$$BorrowRequestStateImplCopyWith<$Res> {
  __$$BorrowRequestStateImplCopyWithImpl(_$BorrowRequestStateImpl _value,
      $Res Function(_$BorrowRequestStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? selectedItem = freezed,
    Object? borrowerName = null,
    Object? borrowerContact = null,
    Object? borrowerEmail = null,
    Object? borrowerOrganization = null,
    Object? purpose = null,
    Object? quantity = null,
    Object? notes = null,
    Object? expectedReturnDate = freezed,
    Object? isSubmitting = null,
    Object? submissionError = freezed,
    Object? isSuccess = null,
  }) {
    return _then(_$BorrowRequestStateImpl(
      currentStep: null == currentStep
          ? _value.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as BorrowStep,
      selectedItem: freezed == selectedItem
          ? _value.selectedItem
          : selectedItem // ignore: cast_nullable_to_non_nullable
              as InventoryModel?,
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
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      expectedReturnDate: freezed == expectedReturnDate
          ? _value.expectedReturnDate
          : expectedReturnDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      submissionError: freezed == submissionError
          ? _value.submissionError
          : submissionError // ignore: cast_nullable_to_non_nullable
              as String?,
      isSuccess: null == isSuccess
          ? _value.isSuccess
          : isSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$BorrowRequestStateImpl implements _BorrowRequestState {
  const _$BorrowRequestStateImpl(
      {this.currentStep = BorrowStep.form,
      this.selectedItem,
      this.borrowerName = '',
      this.borrowerContact = '',
      this.borrowerEmail = '',
      this.borrowerOrganization = '',
      this.purpose = '',
      this.quantity = 1,
      this.notes = '',
      this.expectedReturnDate,
      this.isSubmitting = false,
      this.submissionError,
      this.isSuccess = false});

// ── Step in the multi-step flow ──
  @override
  @JsonKey()
  final BorrowStep currentStep;
// ── Selected inventory item (the item being requested) ──
  @override
  final InventoryModel? selectedItem;
// ── Form data (Immutable copies of what the user typed) ──
  @override
  @JsonKey()
  final String borrowerName;
  @override
  @JsonKey()
  final String borrowerContact;
  @override
  @JsonKey()
  final String borrowerEmail;
  @override
  @JsonKey()
  final String borrowerOrganization;
  @override
  @JsonKey()
  final String purpose;
  @override
  @JsonKey()
  final int quantity;
  @override
  @JsonKey()
  final String notes;
// ── Borrow logistics ──
  @override
  final DateTime? expectedReturnDate;
// ── Async submission tracking ──
  @override
  @JsonKey()
  final bool isSubmitting;
  @override
  final String? submissionError;
  @override
  @JsonKey()
  final bool isSuccess;

  @override
  String toString() {
    return 'BorrowRequestState(currentStep: $currentStep, selectedItem: $selectedItem, borrowerName: $borrowerName, borrowerContact: $borrowerContact, borrowerEmail: $borrowerEmail, borrowerOrganization: $borrowerOrganization, purpose: $purpose, quantity: $quantity, notes: $notes, expectedReturnDate: $expectedReturnDate, isSubmitting: $isSubmitting, submissionError: $submissionError, isSuccess: $isSuccess)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BorrowRequestStateImpl &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.selectedItem, selectedItem) ||
                other.selectedItem == selectedItem) &&
            (identical(other.borrowerName, borrowerName) ||
                other.borrowerName == borrowerName) &&
            (identical(other.borrowerContact, borrowerContact) ||
                other.borrowerContact == borrowerContact) &&
            (identical(other.borrowerEmail, borrowerEmail) ||
                other.borrowerEmail == borrowerEmail) &&
            (identical(other.borrowerOrganization, borrowerOrganization) ||
                other.borrowerOrganization == borrowerOrganization) &&
            (identical(other.purpose, purpose) || other.purpose == purpose) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.expectedReturnDate, expectedReturnDate) ||
                other.expectedReturnDate == expectedReturnDate) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.submissionError, submissionError) ||
                other.submissionError == submissionError) &&
            (identical(other.isSuccess, isSuccess) ||
                other.isSuccess == isSuccess));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentStep,
      selectedItem,
      borrowerName,
      borrowerContact,
      borrowerEmail,
      borrowerOrganization,
      purpose,
      quantity,
      notes,
      expectedReturnDate,
      isSubmitting,
      submissionError,
      isSuccess);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BorrowRequestStateImplCopyWith<_$BorrowRequestStateImpl> get copyWith =>
      __$$BorrowRequestStateImplCopyWithImpl<_$BorrowRequestStateImpl>(
          this, _$identity);
}

abstract class _BorrowRequestState implements BorrowRequestState {
  const factory _BorrowRequestState(
      {final BorrowStep currentStep,
      final InventoryModel? selectedItem,
      final String borrowerName,
      final String borrowerContact,
      final String borrowerEmail,
      final String borrowerOrganization,
      final String purpose,
      final int quantity,
      final String notes,
      final DateTime? expectedReturnDate,
      final bool isSubmitting,
      final String? submissionError,
      final bool isSuccess}) = _$BorrowRequestStateImpl;

  @override // ── Step in the multi-step flow ──
  BorrowStep get currentStep;
  @override // ── Selected inventory item (the item being requested) ──
  InventoryModel? get selectedItem;
  @override // ── Form data (Immutable copies of what the user typed) ──
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
  int get quantity;
  @override
  String get notes;
  @override // ── Borrow logistics ──
  DateTime? get expectedReturnDate;
  @override // ── Async submission tracking ──
  bool get isSubmitting;
  @override
  String? get submissionError;
  @override
  bool get isSuccess;
  @override
  @JsonKey(ignore: true)
  _$$BorrowRequestStateImplCopyWith<_$BorrowRequestStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
