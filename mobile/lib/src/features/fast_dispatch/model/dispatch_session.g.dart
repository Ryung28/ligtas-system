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
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$DispatchItemImplToJson(_$DispatchItemImpl instance) =>
    <String, dynamic>{
      'inventoryId': instance.inventoryId,
      'itemName': instance.itemName,
      'quantity': instance.quantity,
    };
