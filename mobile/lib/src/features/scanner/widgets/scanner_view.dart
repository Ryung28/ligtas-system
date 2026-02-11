import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

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

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
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
        
        // Reset processing state after a delay to allow for the callback to finish
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _isProcessing = false);
          }
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          
          // Overlay with scan window
          _buildScanOverlay(),
          
          // Animated "Scanning" Line
          Center(
            child: Container(
              width: 250,
              height: 2,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0),
                    Colors.blue,
                    Colors.blue.withOpacity(0),
                  ],
                ),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            .moveY(begin: -125, end: 125, duration: 2.seconds, curve: Curves.easeInOut)
            .fadeIn(duration: 500.ms),
          ),
          
          // Top bar with back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black26,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    backgroundColor: Colors.black26,
                    child: IconButton(
                      onPressed: () => controller.toggleTorch(),
                      icon: const Icon(Icons.flash_off, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Processing indicator
          if (_isProcessing)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.blue,
                      strokeWidth: 3,
                    ).animate().scale(duration: 400.ms, curve: Curves.easeOut),
                    const Gap(20),
                    const Text(
                      'Identifying Equipment...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ).animate().fadeIn(delay: 200.ms).moveY(begin: 10, end: 0),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return Container(
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: Colors.blue,
          borderRadius: 20,
          borderLength: 40,
          borderWidth: 6,
          cutOutSize: 250,
          overlayColor: Colors.black.withOpacity(0.7),
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.only(bottom: 80),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.overlayText ?? 'Scan LIGTAS QR Code',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Hold camera steady near the label',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(rect.left, rect.top, rect.left + borderRadius, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return _getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderHeightSize = height / 2;
    final cutOutWidth = cutOutSize < width ? cutOutSize : width - borderWidth;
    final cutOutHeight = cutOutSize < height ? cutOutSize : height - borderWidth;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final cutOutRect = Rect.fromLTWH(
      borderWidthSize - cutOutWidth / 2,
      borderHeightSize - cutOutHeight / 2,
      cutOutWidth,
      cutOutHeight,
    );

    canvas
      ..saveLayer(
        rect,
        backgroundPaint,
      )
      ..drawRect(rect, backgroundPaint)
      ..drawRRect(
        RRect.fromRectAndRadius(
          cutOutRect,
          Radius.circular(borderRadius),
        ),
        backgroundPaint..blendMode = BlendMode.clear,
      )
      ..restore();

    // Draw corner borders
    final borderRect = RRect.fromRectAndRadius(
      cutOutRect,
      Radius.circular(borderRadius),
    );

    _drawCornerBorders(canvas, borderRect, boxPaint);
  }

  void _drawCornerBorders(Canvas canvas, RRect rect, Paint paint) {
    // Top left
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.top + borderLength)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(rect.left, rect.top, rect.left + borderRadius, rect.top)
        ..lineTo(rect.left + borderLength, rect.top),
      paint,
    );

    // Top right
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - borderLength, rect.top)
        ..lineTo(rect.right - borderRadius, rect.top)
        ..quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + borderRadius)
        ..lineTo(rect.right, rect.top + borderLength),
      paint,
    );

    // Bottom left
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.bottom - borderLength)
        ..lineTo(rect.left, rect.bottom - borderRadius)
        ..quadraticBezierTo(rect.left, rect.bottom, rect.left + borderRadius, rect.bottom)
        ..lineTo(rect.left + borderLength, rect.bottom),
      paint,
    );

    // Bottom right
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - borderLength, rect.bottom)
        ..lineTo(rect.right - borderRadius, rect.bottom)
        ..quadraticBezierTo(rect.right, rect.bottom, rect.right, rect.bottom - borderRadius)
        ..lineTo(rect.right, rect.bottom - borderLength),
      paint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}