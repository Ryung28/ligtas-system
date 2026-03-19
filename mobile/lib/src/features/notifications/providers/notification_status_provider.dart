import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/services/user_notification_service.dart';

part 'notification_status_provider.g.dart';

@riverpod
class NotificationSyncStatus extends _$NotificationSyncStatus {
  @override
  NotificationSyncState build() {
    // 🔗 Bridge: Listen to the global singleton's ValueNotifier
    final notifier = UserNotificationService.syncStatus;
    
    // Initial value
    state = notifier.value;
    
    // Listener to keep Riverpod in sync with the Service
    final listener = () {
      state = notifier.value;
    };
    
    notifier.addListener(listener);
    
    // Cleanup on provider disposal
    ref.onDispose(() => notifier.removeListener(listener));
    
    return notifier.value;
  }

  void retrySync() {
    // Trigger the singleton's hidden logic
    UserNotificationService().initialize();
  }
}
