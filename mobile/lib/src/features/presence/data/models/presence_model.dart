import 'package:isar/isar.dart';
import 'package:mobile/src/features/presence/domain/entities/presence.dart';

part 'presence_model.g.dart';

@collection
class PresenceCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String userId;
  
  late DateTime lastSeen;
  late bool isOnline;

  PresenceCollection();

  factory PresenceCollection.fromEntity(UserPresence entity) {
    return PresenceCollection()
      ..userId = entity.userId
      ..lastSeen = entity.lastSeen
      ..isOnline = entity.isOnline;
  }

  UserPresence toEntity() {
    return UserPresence(
      userId: userId,
      lastSeen: lastSeen,
      isOnline: isOnline,
    );
  }
}
