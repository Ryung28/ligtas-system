import '../../data/models/notification_model.dart';

/// Resolves a notification into an in-app route.
/// Keeps routing logic isolated from UI widgets.
class NotificationRouteResolver {
  static String resolve(NotificationItem notification) {
    final meta = notification.metadata;
    final type = notification.type;

    String? asString(dynamic value) {
      if (value == null) return null;
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    final referenceId = asString(notification.referenceId);
    final roomId = asString(meta['room_id']) ?? asString(meta['roomId']) ?? referenceId;
    final itemId = asString(meta['item_id']) ?? asString(meta['id']) ?? referenceId;

    if (type == 'chat_message' && roomId != null) {
      return '/chat/$roomId';
    }

    if (type == 'stock_low' || type == 'stock_out' || type == 'low_stock') {
      if (itemId != null) return '/inventory?id=$itemId';
      return '/inventory';
    }

    if (type == 'borrow_request' ||
        type == 'borrow_approved' ||
        type == 'borrow_rejected' ||
        type == 'item_returned' ||
        type == 'item_overdue') {
      return '/requests';
    }

    if (type.startsWith('user_')) {
      return '/profile';
    }

    return '/dashboard';
  }
}
