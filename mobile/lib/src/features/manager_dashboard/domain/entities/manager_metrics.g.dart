// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manager_metrics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ManagerMetricsImpl _$$ManagerMetricsImplFromJson(Map<String, dynamic> json) =>
    _$ManagerMetricsImpl(
      totalAssets: (json['totalAssets'] as num?)?.toInt() ?? 0,
      assetsTrendPercent:
          (json['assetsTrendPercent'] as num?)?.toDouble() ?? 0.0,
      pendingApprovals: (json['pendingApprovals'] as num?)?.toInt() ?? 0,
      activeLoans: (json['activeLoans'] as num?)?.toInt() ?? 0,
      loansTrendPercent: (json['loansTrendPercent'] as num?)?.toDouble() ?? 0.0,
      overdueCount: (json['overdueCount'] as num?)?.toInt() ?? 0,
      overdueTrendPercent:
          (json['overdueTrendPercent'] as num?)?.toDouble() ?? 0.0,
      anomalyCount: (json['anomalyCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ManagerMetricsImplToJson(
        _$ManagerMetricsImpl instance) =>
    <String, dynamic>{
      'totalAssets': instance.totalAssets,
      'assetsTrendPercent': instance.assetsTrendPercent,
      'pendingApprovals': instance.pendingApprovals,
      'activeLoans': instance.activeLoans,
      'loansTrendPercent': instance.loansTrendPercent,
      'overdueCount': instance.overdueCount,
      'overdueTrendPercent': instance.overdueTrendPercent,
      'anomalyCount': instance.anomalyCount,
    };
