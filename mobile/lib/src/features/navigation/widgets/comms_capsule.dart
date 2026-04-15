import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/src/features_v2/chat/presentation/providers/chat_providers.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/features_v2/chat/presentation/providers/unread_chat_provider.dart';
import '../providers/comms_capsule_provider.dart';
import 'package:flutter/services.dart';

class CommsCapsule extends ConsumerStatefulWidget {
  const CommsCapsule({super.key});

  @override
  ConsumerState<CommsCapsule> createState() => _CommsCapsuleState();
}

class _CommsCapsuleState extends ConsumerState<CommsCapsule> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sentinel = Theme.of(context).sentinel;
    final yPosPercent = ref.watch(commsCapsulePositionProvider);
    final unreadCountAsync = ref.watch(unreadChatCountProvider);
    
    final int unreadCount = unreadCountAsync.maybeWhen(
      data: (count) => count,
      orElse: () => 0,
    );

    // ── High-Visibility Dimensionality ──
    const double capsuleWidth = 18.0; // Increased for better grip
    const double capsuleHeight = 68.0; 
    final double top = yPosPercent * size.height - (capsuleHeight / 2);

    // ── Dynamic Branding Colors ──
    final Color capsuleColor = unreadCount > 0 
        ? Colors.redAccent 
        : AppTheme.primaryBlue;

    return AnimatedPositioned(
      duration: _isDragging ? Duration.zero : const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      right: 8,
      top: top,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          ref.read(commsCapsulePositionProvider.notifier)
              .updatePosition(details.globalPosition.dy, size.height);
        },
        onVerticalDragStart: (_) => setState(() => _isDragging = true),
        onVerticalDragEnd: (_) => setState(() => _isDragging = false),
        onTap: () async {
          HapticFeedback.mediumImpact();
          // 🛡️ PRE-RESOLUTION: Resolve Room ID before navigation
          final repository = ref.read(chatRepositoryProvider);
          final user = Supabase.instance.client.auth.currentUser;
          
          String roomId = user?.id ?? '';
          if (user != null) {
            final realId = await repository.getSupportRoomId();
            if (realId != null) roomId = realId;
          }
          
          if (context.mounted) {
            context.push('/chat/$roomId?title=LIGTAS+Support');
          }
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // ── Pulse Backdrop (Enhanced for visibility) ──
              Container(
                width: capsuleWidth + 16,
                height: capsuleHeight + 16,
                decoration: BoxDecoration(
                  color: capsuleColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .scale(
                  begin: const Offset(1, 1), 
                  end: const Offset(1.4, 1.3), 
                  duration: 2000.ms,
                  curve: Curves.easeInOut,
                )
                .fadeOut(),

              // ── Tactile Capsule (Color Shifted) ──
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: capsuleWidth,
                height: capsuleHeight,
                decoration: BoxDecoration(
                  color: capsuleColor,
                  borderRadius: BorderRadius.circular(capsuleWidth / 2),
                  boxShadow: sentinel.tactile.raised,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Indicators changed to white for contrast against blue/red
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // ── Miniature Unread Badge ──
              if (unreadCount > 0)
                Positioned(
                  top: -8,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        )
        // ── THE BREATHING & NUDGE ANIMATION ──
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.08, 1.05),
          duration: 1500.ms,
          curve: Curves.easeInOut,
        )
        .animate() // Sequential entry animation
        .fadeIn(duration: 400.ms)
        .slideX(
          begin: 1.5, // Start further off-screen
          end: 0, 
          duration: 800.ms,
          curve: Curves.elasticOut,
        )
        .shimmer(delay: 1500.ms, duration: 1000.ms, color: Colors.white.withOpacity(0.3)),
      ),
    );
  }

}
