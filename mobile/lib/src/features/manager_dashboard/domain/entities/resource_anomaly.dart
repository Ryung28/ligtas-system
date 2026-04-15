import 'package:freezed_annotation/freezed_annotation.dart';

part 'resource_anomaly.freezed.dart';
part 'resource_anomaly.g.dart';

enum AnomalySeverity {
  @JsonValue('critical')
  critical,
  @JsonValue('warning')
  warning,
  @JsonValue('info')
  info,
}

enum AnomalyType {
  @JsonValue('low_stock')
  lowStock,
  @JsonValue('overdue')
  overdue,
  @JsonValue('expiry')
  expiring,
  @JsonValue('maintenance')
  maintenance,
  @JsonValue('dispatch')
  dispatch,
  @JsonValue('audit')
  audit,
}

@freezed
class ResourceAnomaly with _$ResourceAnomaly {
  const ResourceAnomaly._();

  const factory ResourceAnomaly({
    required String id,
    required String itemName,
    required String reason,
    @Default(AnomalySeverity.warning) AnomalySeverity severity,
    @Default(AnomalyType.lowStock) AnomalyType type,
    required DateTime detectedAt,
    @Default(0) int currentStock,
    @Default(0) int threshold,
    String? secondaryDetail, // e.g. "Due in 2 days" or "Borrower: Juan"
    String? referenceId, // ID of the loan or inventory item
  }) = _ResourceAnomaly;

  factory ResourceAnomaly.fromJson(Map<String, dynamic> json) =>
      _$ResourceAnomalyFromJson(json);

  /// UI Helper: Badge text
  String get actionLabel {
    switch (type) {
      case AnomalyType.lowStock:
        return 'RESTOCK';
      case AnomalyType.overdue:
        return 'RECALL';
      case AnomalyType.expiring:
        return 'REPLACE';
      case AnomalyType.maintenance:
        return 'SERVICE';
      case AnomalyType.dispatch:
        return 'DISPENSE';
      case AnomalyType.audit:
        return 'VERIFY';
    }
  }
}
