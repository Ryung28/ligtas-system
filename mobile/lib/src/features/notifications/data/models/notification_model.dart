import 'package:isar/isar.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

/// 🛰️ NOTIFICATION ITEM MODEL
/// Mirrors the web dashboard's NotificationItem type
@freezed
class NotificationItem with _$NotificationItem {
  const NotificationItem._();

  const factory NotificationItem({
    required String id,
    String? userId,
    String? referenceId,
    required String title,
    required String message,
    required String time,
    required String type,
    @Default(false) bool isRead,
    @Default({}) Map<String, dynamic> metadata,
  }) = _NotificationItem;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);

  /// Gets the appropriate icon for the notification type
  String get icon {
    switch (type) {
      case 'stock_low':
      case 'stock_out':
        return '📦';
      case 'user_pending':
        return '👤';
      case 'chat_message':
        return '💬';
      case 'borrow_request':
        return '📋';
      case 'item_returned':
        return '📥';
      case 'item_overdue':
        return '⚠️';
      case 'borrow_approved':
        return '✅';
      case 'borrow_rejected':
        return '❌';
      case 'user_approved':
        return '👑';
      case 'user_suspended':
        return '🚫';
      case 'user_reactivated':
        return '🔄';
      case 'system_alert':
        return '🚨';
      default:
        return '🔔';
    }
  }

  /// Gets the appropriate color for the notification type
  String get color {
    switch (type) {
      case 'stock_out':
      case 'item_overdue':
      case 'borrow_rejected':
      case 'user_suspended':
        return '#EF4444'; // Red
      case 'stock_low':
      case 'borrow_request':
      case 'item_returned':
        return '#F59E0B'; // Amber
      case 'borrow_approved':
      case 'user_approved':
      case 'user_reactivated':
        return '#10B981'; // Green
      case 'user_pending':
        return '#3B82F6'; // Blue
      case 'chat_message':
        return '#8B5CF6'; // Violet
      case 'system_alert':
        return '#DC2626'; // Dark Red
      default:
        return '#6B7280'; // Gray
    }
  }

  /// Gets the appropriate action label
  String? get actionLabel {
    switch (type) {
      case 'stock_low':
      case 'stock_out':
        return 'RESTOCK';
      case 'user_pending':
        return 'REVIEW ACCESS';
      case 'chat_message':
        return 'OPEN CHAT';
      case 'borrow_request':
      case 'item_returned':
        return 'MANAGE LOG';
      case 'system_alert':
        return 'VIEW INTEL';
      default:
        return null;
    }
  }

  /// Gets the appropriate action target
  String? get actionTarget {
    switch (type) {
      case 'stock_low':
      case 'stock_out':
        return '/inventory';
      case 'user_pending':
        return '/users?tab=requests';
      case 'chat_message':
        return '/chat/${referenceId ?? ''}';
      case 'borrow_request':
      case 'item_returned':
        return '/logs';
      case 'system_alert':
        return '/dashboard';
      default:
        return null;
    }
  }
}

@collection
class NotificationCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String remoteId;

  String? userId;
  String? referenceId;
  late String title;
  late String message;
  late String time;
  late String type;
  late bool isRead;

  static NotificationCollection fromModel(NotificationItem model) {
    return NotificationCollection()
      ..remoteId = model.id
      ..userId = model.userId
      ..referenceId = model.referenceId
      ..title = model.title
      ..message = model.message
      ..time = model.time
      ..type = model.type
      ..isRead = model.isRead;
  }

  NotificationItem toModel() {
    return NotificationItem(
      id: remoteId,
      userId: userId,
      referenceId: referenceId,
      title: title,
      message: message,
      time: time,
      type: type,
      isRead: isRead,
    );
  }
}