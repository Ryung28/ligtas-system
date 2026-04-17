import 'package:mobile/src/features/analyst_dashboard/domain/entities/resource_anomaly.dart';

/// Legacy name: same as [sortResourceAnomaliesNewestFirst].
List<ResourceAnomaly> sortAlertsForTriage(List<ResourceAnomaly> items) {
  return sortResourceAnomaliesNewestFirst(items);
}
