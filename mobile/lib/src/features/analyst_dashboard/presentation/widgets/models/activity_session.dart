import 'package:intl/intl.dart';
import 'package:mobile/src/features/analyst_dashboard/domain/entities/activity_event.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ActivitySession — logical grouping of related borrow_log rows
// Groups: same actor + same EventType + same calendar day
// ─────────────────────────────────────────────────────────────────────────────
class ActivitySession {
  final String actorName;
  EventType type; // 🛡️ MUTABLE: Allows logic to detect MIXED states after initial grouping
  final List<ActivityEvent> events; // sorted newest-first

  ActivitySession({
    required this.actorName,
    required this.type,
    required this.events,
  });

  /// 🛰️ COMMAND: Updates the session type based on internal event consensus
  void updateSessionType() {
    if (events.length > 1) {
      final hasAssetOut = events.any((e) => e.type == EventType.assetOut);
      final hasAssetIn = events.any((e) => e.type == EventType.assetIn);
      
      if (hasAssetOut && hasAssetIn) {
        type = EventType.mixed;
      } else {
        type = events.first.type;
      }
    }
  }

  DateTime get latestTimestamp => events.first.timestamp;

  /// 🛡️ SSOT: Sum of all physical items across all events in this session
  int get totalQuantity => events.fold(0, (sum, e) => sum + e.quantity);

  String get timeDisplay {
    final now = DateTime.now();
    final diff = now.difference(latestTimestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String get sessionTitle {
    if (events.length == 1) {
      final e = events.first;
      return e.quantity > 1 ? '${e.title} (x${e.quantity})' : e.title;
    }
    return '$totalQuantity Items';
  }

  String get sessionSubtitle => actorName;

  String get actorInitials {
    final parts = actorName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return actorName.isNotEmpty ? actorName[0].toUpperCase() : '?';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// buildSessions — groups raw ActivityEvent list into ActivitySession list
// ─────────────────────────────────────────────────────────────────────────────
List<ActivitySession> buildActivitySessions(
  List<ActivityEvent> events, {
  int? cap,
}) {
  final Map<String, ActivitySession> map = {};

  for (final event in events) {
    final dateKey = DateFormat('yyyy-MM-dd').format(event.timestamp);
    final actorKey = (event.actorName ?? 'system').toLowerCase().trim();
    // 🛡️ TACTICAL STRATEGY: Group by actor + date only, ignoring EventType
    // This keeps related items (e.g., partial returns) in the same card.
    final key = '${actorKey}__$dateKey';

    if (map.containsKey(key)) {
      map[key]!.events.add(event);
    } else {
      map[key] = ActivitySession(
        actorName: event.actorName ?? 'System',
        type: event.type, // Initial type, will be updated below
        events: [event],
      );
    }
  }

  // Finalize each session's status (detect MIXED states)
  for (final session in map.values) {
    session.events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    session.updateSessionType();
  }

  final sorted = map.values.toList()
    ..sort((a, b) => b.latestTimestamp.compareTo(a.latestTimestamp));

  return cap != null ? sorted.take(cap).toList() : sorted;
}

// ─────────────────────────────────────────────────────────────────────────────
// groupSessionsByDate — buckets into TODAY / YESTERDAY / full date labels
// ─────────────────────────────────────────────────────────────────────────────
Map<String, List<ActivitySession>> groupSessionsByDate(
  List<ActivitySession> sessions,
) {
  final Map<String, List<ActivitySession>> groups = {};
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  for (final session in sessions) {
    final d = session.latestTimestamp;
    final eventDate = DateTime(d.year, d.month, d.day);

    final String label;
    if (eventDate == today) {
      label = 'TODAY';
    } else if (eventDate == yesterday) {
      label = 'YESTERDAY';
    } else {
      label = DateFormat('MMMM d, y').format(eventDate).toUpperCase();
    }

    groups.putIfAbsent(label, () => []).add(session);
  }

  return groups;
}
