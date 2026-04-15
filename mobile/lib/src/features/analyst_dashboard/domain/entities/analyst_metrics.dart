import 'package:freezed_annotation/freezed_annotation.dart';

part 'analyst_metrics.freezed.dart';
part 'analyst_metrics.g.dart';

@freezed
class AnalystMetrics with _$AnalystMetrics {
  const AnalystMetrics._();

  const factory AnalystMetrics({
    @Default(0) int totalAssets,
    @Default(0.0) double assetsTrendPercent,
    @Default(0) int pendingApprovals,
    @Default(0) int activeLoans,
    @Default(0.0) double loansTrendPercent,
    @Default(0) int overdueCount,
    @Default(0.0) double overdueTrendPercent,
    @Default(0) int anomalyCount,
  }) = _AnalystMetrics;

  factory AnalystMetrics.fromJson(Map<String, dynamic> json) =>
      _$AnalystMetricsFromJson(json);

  /// Semantic color for trends (Green=Positive, Red=Negative)
  bool get isAssetTrendPositive => assetsTrendPercent >= 0;
  bool get isLoanTrendStable => loansTrendPercent.abs() < 5.0;
  bool get hasOverdueAlert => overdueCount > 0;
  bool get hasCriticalAnomalies => anomalyCount > 0;
}
