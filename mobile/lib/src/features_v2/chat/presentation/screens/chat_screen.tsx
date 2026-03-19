import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/chat_providers.dart';
import '../../domain/entities/chat_message.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String title;

    const ChatScreen({
        super.key,
        required this.roomId,
        required this.title,
    });

    @override
    ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    ref.read(chatSessionProvider(widget.roomId).notifier).sendOptimisticMessage(_controller.text.trim());
    _controller.clear();

    // Smooth scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
            _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
        );
        }
    });
}

@override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatSessionProvider(widget.roomId));

    return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
                title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    const Text('Real-time Coordination', style: TextStyle(fontSize: 10, color: Colors.blueAccent)),
          ],
        ),
    elevation: 0,
        backgroundColor: Colors.white,
            foregroundColor: Colors.black,
      ),
    body: Column(
        children: [
        Expanded(
            child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                        itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message.senderId == ref.watch(chatRepositoryProvider)._client.auth.currentUser?.id;

                            return _ChatBubble(message: message, isMe: isMe);
                        },
            ),
          ),
    _buildInputArea(),
        ],
      ),
    );
}

  Widget _buildInputArea() {
    return Container(
        padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 12
        ),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
          ),
        ],
      ),
    child: Row(
        children: [
        Expanded(
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(24),
              ),
    child: TextField(
        controller: _controller,
        decoration: const InputDecoration(
            hintText: 'Type a message...',
            border: InputBorder.none,
            hintStyle: TextStyle(fontSize: 14),
                ),
    onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
    const Gap(8),
        CircleAvatar(
            backgroundColor: const Color(0xFF3B82F6),
                child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
    onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
}
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

    const _ChatBubble({ required this.message, required this.isMe });

    @override
  Widget build(BuildContext context) {
        return Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                                color: isMe ? const Color(0xFF3B82F6) : Colors.white,
                                    borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(16),
                                            topRight: const Radius.circular(16),
                                                bottomLeft: Radius.circular(isMe ? 16 : 0),
                                                    bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        boxShadow: [
            if (!isMe)
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
            Text(
                message.content,
                style: TextStyle(
                    color: isMe ? Colors.white : const Color(0xFF1E293B),
                        fontSize: 14,
              ),
            ),
        const Gap(4),
            Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                Text(
                    timeago.format(message.createdAt, locale: 'en_short'),
                    style: TextStyle(
                        color: (isMe ? Colors.white : const Color(0xFF64748B)).withOpacity(0.7),
                            fontSize: 10,
                  ),
                ),
        if (isMe) ...[
                  const Gap(4),
            _buildStatusIcon(),
                ],
              ],
            ),
          ],
        ),
      ),
    );
    }

  Widget _buildStatusIcon() {
        if (message.status == MessageStatus.sending) {
            return const SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(strokeWidth: 1, color: Colors.white70)
      );
        }
        if (message.status == MessageStatus.error) {
            return const Icon(Icons.error_outline, size: 12, color: Colors.redAccent);
        }
        return const Icon(Icons.check_rounded, size: 12, color: Colors.white70);
    }
}
