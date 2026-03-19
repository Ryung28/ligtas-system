import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/features_v2/chat/presentation/providers/chat_providers.dart';
import 'package:mobile/src/features_v2/chat/presentation/screens/chat_screen.dart';
import 'package:mobile/src/features_v2/loans/presentation/providers/loan_provider.dart';
import 'package:mobile/src/core/design_system/widgets/app_toast.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';

class ChatFab extends ConsumerWidget {
  const ChatFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for active or pending loans to determine if chat is needed
    final activeLoans = ref.watch(myActiveItemsProvider);
    final pendingLoans = ref.watch(myPendingItemsProvider);
    
    final allRelevantLoans = [...activeLoans, ...pendingLoans];
    
    if (allRelevantLoans.isEmpty) return const SizedBox.shrink();

    final user = ref.watch(currentUserProvider);
    
    // ── Senior FIX: Unified Truth Binding ──
    // Do not use loan-specific providers for the label if the chat is generic support.
    // Use the User ID as the Room ID (Deterministic Support Pattern).
    final supportRoomId = user?.id;
    
    // Watch the identity provider for this SPECIFIC room to match ChatScreen
    final partnerIdentity = supportRoomId != null 
        ? ref.watch(chatPartnerIdentityProvider(supportRoomId))
        : const AsyncValue.data('Admin');

    final fullName = partnerIdentity.maybeWhen(
      data: (name) => (name == null || name.isEmpty) ? 'Admin' : name,
      orElse: () => 'Admin',
    );

    // SENIOR FIX: Strict First Name Tokenization
    final partnerName = fullName.split(' ').first;

    // ── IDENTITY REFRESH: Kinetic Response ──
    // Invalidate partner name/ID if messages arrive to handle hand-offs
    if (supportRoomId != null) {
      ref.listen(chatSyncStreamProvider(supportRoomId), (previous, next) {
        if (next.hasValue && (next.value?.isNotEmpty ?? false)) {
          ref.invalidate(chatPartnerIdentityProvider(supportRoomId));
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 80.0), // Above the dock
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(24),
          ),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // ── Geometric Accent Layer ──
            Positioned.fill(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(24),
                ),
                child: CustomPaint(
                  painter: _TacticalGeometricPainter(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
            ),
            FloatingActionButton.extended(
              isExtended: true,
              onPressed: () => _handleFabPress(context, ref, allRelevantLoans),
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.95), 
              foregroundColor: Colors.white,
              elevation: 0,
              highlightElevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(24),
                ),
              ),
              label: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Chat with',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: Colors.white70,
                          letterSpacing: 0.2,
                        ),
                  ),
                  Text(
                    partnerName.isNotEmpty ? partnerName : 'Admin',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.1,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
              extendedPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              clipBehavior: Clip.none,
              heroTag: 'chat_fab',
            ),
          ],
        ),
      ).animate().scale(delay: 500.ms, curve: Curves.easeOutBack).shimmer(delay: 2.seconds, duration: 1500.ms),
    );
  }

  void _handleFabPress(BuildContext context, WidgetRef ref, List<dynamic> loans) async {
    if (loans.length == 1) {
      // 1. Kinetic Feedback
      HapticFeedback.mediumImpact(); 
      
      // 2. Resolve ID Synchronously (No Await)
      // Following the Tactical Deterministic Pattern: User ID identifies the support thread
      final user = ref.read(currentUserProvider);
      
      if (user != null) {
        final loan = loans.first;
        final roomId = user.id; // Deterministic 1:1 Support Room ID
        
        // 3. Warmup & Navigate Immediately
        ref.read(chatSessionProvider(roomId).notifier).warmUp(); 
        context.push('/chat/$roomId?title=${Uri.encodeComponent(loan.itemName)}');
      } else {
        AppToast.showError(context, 'Please login to start coordination.');
      }
    } else {
      AppToast.showInfo(context, 'Please select an item from the list to start chatting.');
    }
  }
}

class _TacticalGeometricPainter extends CustomPainter {
  final Color color;
  _TacticalGeometricPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(size.width * 0.75, 0), Offset(size.width, size.height * 0.5), paint);
    canvas.drawLine(Offset(size.width * 0.85, 0), Offset(size.width, size.height * 0.3), paint);
    
    final path = Path()
      ..moveTo(size.width - 15, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, 15)
      ..close();
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
