import 'package:isar/isar.dart';

part 'chat_isar_model.g.dart';

@collection
class ChatMessageIsar {
  Id? isarId; // Internal Isar ID

  @Index(unique: true, replace: true)
  late String id; // Supabase UUID
  
  @Index()
  late String roomId;
  
  late String senderId;
  String? receiverId; // ── Sync parity ──
  late String content;
  late DateTime createdAt;
  late bool isRead;
  late String status; // String representation of MessageStatus
}

