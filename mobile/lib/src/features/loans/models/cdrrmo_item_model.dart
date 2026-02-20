import 'package:freezed_annotation/freezed_annotation.dart';

part 'cdrrmo_item_model.freezed.dart';
part 'cdrrmo_item_model.g.dart';

@freezed
class CdrrmoItem with _$CdrrmoItem {
  const factory CdrrmoItem({
    required String id,
    required String name,
    required String code,
    required String category,
    required String description,
  }) = _CdrrmoItem;

  factory CdrrmoItem.fromJson(Map<String, dynamic> json) => _$CdrrmoItemFromJson(json);
}