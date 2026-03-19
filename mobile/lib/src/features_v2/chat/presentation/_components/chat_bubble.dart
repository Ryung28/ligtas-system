import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile/src/features_v2/chat/domain/entities/chat_message.dart';

// =============================================================================
// ChatBubble
// ─────────────────────────────────────────────────────────────────────────────
// Extracted from chat_screen.dart. Molecule-level widget.
// Renders a single chat message bubble with timestamp and read receipt.
// Shadow: 0.05 opacity per LIGTAS Tactical Premium guidelines.
// =============================================================================

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFFB8FFC6) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.content,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1E293B),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const Gap(4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('hh:mm a').format(message.createdAt.toLocal()),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isMe
                              ? const Color(0xFF279A51)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                      if (isMe) ...[
                        const Gap(4),
                        const Icon(
                          Icons.done_all_rounded,
                          color: Color(0xFF279A51),
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
