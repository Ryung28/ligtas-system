import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

enum NoticeType { success, error, info }

class TacticalNotice {
  static OverlayEntry? _activeEntry;

  static void show(
    BuildContext context, {
    required String message,
    NoticeType type = NoticeType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    // 🛡️ THE LIQUIDATION: Remove existing HUD before showing new one
    _activeEntry?.remove();
    _activeEntry = null;

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _TacticalNoticeWidget(
        message: message,
        type: type,
        onDismiss: () {
          if (entry.mounted) {
            entry.remove();
            if (_activeEntry == entry) _activeEntry = null;
          }
        },
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);

    Future.delayed(duration, () {
      if (entry.mounted && _activeEntry == entry) {
        entry.remove();
        _activeEntry = null;
      }
    });
  }
}

class _TacticalNoticeWidget extends StatelessWidget {
  final String message;
  final NoticeType type;
  final VoidCallback onDismiss;

  const _TacticalNoticeWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final icon = _getIcon();

    return Stack(
      children: [
        // 🛡️ THE PERMEABLE MEMBRANE: This ensures taps pass through the transparent area
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),
        ),
        
        // 🛡️ THE TACTICAL HUD: The actual interactive component
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Material( // 💎 Material moved inside Align to prevent full-screen interception
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: onDismiss,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                      border: Border.all(color: color.withOpacity(0.12), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: color, size: 18),
                        ),
                        const Gap(16),
                        Flexible(
                          child: Text(
                            message,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().slideY(begin: -1, end: 0, duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getColor() {
    switch (type) {
      case NoticeType.success: return const Color(0xFF10B981);
      case NoticeType.error: return const Color(0xFFEF4444);
      case NoticeType.info: return const Color(0xFF0F172A);
    }
  }

  IconData _getIcon() {
    switch (type) {
      case NoticeType.success: return Icons.check_circle_outline_rounded;
      case NoticeType.error: return Icons.error_outline_rounded;
      case NoticeType.info: return Icons.info_outline_rounded;
    }
  }
}
