import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../../navigation/providers/navigation_provider.dart';
import '../../../core/design_system/app_theme.dart';
import 'scanner_view_widgets.dart';

/// 🛡️ ResQTrack SMART SCANNER
/// Unified camera interface with deferred state lifecycle for navigation stability.
class ScannerView extends ConsumerStatefulWidget {
  final String? Function(String) onQrCodeDetected;
  final String? overlayText;
  
  const ScannerView({
    super.key,
    required this.onQrCodeDetected,
    this.overlayText,
  });

  @override
  ConsumerState<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends ConsumerState<ScannerView> {
  static const double _scanCutoutSize = 280;
  late MobileScannerController controller;
  late DockSuppressionController _dockSuppressionController;
  bool _isProcessing = false;
  bool _isTorchOn = false;
  String? _scanErrorMessage;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _dockSuppressionController =
        ref.read(dockSuppressionControllerProvider.notifier);
    Future<void>(() {
      if (!mounted) return;
      _dockSuppressionController.suppress(DockSuppressionReason.scanner);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    Future<void>(() {
      _dockSuppressionController.release(DockSuppressionReason.scanner);
    });
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        HapticFeedback.heavyImpact();
        
        setState(() => _isProcessing = true);
        final validationMessage = widget.onQrCodeDetected(barcode.rawValue!);
        if (validationMessage != null) {
          setState(() {
            _scanErrorMessage = validationMessage;
            _isProcessing = false;
          });
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted && _scanErrorMessage == validationMessage) {
              setState(() => _scanErrorMessage = null);
            }
          });
          return;
        }
        
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scanWindow = Rect.fromCenter(
            center: Offset(
              constraints.maxWidth / 2,
              constraints.maxHeight / 2,
            ),
            width: _scanCutoutSize,
            height: _scanCutoutSize,
          );

          return Stack(
            children: [
          // 1. Camera Feed
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
            scanWindow: scanWindow,
          ),
          
          // 2. Sentinel Overlay
          CustomPaint(
            painter: SentinelOverlayPainter(
              borderColor: const Color(0xFF001A33),
              borderRadius: 32,
              borderLength: 48,
              cutOutSize: _scanCutoutSize,
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
                  SentinelGlassButton(
                    icon: Icons.close_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  SentinelGlassButton(
                    icon: _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    color: _isTorchOn ? AppTheme.warningAmber : Colors.white,
                    onPressed: _toggleTorch,
                  ),
                ],
              ),
            ),
          ),
          
          // 5. Tactical Instructions
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: SentinelGlassPill(
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
          if (_isProcessing) const ScannerIdentifyingOverlay(),
          if (_scanErrorMessage != null)
            ScannerErrorOverlay(message: _scanErrorMessage!),
            ],
          );
        },
      ),
    );
  }
}
