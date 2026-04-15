// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_anomaly.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ResourceAnomalyImpl _$$ResourceAnomalyImplFromJson(
        Map<String, dynamic> json) =>
    _$ResourceAnomalyImpl(
      id: json['id'] as String,
      itemName: json['itemName'] as String,
      reason: json['reason'] as String,
      severity:
          $enumDecodeNullable(_$AnomalySeverityEnumMap, json['severity']) ??
              AnomalySeverity.warning,
      type: $enumDecodeNullable(_$AnomalyTypeEnumMap, json['type']) ??
          AnomalyType.lowStock,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      currentStock: (json['currentStock'] as num?)?.toInt() ?? 0,
      threshold: (json['threshold'] as num?)?.toInt() ?? 0,
      secondaryDetail: json['secondaryDetail'] as String?,
      referenceId: json['referenceId'] as String?,
    );

Map<String, dynamic> _$$ResourceAnomalyImplToJson(
        _$ResourceAnomalyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'itemName': instance.itemName,
      'reason': instance.reason,
      'severity': _$AnomalySeverityEnumMap[instance.severity]!,
      'type': _$AnomalyTypeEnumMap[instance.type]!,
      'detectedAt': instance.detectedAt.toIso8601String(),
      'currentStock': instance.currentStock,
      'threshold': instance.threshold,
      'secondaryDetail': instance.secondaryDetail,
      'referenceId': instance.referenceId,
    };

const _$AnomalySeverityEnumMap = {
  AnomalySeverity.critical: 'critical',
  AnomalySeverity.warning: 'warning',
  AnomalySeverity.info: 'info',
};

const _$AnomalyTypeEnumMap = {
  AnomalyType.lowStock: 'low_stock',
  AnomalyType.overdue: 'overdue',
  AnomalyType.expiring: 'expiry',
  AnomalyType.maintenance: 'maintenance',
  AnomalyType.dispatch: 'dispatch',
  AnomalyType.audit: 'audit',
};
