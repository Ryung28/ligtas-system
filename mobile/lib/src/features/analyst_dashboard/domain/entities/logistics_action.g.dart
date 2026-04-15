// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logistics_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LogisticsActionImpl _$$LogisticsActionImplFromJson(
        Map<String, dynamic> json) =>
    _$LogisticsActionImpl(
      id: _idToString(json['id']),
      itemName: json['item_name'] as String,
      itemId: _idToString(json['item_id']),
      type: _typeFromJson(json['type'] as String?),
      status: json['status'] == null
          ? ActionStatus.pending
          : _statusFromJson(json['status'] as String?),
      quantity: _toInt(json['quantity']),
      requesterId: _idToString(json['requester_id']),
      requesterName: _idToString(json['requester_name']),
      recipientName: _idToString(json['recipient_name']),
      recipientOffice: _idToString(json['recipient_office']),
      warehouseId: _idToString(json['warehouse_id']),
      binLocation: _idToString(json['bin_location']),
      forensicNote: _idToString(json['forensic_note']),
      forensicImageUrl: _idToString(json['forensic_image_url']),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$LogisticsActionImplToJson(
        _$LogisticsActionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item_name': instance.itemName,
      'item_id': instance.itemId,
      'type': _$ActionTypeEnumMap[instance.type]!,
      'status': _$ActionStatusEnumMap[instance.status]!,
      'quantity': instance.quantity,
      'requester_id': instance.requesterId,
      'requester_name': instance.requesterName,
      'recipient_name': instance.recipientName,
      'recipient_office': instance.recipientOffice,
      'warehouse_id': instance.warehouseId,
      'bin_location': instance.binLocation,
      'forensic_note': instance.forensicNote,
      'forensic_image_url': instance.forensicImageUrl,
      'created_at': instance.createdAt?.toIso8601String(),
    };

const _$ActionTypeEnumMap = {
  ActionType.dispense: 'dispense',
  ActionType.dispose: 'dispose',
  ActionType.audit: 'audit',
  ActionType.returnItem: 'return',
  ActionType.adjustment: 'adjustment',
  ActionType.unknown: 'unknown',
};

const _$ActionStatusEnumMap = {
  ActionStatus.pending: 'pending',
  ActionStatus.completed: 'completed',
  ActionStatus.flagged: 'flagged',
  ActionStatus.unknown: 'unknown',
};
