// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_manifest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StationManifestItemImpl _$$StationManifestItemImplFromJson(
        Map<String, dynamic> json) =>
    _$StationManifestItemImpl(
      id: json['id'] as String,
      stationId: json['stationId'] as String,
      inventoryId: (json['inventoryId'] as num).toInt(),
      quantityRequired: (json['quantityRequired'] as num).toInt(),
      itemName: json['itemName'] as String,
      itemCategory: json['itemCategory'] as String?,
      imageUrl: json['imageUrl'] as String?,
      currentStock: (json['currentStock'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$StationManifestItemImplToJson(
        _$StationManifestItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stationId': instance.stationId,
      'inventoryId': instance.inventoryId,
      'quantityRequired': instance.quantityRequired,
      'itemName': instance.itemName,
      'itemCategory': instance.itemCategory,
      'imageUrl': instance.imageUrl,
      'currentStock': instance.currentStock,
    };
