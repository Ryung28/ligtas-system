// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispatch_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BorrowerInfoImpl _$$BorrowerInfoImplFromJson(Map<String, dynamic> json) =>
    _$BorrowerInfoImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      contact: json['contact'] as String,
      office: json['office'] as String?,
      isDraft: json['isDraft'] as bool? ?? false,
    );

Map<String, dynamic> _$$BorrowerInfoImplToJson(_$BorrowerInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'contact': instance.contact,
      'office': instance.office,
      'isDraft': instance.isDraft,
    };

_$DispatchItemImpl _$$DispatchItemImplFromJson(Map<String, dynamic> json) =>
    _$DispatchItemImpl(
      inventoryId: (json['inventoryId'] as num).toInt(),
      itemName: json['itemName'] as String,
      imageUrl: json['imageUrl'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      stockAvailable: (json['stockAvailable'] as num?)?.toInt() ?? 0,
      targetStock: (json['targetStock'] as num?)?.toInt() ?? 0,
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 20,
    );

Map<String, dynamic> _$$DispatchItemImplToJson(_$DispatchItemImpl instance) =>
    <String, dynamic>{
      'inventoryId': instance.inventoryId,
      'itemName': instance.itemName,
      'imageUrl': instance.imageUrl,
      'quantity': instance.quantity,
      'stockAvailable': instance.stockAvailable,
      'targetStock': instance.targetStock,
      'lowStockThreshold': instance.lowStockThreshold,
    };
