import 'package:freezed_annotation/freezed_annotation.dart';

part 'station_manifest.freezed.dart';
part 'station_manifest.g.dart';

@freezed
class StationManifestItem with _$StationManifestItem {
  const factory StationManifestItem({
    required String id,
    required String stationId,
    required int inventoryId,
    required int quantityRequired,
    required String itemName,
    String? itemCategory,
    String? imageUrl,
    @Default(0) int currentStock,
  }) = _StationManifestItem;

  factory StationManifestItem.fromJson(Map<String, dynamic> json) => _$StationManifestItemFromJson(json);
}
