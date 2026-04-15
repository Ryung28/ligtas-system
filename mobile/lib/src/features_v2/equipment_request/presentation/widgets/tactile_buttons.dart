import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';

// 🛡️ TACTILE CIRCLE BUTTON: Native Hardware Look (No Overlays)
class TactileCircleButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final SentinelColors sentinel;
  final double size;

  const TactileCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.sentinel,
    this.size = 44,
  });

  @override
  State<TactileCircleButton> createState() => _TactileCircleButtonState();
}

class _TactileCircleButtonState extends State<TactileCircleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _isPressed ? widget.sentinel.containerLow : Colors.white,
          shape: BoxShape.circle,
          // 🛡️ THE TACTILE HACK: Primary Light/Dark Shadows
          boxShadow: _isPressed 
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ]
            : [
                const BoxShadow(
                  color: Colors.white,
                  offset: Offset(-3, -3),
                  blurRadius: 6,
                ),
                BoxShadow(
                  color: const Color(0xFFA2B1C6).withOpacity(0.25),
                  offset: const Offset(3, 3),
                  blurRadius: 6,
                ),
              ],
        ),
        child: Icon(
          widget.icon, 
          size: widget.size * 0.5, 
          color: widget.sentinel.navy,
        ),
      ),
    );
  }
}

// 🛡️ REVIEW BUTTON: The Primary Mission Command Button
class ReviewButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  const ReviewButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    return GestureDetector(
      onTap: isLoading ? null : () {
        HapticFeedback.heavyImpact();
        onPressed();
      },
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: isLoading ? sentinel.containerLow : sentinel.primary,
          borderRadius: BorderRadius.circular(32),
          // 🛡️ NATIVE PRIMARY SHADOW: Clean depth for 120Hz scrolling
          boxShadow: [
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-3, -3),
              blurRadius: 6,
            ),
            BoxShadow(
              color: const Color(0xFFA2B1C6).withOpacity(0.25),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: isLoading 
            ? const SizedBox(
                width: 24, 
                height: 24, 
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text, 
                    style: GoogleFonts.lexend(
                      fontSize: 15, 
                      fontWeight: FontWeight.w900, 
                      color: Colors.white, 
                      letterSpacing: 1,
                    ),
                  ),
                  const Gap(12),
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                ],
              ),
        ),
      ),
    );
  }
}
