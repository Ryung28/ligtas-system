import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 🛡️ TACTICAL SCANNER OVERLAY
class SentinelOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  SentinelOverlayPainter({
    required this.borderColor,
    this.borderWidth = 3.0,
    required this.overlayColor,
    required this.borderRadius,
    required this.borderLength,
    required this.cutOutSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    
    final cutoutRect = Rect.fromCenter(
      center: Offset(width / 2, height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );

    // 1. Draw Tactical Dark Overlay
    final overlayPaint = Paint()..color = overlayColor;
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, width, height)),
        Path()..addRRect(RRect.fromRectAndRadius(cutoutRect, Radius.circular(borderRadius))),
      ),
      overlayPaint,
    );

    // 2. Draw Precision Brackets (Navy Contrast)
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.square;

    final path = Path();
    
    // Top-Left
    path.moveTo(cutoutRect.left, cutoutRect.top + borderLength);
    path.lineTo(cutoutRect.left, cutoutRect.top);
    path.lineTo(cutoutRect.left + borderLength, cutoutRect.top);

    // Top-Right
    path.moveTo(cutoutRect.right - borderLength, cutoutRect.top);
    path.lineTo(cutoutRect.right, cutoutRect.top);
    path.lineTo(cutoutRect.right, cutoutRect.top + borderLength);

    // Bottom-Right
    path.moveTo(cutoutRect.right, cutoutRect.bottom - borderLength);
    path.lineTo(cutoutRect.right, cutoutRect.bottom);
    path.lineTo(cutoutRect.right - borderLength, cutoutRect.bottom);

    // Bottom-Left
    path.moveTo(cutoutRect.left + borderLength, cutoutRect.bottom);
    path.lineTo(cutoutRect.left, cutoutRect.bottom);
    path.lineTo(cutoutRect.left, cutoutRect.bottom - borderLength);

    canvas.drawPath(path, borderPaint);
    
    // Add inner white indicators for high precision
    final innerPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRRect(
      RRect.fromRectAndRadius(cutoutRect.inflate(1), Radius.circular(borderRadius)), 
      innerPaint
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 🛡️ GLASS-MORPHIC ACTION BUTTON
class SentinelGlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const SentinelGlassButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Center(child: Icon(icon, color: color, size: 26)),
          ),
        ),
      ),
    );
  }
}

/// 🛡️ TACTICAL INSTRUCTION PILL
class SentinelGlassPill extends StatelessWidget {
  final Widget child;

  const SentinelGlassPill({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// 🛡️ PROCESSING STATE OVERLAY
class ScannerIdentifyingOverlay extends StatelessWidget {
  const ScannerIdentifyingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FD),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    color: Color(0xFF001A33),
                    strokeWidth: 4,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                const Gap(24),
                Text(
                  'IDENTIFYING',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF191C1F),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const Gap(4),
                Text(
                  'ENCRYPTED SYSTEM LINK',
                  style: GoogleFonts.lexend(
                    color: const Color(0xFF43474D),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutCubic),
        ),
      ),
    );
  }
}

class ScannerErrorOverlay extends StatelessWidget {
  final String message;

  const ScannerErrorOverlay({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.45),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FD),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFDA4AF), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: Color(0xFFBE123C), size: 22),
              const Gap(10),
              Flexible(
                child: Text(
                  message,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF881337),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 120.ms).scale(begin: const Offset(0.96, 0.96)),
      ),
    );
  }
}
