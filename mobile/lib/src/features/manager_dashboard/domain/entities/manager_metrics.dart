import 'package:freezed_annotation/freezed_annotation.dart';

part 'manager_metrics.freezed.dart';
part 'manager_metrics.g.dart';

@freezed
class ManagerMetrics with _$ManagerMetrics {
  const factory ManagerMetrics({
    @Default(0) int totalAssets,
    @Default(0.0) double assetsTrendPercent,
    @Default(0) int pendingApprovals,
    @Default(0) int activeLoans,
    @Default(0.0) double loansTrendPercent,
    @Default(0) int overdueCount,
    @Default(0.0) double overdueTrendPercent,
    @Default(0) int anomalyCount,
  }) = _ManagerMetrics;

  factory ManagerMetrics.fromJson(Map<String, dynamic> json) => _$ManagerMetricsFromJson(json);
}
