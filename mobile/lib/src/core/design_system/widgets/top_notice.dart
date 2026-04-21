import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum TopNoticeType { success, error, info, warning }

class TopNotice {
  static OverlayEntry? _activeEntry;
  static Timer? _dismissTimer;

  static void show(
    BuildContext context, {
    required String message,
    TopNoticeType type = TopNoticeType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    _dismissTimer?.cancel();
    _removeActive();

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final scheme = _noticeScheme(type);
    final topInset = MediaQuery.of(context).padding.top;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _TopNoticeWidget(
        message: message,
        icon: scheme.icon,
        background: scheme.background,
        border: scheme.border,
        iconColor: scheme.iconColor,
        textColor: scheme.textColor,
        topInset: topInset,
        onDismissed: _removeActive,
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);
    _dismissTimer = Timer(duration, _removeActive);
  }

  static void _removeActive() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _activeEntry?.remove();
    _activeEntry = null;
  }

  static _TopNoticeScheme _noticeScheme(TopNoticeType type) {
    const charcoal = Color(0xFF0F172A);
    const white = Color(0xFFF8FAFC);
    switch (type) {
      case TopNoticeType.success:
        return const _TopNoticeScheme(
          icon: Icons.check_circle_rounded,
          background: charcoal,
          border: Color(0xFF334155),
          iconColor: Color(0xFF34D399),
          textColor: white,
        );
      case TopNoticeType.error:
        return const _TopNoticeScheme(
          icon: Icons.error_rounded,
          background: charcoal,
          border: Color(0xFF334155),
          iconColor: Color(0xFFFB7185),
          textColor: white,
        );
      case TopNoticeType.warning:
        return const _TopNoticeScheme(
          icon: Icons.warning_rounded,
          background: charcoal,
          border: Color(0xFF334155),
          iconColor: Color(0xFFFBBF24),
          textColor: white,
        );
      case TopNoticeType.info:
        return const _TopNoticeScheme(
          icon: Icons.info_rounded,
          background: charcoal,
          border: Color(0xFF334155),
          iconColor: Color(0xFF60A5FA),
          textColor: white,
        );
    }
  }
}

class _TopNoticeScheme {
  final IconData icon;
  final Color background;
  final Color border;
  final Color iconColor;
  final Color textColor;

  const _TopNoticeScheme({
    required this.icon,
    required this.background,
    required this.border,
    required this.iconColor,
    required this.textColor,
  });
}

class _TopNoticeWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color background;
  final Color border;
  final Color iconColor;
  final Color textColor;
  final double topInset;
  final VoidCallback onDismissed;

  const _TopNoticeWidget({
    required this.message,
    required this.icon,
    required this.background,
    required this.border,
    required this.iconColor,
    required this.textColor,
    required this.topInset,
    required this.onDismissed,
  });

  @override
  State<_TopNoticeWidget> createState() => _TopNoticeWidgetState();
}

class _TopNoticeWidgetState extends State<_TopNoticeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 170),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep clear of device status bar/notch and app header icons.
    final topOffset = widget.topInset + 24;
    return Positioned(
      top: topOffset,
      left: 12,
      right: 12,
      child: IgnorePointer(
        ignoring: false,
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _fade,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: widget.onDismissed,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: widget.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: widget.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(widget.icon, size: 18, color: widget.iconColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: widget.textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.close_rounded, size: 16, color: Colors.white70),
                    ],
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
