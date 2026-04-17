import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/resource_anomaly.dart';
import '../controllers/analyst_dashboard_controller.dart';

/// Local UI: search box text.
final alertQueueSearchProvider = StateProvider<String>((ref) => '');

/// Local UI: selected chip (All, Critical, …).
final alertQueueFilterProvider = StateProvider<String>((ref) => 'All');

/// `true` = newest first, `false` = oldest first (search + chip filters still apply).
final alertQueueSortNewestFirstProvider = StateProvider<bool>((ref) => true);

/// After the first frame, list entrance animations are skipped (same idea as the main dashboard).
final alertQueueEntryCompleteProvider = StateProvider<bool>((ref) => false);

/// Raw stream list (no extra work in the widget).
final alertQueueRawListProvider = Provider<List<ResourceAnomaly>>((ref) {
  return ref.watch(watchResourceAnomaliesProvider).valueOrNull ?? [];
});

/// Filtered by search + chip; sorting stays out of the screen `build`.
final alertQueueFilteredProvider = Provider<List<ResourceAnomaly>>((ref) {
  final alerts = ref.watch(alertQueueRawListProvider);
  final searchQuery = ref.watch(alertQueueSearchProvider);
  final activeFilter = ref.watch(alertQueueFilterProvider);
  final q = searchQuery.toLowerCase();

  return alerts.where((a) {
    if (!a.itemName.toLowerCase().contains(q)) return false;

    switch (activeFilter) {
      case 'All':
        return true;
      case 'Critical':
        return a.severity == AnomalySeverity.critical;
      case 'Inventory':
        return a.category == AnomalyCategory.depletion;
      case 'Logistics':
        return a.category == AnomalyCategory.logistics;
      case 'Overdue':
        return a.category == AnomalyCategory.overdue;
      case 'Access':
        return a.category == AnomalyCategory.access;
      default:
        return true;
    }
  }).toList();
});

final alertQueueSortedProvider = Provider<List<ResourceAnomaly>>((ref) {
  final filtered = ref.watch(alertQueueFilteredProvider);
  final newestFirst = ref.watch(alertQueueSortNewestFirstProvider);
  return sortResourceAnomaliesByRecency(filtered, newestFirst: newestFirst);
});

/// One pass over the raw list for chip badge counts (not O(chips × N) per build from the Row).
final alertQueueFilterCountsProvider = Provider<Map<String, int>>((ref) {
  final alerts = ref.watch(alertQueueRawListProvider);
  var critical = 0;
  var inventory = 0;
  var logistics = 0;
  var overdue = 0;
  var access = 0;
  for (final a in alerts) {
    if (a.severity == AnomalySeverity.critical) critical++;
    switch (a.category) {
      case AnomalyCategory.depletion:  inventory++; break;
      case AnomalyCategory.logistics:  logistics++; break;
      case AnomalyCategory.overdue:    overdue++; break;
      case AnomalyCategory.access:     access++; break;
      default: break;
    }
  }
  return {
    'All': alerts.length,
    'Critical': critical,
    'Inventory': inventory,
    'Logistics': logistics,
    'Overdue': overdue,
    'Access': access,
  };
});
