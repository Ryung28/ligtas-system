import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../../../core/design_system/app_theme.dart';

class ScannerView extends StatefulWidget {
  final Function(String) onQrCodeDetected;
  final String? overlayText;
  
  const ScannerView({
    super.key,
    required this.onQrCodeDetected,
    this.overlayText,
  });

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  late MobileScannerController controller;
  bool _isProcessing = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        HapticFeedback.heavyImpact();
        
        setState(() => _isProcessing = true);
        widget.onQrCodeDetected(barcode.rawValue!);
        
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _isProcessing = false);
          }
        });
        break;
      }
    }
  }

  void _toggleTorch() {
    controller.toggleTorch();
    setState(() => _isTorchOn = !_isTorchOn);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Feed
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
            // 🛡️ SIMPLICITY: Scan full viewport to prevent aspect-ratio blindness
          ),
          
          // 2. Sentinel Overlay
          CustomPaint(
            painter: _SentinelOverlayPainter(
              borderColor: const Color(0xFF001A33), // Stitch Navy
              borderRadius: 32,
              borderLength: 48,
              cutOutSize: 280,
              overlayColor: Colors.black.withOpacity(0.75),
            ),
            child: Container(),
          ),
          
          // 3. Kinetic Laser Pulse
          Center(
            child: Container(
              width: 280,
              height: 2,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF001A33).withOpacity(0.8),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF001A33).withOpacity(0),
                    const Color(0xFF001A33),
                    const Color(0xFF001A33).withOpacity(0),
                  ],
                ),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            .moveY(begin: -140, end: 140, duration: 2.seconds, curve: Curves.easeInOut)
            .fadeIn(duration: 300.ms),
          ),
          
          // 4. Glass Controls (Top)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SentinelGlassButton(
                    icon: Icons.close_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  _SentinelGlassButton(
                    icon: _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    color: _isTorchOn ? AppTheme.warningAmber : Colors.white,
                    onPressed: _toggleTorch,
                  ),
                ],
              ),
            ),
          ),
          
          // 5. Tactical Instructions (Glass Pill)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: _SentinelGlassPill(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.overlayText?.toUpperCase() ?? 'EQUIPMENT SCANNER',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(6),
                    Text(
                      'STATIONARY ALIGNMENT REQUIRED',
                      style: GoogleFonts.lexend(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
          
          // 6. Softdepth Processing Bridge
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FD), // surface
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
                            color: const Color(0xFF191C1F), // on_surface
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          'ENCRYPTED SYSTEM LINK',
                          style: GoogleFonts.lexend(
                            color: const Color(0xFF43474D), // on_surface_variant
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOutCubic),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SentinelGlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const _SentinelGlassButton({
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
            child: Stack(
              children: [
                // 🛡️ STABILITY: Removed non-uniform border that caused crash
                Center(child: Icon(icon, color: color, size: 26)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SentinelGlassPill extends StatelessWidget {
  final Widget child;

  const _SentinelGlassPill({required this.child});

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
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
                      left: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
                    ),
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _SentinelOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  _SentinelOverlayPainter({
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
    
    // Custom Bracket Shape (Not standard rounded corners)
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
