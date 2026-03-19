import 'package:isar/isar.dart';

part 'notification_config_model.g.dart';

@collection
class NotificationConfig {
  @Index(unique: true)
  Id id = 0; // 🛡️ Tactical Fixed ID: Ensures singleton pattern in Isar

  String? lastFCMToken;
  String? lastRegisteredUserId;
  DateTime? lastSyncedAt;
}
