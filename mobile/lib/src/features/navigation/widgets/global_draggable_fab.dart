import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/src/features_v2/chat/presentation/screens/chat_rooms_screen.dart';
import 'package:mobile/src/features_v2/chat/presentation/screens/chat_screen.dart';
import 'package:mobile/src/features_v2/chat/presentation/providers/chat_providers.dart';
import 'package:mobile/src/features_v2/chat/presentation/providers/unread_chat_provider.dart';
import 'package:mobile/src/features_v2/loans/presentation/providers/loan_provider.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/core/design_system/widgets/app_toast.dart';
import 'package:gap/gap.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';

class GlobalDraggableFab extends ConsumerStatefulWidget {
  const GlobalDraggableFab({super.key});

  @override
  ConsumerState<GlobalDraggableFab> createState() => _GlobalDraggableFabState();
}

class _GlobalDraggableFabState extends ConsumerState<GlobalDraggableFab> {
  Offset _position = const Offset(-1, -1);
  bool _isDragging = false;
  double _buttonWidth = 100.0; // Dynamic width holder
  final GlobalKey _buttonKey = GlobalKey();

  void _updateWidth() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize && mounted) {
        if (_buttonWidth != box.size.width) {
          setState(() {
            _buttonWidth = box.size.width;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final user = ref.watch(currentUserProvider);
    final supportRoomId = user?.id;

    // ── SENIOR FIX: Reactive Label Switching ──
    // If Aldro chats today, this updates to 'Aldro'. If Brandon chats tomorrow, it updates to 'Brandon'.
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
    if (supportRoomId != null) {
      ref.listen(chatSyncStreamProvider(supportRoomId), (previous, next) {
        if (next.hasValue && (next.value?.isNotEmpty ?? false)) {
          ref.invalidate(chatPartnerIdentityProvider(supportRoomId));
        }
      });
    }

    final unreadCountAsync = ref.watch(unreadChatCountProvider);
    final int unreadCount = unreadCountAsync.maybeWhen(
      data: (count) => count,
      orElse: () => 0,
    );

    _updateWidth();
    
    if (_position.dx == -1 && _position.dy == -1) {
      _position = Offset(
        size.width - _buttonWidth - 16, 
        size.height - 180,
      );
    }

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: RepaintBoundary(
        child: GestureDetector(
          onPanStart: (details) => setState(() => _isDragging = true),
          onPanUpdate: (details) {
            setState(() {
              _position += details.delta;
              
              double minX = 16;
              double maxX = size.width - _buttonWidth - 16;
              
              double minY = padding.top + 16;
              double maxY = size.height - padding.bottom - 120;

              _position = Offset(
                _position.dx.clamp(minX, maxX),
                _position.dy.clamp(minY, maxY),
              );
            });
          },
          onPanEnd: (details) => setState(() => _isDragging = false),
          onTap: () {
            // 1. Kinetic Feedback
            HapticFeedback.mediumImpact(); 
            
            // 2. Resolve ID Synchronously (No Await)
            // Assuming 1:1 support chat, use current user's ID as room ID
            final user = ref.read(currentUserProvider);
            
            if (user != null) {
              final roomId = user.id;
              // 3. Warmup & Navigate Immediately
              ref.read(chatSessionProvider(roomId).notifier).warmUp(); 
              context.push('/chat/$roomId?title=${Uri.encodeComponent('Admin Support')}');
            } else {
              AppToast.showError(context, 'Please login to access support chat.');
            }
          },
          child: AnimatedScale(
            scale: _isDragging ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Tooltip(
              message: 'Open Chat',
              child: Badge(
                label: Text(unreadCount > 9 ? '9+' : '$unreadCount'),
                isLabelVisible: unreadCount > 0,
                backgroundColor: const Color(0xFFF43F5E), 
                largeSize: 18,
                padding: const EdgeInsets.symmetric(horizontal: 5),
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
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(24),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _TacticalGeometricPainter(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                        ),
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: FloatingActionButton.extended(
                            key: _buttonKey,
                            heroTag: 'chat_fab',
                            onPressed: () {
                              // 1. Kinetic Feedback
                              HapticFeedback.mediumImpact(); 
                              
                              // 2. Resolve ID Synchronously
                              final user = ref.read(currentUserProvider);
                              
                              if (user != null) {
                                final roomId = user.id;
                                // 3. Warmup & Navigate Immediately
                                ref.read(chatSessionProvider(roomId).notifier).warmUp(); 
                                context.push('/chat/$roomId?title=${Uri.encodeComponent('Admin Support')}');
                              } else {
                                AppToast.showError(context, 'Please login to access support chat.');
                              }
                            },
                            extendedPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                            clipBehavior: Clip.none,
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
                            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
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
                                Flexible(
                                  child: Text(
                                    partnerName.isNotEmpty ? partnerName : 'Admin',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                          height: 1.1,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
