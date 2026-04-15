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
  BorrowStep get currentStep => throw _privateConstructorUsedError;
  List<CartItem> get cartItems => throw _privateConstructorUsedError;
  String get borrowerName => throw _privateConstructorUsedError;
  String get borrowerContact => throw _privateConstructorUsedError;
  String get borrowerEmail => throw _privateConstructorUsedError;
  String get borrowerOrganization => throw _privateConstructorUsedError;
  String get purpose => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  DateTime? get expectedReturnDate => throw _privateConstructorUsedError;
  Map<String, DateTime> get itemReturnDates =>
      throw _privateConstructorUsedError;
  Map<String, DateTime> get itemPickupDates =>
      throw _privateConstructorUsedError;
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
      List<CartItem> cartItems,
      String borrowerName,
      String borrowerContact,
      String borrowerEmail,
      String borrowerOrganization,
      String purpose,
      String notes,
      DateTime? expectedReturnDate,
      Map<String, DateTime> itemReturnDates,
      Map<String, DateTime> itemPickupDates,
      bool isSubmitting,
      String? submissionError,
      bool isSuccess});
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
    Object? cartItems = null,
    Object? borrowerName = null,
    Object? borrowerContact = null,
    Object? borrowerEmail = null,
    Object? borrowerOrganization = null,
    Object? purpose = null,
    Object? notes = null,
    Object? expectedReturnDate = freezed,
    Object? itemReturnDates = null,
    Object? itemPickupDates = null,
    Object? isSubmitting = null,
    Object? submissionError = freezed,
    Object? isSuccess = null,
  }) {
    return _then(_value.copyWith(
      currentStep: null == currentStep
          ? _value.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as BorrowStep,
      cartItems: null == cartItems
          ? _value.cartItems
          : cartItems // ignore: cast_nullable_to_non_nullable
              as List<CartItem>,
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
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      expectedReturnDate: freezed == expectedReturnDate
          ? _value.expectedReturnDate
          : expectedReturnDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      itemReturnDates: null == itemReturnDates
          ? _value.itemReturnDates
          : itemReturnDates // ignore: cast_nullable_to_non_nullable
              as Map<String, DateTime>,
      itemPickupDates: null == itemPickupDates
          ? _value.itemPickupDates
          : itemPickupDates // ignore: cast_nullable_to_non_nullable
              as Map<String, DateTime>,
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
      List<CartItem> cartItems,
      String borrowerName,
      String borrowerContact,
      String borrowerEmail,
      String borrowerOrganization,
      String purpose,
      String notes,
      DateTime? expectedReturnDate,
      Map<String, DateTime> itemReturnDates,
      Map<String, DateTime> itemPickupDates,
      bool isSubmitting,
      String? submissionError,
      bool isSuccess});
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
    Object? cartItems = null,
    Object? borrowerName = null,
    Object? borrowerContact = null,
    Object? borrowerEmail = null,
    Object? borrowerOrganization = null,
    Object? purpose = null,
    Object? notes = null,
    Object? expectedReturnDate = freezed,
    Object? itemReturnDates = null,
    Object? itemPickupDates = null,
    Object? isSubmitting = null,
    Object? submissionError = freezed,
    Object? isSuccess = null,
  }) {
    return _then(_$BorrowRequestStateImpl(
      currentStep: null == currentStep
          ? _value.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as BorrowStep,
      cartItems: null == cartItems
          ? _value._cartItems
          : cartItems // ignore: cast_nullable_to_non_nullable
              as List<CartItem>,
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
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      expectedReturnDate: freezed == expectedReturnDate
          ? _value.expectedReturnDate
          : expectedReturnDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      itemReturnDates: null == itemReturnDates
          ? _value._itemReturnDates
          : itemReturnDates // ignore: cast_nullable_to_non_nullable
              as Map<String, DateTime>,
      itemPickupDates: null == itemPickupDates
          ? _value._itemPickupDates
          : itemPickupDates // ignore: cast_nullable_to_non_nullable
              as Map<String, DateTime>,
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
      final List<CartItem> cartItems = const [],
      this.borrowerName = '',
      this.borrowerContact = '',
      this.borrowerEmail = '',
      this.borrowerOrganization = '',
      this.purpose = '',
      this.notes = '',
      this.expectedReturnDate,
      final Map<String, DateTime> itemReturnDates = const {},
      final Map<String, DateTime> itemPickupDates = const {},
      this.isSubmitting = false,
      this.submissionError,
      this.isSuccess = false})
      : _cartItems = cartItems,
        _itemReturnDates = itemReturnDates,
        _itemPickupDates = itemPickupDates;

  @override
  @JsonKey()
  final BorrowStep currentStep;
  final List<CartItem> _cartItems;
  @override
  @JsonKey()
  List<CartItem> get cartItems {
    if (_cartItems is EqualUnmodifiableListView) return _cartItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cartItems);
  }

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
  final String notes;
  @override
  final DateTime? expectedReturnDate;
  final Map<String, DateTime> _itemReturnDates;
  @override
  @JsonKey()
  Map<String, DateTime> get itemReturnDates {
    if (_itemReturnDates is EqualUnmodifiableMapView) return _itemReturnDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_itemReturnDates);
  }

  final Map<String, DateTime> _itemPickupDates;
  @override
  @JsonKey()
  Map<String, DateTime> get itemPickupDates {
    if (_itemPickupDates is EqualUnmodifiableMapView) return _itemPickupDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_itemPickupDates);
  }

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
    return 'BorrowRequestState(currentStep: $currentStep, cartItems: $cartItems, borrowerName: $borrowerName, borrowerContact: $borrowerContact, borrowerEmail: $borrowerEmail, borrowerOrganization: $borrowerOrganization, purpose: $purpose, notes: $notes, expectedReturnDate: $expectedReturnDate, itemReturnDates: $itemReturnDates, itemPickupDates: $itemPickupDates, isSubmitting: $isSubmitting, submissionError: $submissionError, isSuccess: $isSuccess)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BorrowRequestStateImpl &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            const DeepCollectionEquality()
                .equals(other._cartItems, _cartItems) &&
            (identical(other.borrowerName, borrowerName) ||
                other.borrowerName == borrowerName) &&
            (identical(other.borrowerContact, borrowerContact) ||
                other.borrowerContact == borrowerContact) &&
            (identical(other.borrowerEmail, borrowerEmail) ||
                other.borrowerEmail == borrowerEmail) &&
            (identical(other.borrowerOrganization, borrowerOrganization) ||
                other.borrowerOrganization == borrowerOrganization) &&
            (identical(other.purpose, purpose) || other.purpose == purpose) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.expectedReturnDate, expectedReturnDate) ||
                other.expectedReturnDate == expectedReturnDate) &&
            const DeepCollectionEquality()
                .equals(other._itemReturnDates, _itemReturnDates) &&
            const DeepCollectionEquality()
                .equals(other._itemPickupDates, _itemPickupDates) &&
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
      const DeepCollectionEquality().hash(_cartItems),
      borrowerName,
      borrowerContact,
      borrowerEmail,
      borrowerOrganization,
      purpose,
      notes,
      expectedReturnDate,
      const DeepCollectionEquality().hash(_itemReturnDates),
      const DeepCollectionEquality().hash(_itemPickupDates),
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
      final List<CartItem> cartItems,
      final String borrowerName,
      final String borrowerContact,
      final String borrowerEmail,
      final String borrowerOrganization,
      final String purpose,
      final String notes,
      final DateTime? expectedReturnDate,
      final Map<String, DateTime> itemReturnDates,
      final Map<String, DateTime> itemPickupDates,
      final bool isSubmitting,
      final String? submissionError,
      final bool isSuccess}) = _$BorrowRequestStateImpl;

  @override
  BorrowStep get currentStep;
  @override
  List<CartItem> get cartItems;
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
  String get notes;
  @override
  DateTime? get expectedReturnDate;
  @override
  Map<String, DateTime> get itemReturnDates;
  @override
  Map<String, DateTime> get itemPickupDates;
  @override
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
