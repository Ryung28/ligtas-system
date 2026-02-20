import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        // Immediate physical feedback
        HapticFeedback.heavyImpact();
        
        setState(() => _isProcessing = true);
        widget.onQrCodeDetected(barcode.rawValue!);
        
        // Reset processing state after a delay
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
          ),
          
          // 2. Dark Overlay with Cutout
          CustomPaint(
            painter: _ScannerOverlayPainter(
              borderColor: AppTheme.primaryBlue,
              borderRadius: 24,
              borderLength: 40,
              cutOutSize: 280,
              overlayColor: Colors.black.withOpacity(0.7),
            ),
            child: Container(),
          ),
          
          // 3. Animated "Laser" Pulse
          Center(
            child: Container(
              width: 280,
              height: 120, // Height for the fade
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0),
                    AppTheme.primaryBlue.withOpacity(0.5),
                    AppTheme.primaryBlue.withOpacity(0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            .moveY(begin: -140, end: 140, duration: 2.5.seconds, curve: Curves.easeInOut)
            .fadeIn(duration: 300.ms),
          ),
          
          // 4. Glass Controls (Top)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _GlassIconButton(
                    icon: Icons.close_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  _GlassIconButton(
                    icon: _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    color: _isTorchOn ? AppTheme.warningAmber : Colors.white,
                    onPressed: _toggleTorch,
                  ),
                ],
              ),
            ),
          ),
          
          // 5. Bottom Instructions (Glass Pill)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.overlayText ?? 'Scan Equipment Label',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Gap(4),
                        Text(
                          'Align code within the frame',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
          
          // 6. Processing Overlay (Glass Dialog)
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.2),
                          blurRadius: 32,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryBlue,
                            strokeWidth: 3,
                          ),
                        ),
                        const Gap(24),
                        const Text(
                          'Identifying...',
                          style: TextStyle(
                            color: AppTheme.neutralGray900,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          'Verifying equipment details',
                          style: TextStyle(
                            color: AppTheme.neutralGray600,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const _GlassIconButton({
    required this.icon,
    required this.onPressed,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
      ),
    );
  }
}

// Custom Painter for the Corner Brackets
class _ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  _ScannerOverlayPainter({
    required this.borderColor,
    this.borderWidth = 4.0,
    required this.overlayColor,
    required this.borderRadius,
    required this.borderLength,
    required this.cutOutSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final rect = Rect.fromLTWH(0, 0, width, height);
    
    final cutoutRect = Rect.fromCenter(
      center: Offset(width / 2, height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );

    // 1. Draw Semi-Transparent Overlay with Cutout
    final overlayPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()
          ..addRRect(RRect.fromRectAndRadius(cutoutRect, Radius.circular(borderRadius))),
      ),
      overlayPaint,
    );

    // 2. Draw Glowing Corner Brackets
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = borderColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth + 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Draw corners (Top-Left, Top-Right, Bottom-Left, Bottom-Right)
    final path = Path();
    
    // Top-Left
    path.moveTo(cutoutRect.left, cutoutRect.top + borderLength);
    path.lineTo(cutoutRect.left, cutoutRect.top + borderRadius);
    path.quadraticBezierTo(cutoutRect.left, cutoutRect.top, cutoutRect.left + borderRadius, cutoutRect.top);
    path.lineTo(cutoutRect.left + borderLength, cutoutRect.top);

    // Top-Right
    path.moveTo(cutoutRect.right - borderLength, cutoutRect.top);
    path.lineTo(cutoutRect.right - borderRadius, cutoutRect.top);
    path.quadraticBezierTo(cutoutRect.right, cutoutRect.top, cutoutRect.right, cutoutRect.top + borderRadius);
    path.lineTo(cutoutRect.right, cutoutRect.top + borderLength);

    // Bottom-Right
    path.moveTo(cutoutRect.right, cutoutRect.bottom - borderLength);
    path.lineTo(cutoutRect.right, cutoutRect.bottom - borderRadius);
    path.quadraticBezierTo(cutoutRect.right, cutoutRect.bottom, cutoutRect.right - borderRadius, cutoutRect.bottom);
    path.lineTo(cutoutRect.right - borderLength, cutoutRect.bottom);

    // Bottom-Left
    path.moveTo(cutoutRect.left + borderLength, cutoutRect.bottom);
    path.lineTo(cutoutRect.left + borderRadius, cutoutRect.bottom);
    path.quadraticBezierTo(cutoutRect.left, cutoutRect.bottom, cutoutRect.left, cutoutRect.bottom - borderRadius);
    path.lineTo(cutoutRect.left, cutoutRect.bottom - borderLength);

    // Draw Glow then Border
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
