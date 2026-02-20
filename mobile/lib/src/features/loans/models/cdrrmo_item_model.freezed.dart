// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cdrrmo_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CdrrmoItem _$CdrrmoItemFromJson(Map<String, dynamic> json) {
  return _CdrrmoItem.fromJson(json);
}

/// @nodoc
mixin _$CdrrmoItem {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CdrrmoItemCopyWith<CdrrmoItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CdrrmoItemCopyWith<$Res> {
  factory $CdrrmoItemCopyWith(
          CdrrmoItem value, $Res Function(CdrrmoItem) then) =
      _$CdrrmoItemCopyWithImpl<$Res, CdrrmoItem>;
  @useResult
  $Res call(
      {String id,
      String name,
      String code,
      String category,
      String description});
}

/// @nodoc
class _$CdrrmoItemCopyWithImpl<$Res, $Val extends CdrrmoItem>
    implements $CdrrmoItemCopyWith<$Res> {
  _$CdrrmoItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = null,
    Object? category = null,
    Object? description = null,
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
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CdrrmoItemImplCopyWith<$Res>
    implements $CdrrmoItemCopyWith<$Res> {
  factory _$$CdrrmoItemImplCopyWith(
          _$CdrrmoItemImpl value, $Res Function(_$CdrrmoItemImpl) then) =
      __$$CdrrmoItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String code,
      String category,
      String description});
}

/// @nodoc
class __$$CdrrmoItemImplCopyWithImpl<$Res>
    extends _$CdrrmoItemCopyWithImpl<$Res, _$CdrrmoItemImpl>
    implements _$$CdrrmoItemImplCopyWith<$Res> {
  __$$CdrrmoItemImplCopyWithImpl(
      _$CdrrmoItemImpl _value, $Res Function(_$CdrrmoItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = null,
    Object? category = null,
    Object? description = null,
  }) {
    return _then(_$CdrrmoItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CdrrmoItemImpl implements _CdrrmoItem {
  const _$CdrrmoItemImpl(
      {required this.id,
      required this.name,
      required this.code,
      required this.category,
      required this.description});

  factory _$CdrrmoItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$CdrrmoItemImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String code;
  @override
  final String category;
  @override
  final String description;

  @override
  String toString() {
    return 'CdrrmoItem(id: $id, name: $name, code: $code, category: $category, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CdrrmoItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, code, category, description);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CdrrmoItemImplCopyWith<_$CdrrmoItemImpl> get copyWith =>
      __$$CdrrmoItemImplCopyWithImpl<_$CdrrmoItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CdrrmoItemImplToJson(
      this,
    );
  }
}

abstract class _CdrrmoItem implements CdrrmoItem {
  const factory _CdrrmoItem(
      {required final String id,
      required final String name,
      required final String code,
      required final String category,
      required final String description}) = _$CdrrmoItemImpl;

  factory _CdrrmoItem.fromJson(Map<String, dynamic> json) =
      _$CdrrmoItemImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get code;
  @override
  String get category;
  @override
  String get description;
  @override
  @JsonKey(ignore: true)
  _$$CdrrmoItemImplCopyWith<_$CdrrmoItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
