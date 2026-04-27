import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/chat_providers.dart';
import '../../domain/entities/chat_message.dart';
import 'package:mobile/src/core/utils/date_formatter.dart';
import 'package:mobile/src/features/presence/presentation/providers/presence_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mobile/src/features_v2/chat/presentation/_components/presence_indicator.dart';
import 'package:mobile/src/features_v2/chat/presentation/_components/chat_bubble.dart';

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
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _playIncomingMessageTone() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      debugPrint('[Chat-Acoustic] Audio playback failed. Verify assets/sounds/notification.mp3 exists. Error: $e');
      // Fallback haptic-like system click so user still gets immediate feedback.
      SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> _markRoomAsRead() async {
    await ref.read(chatSessionProvider(widget.roomId).notifier).markAsRead();
  }

  @override
  void initState() {
    super.initState();
    // 🛡️ PRESENCE ELEVATION: Delegate heartbeat ownership to PresenceController.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(presenceControllerProvider.notifier).triggerChatPulse();
      // Mark as Read immediately on entry
      _markRoomAsRead();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    ref.read(chatSessionProvider(widget.roomId).notifier).sendMessage(_controller.text.trim());
    _controller.clear();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeRoomId = widget.roomId;
    final messages = ref.watch(chatSessionProvider(activeRoomId));
    ref.watch(presenceControllerProvider);
    final syncStatus = ref.watch(chatSyncStreamProvider(activeRoomId));

    // ✅ CONSOLIDATED SNAPSHOT: Single-query identity
    final partnerMeta = ref.watch(partnerMetadataProvider(activeRoomId));
    final partnerName = partnerMeta.valueOrNull?['full_name'] as String? ?? 'ResQTrack Admin';
    final partnerId = partnerMeta.valueOrNull?['id'] as String?;
    final isMetaLoading = partnerMeta.isLoading;

    // 1. Snapshot/Inference Presence
    final presenceAsync = partnerId != null 
        ? ref.watch(partnerPresenceProvider(partnerId)) 
        : const AsyncValue<DateTime?>.data(null);
    
    // 2. Realtime Channel Presence
    final onlineUsersAsync = ref.watch(chatRoomOnlineUsersProvider(activeRoomId));
    final myId = Supabase.instance.client.auth.currentUser?.id;
    final isRealtimeOnline = onlineUsersAsync.value?.any((id) => 
      (partnerId != null && id == partnerId) || 
      (partnerId == null && id != myId)
    ) ?? false;

    // 🔊 ACOUSTIC GUARD: Isolated listener
    ref.listen(chatSyncStreamProvider(activeRoomId), (previous, next) {
      if (!next.hasValue) return;
      final msgs = next.value!;
      final previousCount = previous?.value?.length ?? 0;
      if (msgs.length > previousCount) {
        // chat_repository sorts stream data ascending, so newest is at the tail.
        final latestMessage = msgs.last;
        if (latestMessage.senderId != myId) {
          _markRoomAsRead();
          _playIncomingMessageTone();
        }
      }
    });

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            elevation: 0,
          ),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // ── Tactical HUD Header (Glassmorphic & Asymmetric) ──
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(8),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // 🛡️ Step 1.2: Frosted Effect
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8), // 🛡️ Step 1.3: Silk Transparency
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10), // 🛡️ Soft Neumorphism
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Gap(8),
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A), size: 24),
                          // 🛡️ SENIOR FIX: Safe Navigation Check
                          // If we can pop, go back. If not (deep link/refresh), force go to Dashboard.
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/dashboard');
                            }
                          },
                        ),
                        const Gap(4),
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2), // 🛡️ Step 3.1: Identity Protection
                                ),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  child: isMetaLoading
                                    ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2))
                                    : Text(
                                        partnerName[0].toUpperCase(),
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                ),
                              ),
                              const Gap(12),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // 1. IDENTITY LAYER
                                            isMetaLoading
                                              ? Shimmer.fromColors(
                                                  baseColor: Colors.grey.shade300,
                                                  highlightColor: Colors.grey.shade100,
                                                  child: Container(
                                                    width: 140,
                                                    height: 18,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                  ),
                                                )
                                              : Text(
                                                  partnerName,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: const Color(0xFF0F172A),
                                                    letterSpacing: -0.5,
                                                    shadows: [
                                                      Shadow(
                                                        color: Colors.black.withOpacity(0.05),
                                                        blurRadius: 4,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),

                                            // 2. PRESENCE LAYER
                                            const Gap(2), // Tighten vertical gap
                                            presenceAsync.when(
                                              data: (lastSeen) => PresenceIndicator(
                                                lastSeen: lastSeen,
                                                isRealtimeOnline: isRealtimeOnline,
                                              ),
                                              loading: () => const SizedBox.shrink(),
                                              error: (_, __) => const SizedBox.shrink(),
                                            ),
                                          ],
                                        ),
                                      ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF64748B), size: 22),
                          onPressed: () {}, // 🛡️ Step 3.2: Secondary Action
                        ),
                        const Gap(12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // ── Messages Area (Custom Assets Background) ──
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE0F2FE), // Light Sky Blue
                      Colors.white,
                    ],
                  ),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    image: const AssetImage('assets/3q45h4ryjn5tmm.jpg'),
                    opacity: 0.35, // Balanced visibility
                    colorFilter: ColorFilter.mode(
                      const Color(0xFF3B82F6).withOpacity(0.15),
                      BlendMode.overlay,
                    ),
                  ),
                ),
                child: syncStatus.when(
                  data: (_) => _buildChatList(messages),
                  loading: () => messages.isEmpty 
                      ? const Center(child: CircularProgressIndicator()) 
                      : _buildChatList(messages),
                  error: (error, _) => Center(child: Text('Sync Error: $error')),
                ),
              ),
            ),
            
            // ── Exact Design Input Bar (Carbon Copy) ──
            SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(6, 0, 6, 0),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add_rounded, color: Color(0xFF1E293B), size: 22),
                          onPressed: () {
                            // Logic for Bottom2Widget
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 15),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextFormField(
                            controller: _controller,
                            autofocus: false,
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Message',
                              hintStyle: GoogleFonts.inter(
                                color: const Color(0xFF64748B),
                                fontSize: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.transparent, width: 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.transparent, width: 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsetsDirectional.fromSTEB(15, 10, 15, 10),
                            ),
                            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E293B)),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const AlignmentDirectional(0, 0),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(6, 0, 6, 0),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send_rounded, color: Color(0xFF3B82F6), size: 22),
                            onPressed: _sendMessage,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      // 1. Viewport Physics: Bottom-Up (Standard Chat)
      reverse: true, 
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = Supabase.instance.client.auth.currentUser?.id == message.senderId;
        
        // 2. Manual Date Boundary Detection (The Senior Way)
        // Check if the NEXT item (older message) has a different date.
        // If so, we are at the "top" (chronological start) of the current date group.
        bool showHeader = false;
        if (index == messages.length - 1) {
          // Always show header for the absolute oldest message
          showHeader = true; 
        } else {
          final nextMessage = messages[index + 1];
          final currentDate = DateFormat('yyyy-MM-dd').format(message.createdAt.toLocal());
          final nextDate = DateFormat('yyyy-MM-dd').format(nextMessage.createdAt.toLocal());
          if (currentDate != nextDate) {
            showHeader = true;
          }
        }

        // 3. Render
        if (showHeader) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header goes "above" (visually) the oldest message of the group
              _buildDateHeader(message.createdAt), 
              ChatBubble(message: message, isMe: isMe),
            ],
          );
        }

        return ChatBubble(message: message, isMe: isMe);
      },
    );
  }

  // Extract the header styling to a clean helper
  Widget _buildDateHeader(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9), // Slate-100
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)), // Slate-200
          ),
          child: Text(
            DateFormatter.formatGroupHeader(date),
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF64748B), // Slate-500
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Blue Glow Aura ──
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.05),
                  blurRadius: 100,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      offset: const Offset(0, 10),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.forum_rounded,
                  size: 64,
                  color: Color(0xFF3B82F6),
                ),
              ),
              const Gap(24),
              Text(
                'No messages yet',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              const Gap(12),
              Text(
                'Secure coordination link active.\nSend a message to start.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(60), // Extra bottom padding for visual balance
            ],
          ),
        ],
      ),
    );
  }
}

