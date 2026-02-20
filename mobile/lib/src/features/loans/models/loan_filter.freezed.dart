// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'loan_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LoanFilter {
  String get query => throw _privateConstructorUsedError;
  LoanSortOption get sortBy => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LoanFilterCopyWith<LoanFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoanFilterCopyWith<$Res> {
  factory $LoanFilterCopyWith(
          LoanFilter value, $Res Function(LoanFilter) then) =
      _$LoanFilterCopyWithImpl<$Res, LoanFilter>;
  @useResult
  $Res call({String query, LoanSortOption sortBy});
}

/// @nodoc
class _$LoanFilterCopyWithImpl<$Res, $Val extends LoanFilter>
    implements $LoanFilterCopyWith<$Res> {
  _$LoanFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? sortBy = null,
  }) {
    return _then(_value.copyWith(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as LoanSortOption,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoanFilterImplCopyWith<$Res>
    implements $LoanFilterCopyWith<$Res> {
  factory _$$LoanFilterImplCopyWith(
          _$LoanFilterImpl value, $Res Function(_$LoanFilterImpl) then) =
      __$$LoanFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String query, LoanSortOption sortBy});
}

/// @nodoc
class __$$LoanFilterImplCopyWithImpl<$Res>
    extends _$LoanFilterCopyWithImpl<$Res, _$LoanFilterImpl>
    implements _$$LoanFilterImplCopyWith<$Res> {
  __$$LoanFilterImplCopyWithImpl(
      _$LoanFilterImpl _value, $Res Function(_$LoanFilterImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? sortBy = null,
  }) {
    return _then(_$LoanFilterImpl(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as LoanSortOption,
    ));
  }
}

/// @nodoc

class _$LoanFilterImpl implements _LoanFilter {
  const _$LoanFilterImpl(
      {this.query = '', this.sortBy = LoanSortOption.newest});

  @override
  @JsonKey()
  final String query;
  @override
  @JsonKey()
  final LoanSortOption sortBy;

  @override
  String toString() {
    return 'LoanFilter(query: $query, sortBy: $sortBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoanFilterImpl &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy));
  }

  @override
  int get hashCode => Object.hash(runtimeType, query, sortBy);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoanFilterImplCopyWith<_$LoanFilterImpl> get copyWith =>
      __$$LoanFilterImplCopyWithImpl<_$LoanFilterImpl>(this, _$identity);
}

abstract class _LoanFilter implements LoanFilter {
  const factory _LoanFilter({final String query, final LoanSortOption sortBy}) =
      _$LoanFilterImpl;

  @override
  String get query;
  @override
  LoanSortOption get sortBy;
  @override
  @JsonKey(ignore: true)
  _$$LoanFilterImplCopyWith<_$LoanFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
