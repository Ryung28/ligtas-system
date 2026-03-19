import 'package:flutter/material.dart';

// =============================================================================
// PulsingDot
// ─────────────────────────────────────────────────────────────────────────────
// Extracted from chat_screen.dart. Atom-level widget.
// Renders a static or pulsing (animated) status dot.
// =============================================================================

class PulsingDot extends StatefulWidget {
  final Color color;
  final bool isPulsing;

  const PulsingDot({super.key, required this.color, required this.isPulsing});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPulsing) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      );
    }

    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.4),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
