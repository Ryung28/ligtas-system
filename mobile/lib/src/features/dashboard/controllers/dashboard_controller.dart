import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../scanner/widgets/scanner_view.dart';
import '../../scanner/models/qr_payload.dart';
import '../../scanner/widgets/scan_result_sheet.dart';

/// Controller for Dashboard actions and complex navigation logic.
/// Separates the "How" from the "What" in the UI.
class DashboardController {
  final Ref ref;

  DashboardController(this.ref);

  void openScanner(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScannerView(
          onQrCodeDetected: (qrCode) {
            final payload = LigtasQrPayload.tryParse(qrCode);
            
            if (payload == null) {
              _showErrorSnackBar(context, 'Invalid QR Code. Please scan a LIGTAS label.');
              return;
            }

            // Close scanner and show result sheet
            Navigator.of(context).pop();
            _showScanResult(context, payload);
          },
          overlayText: 'Scan Equipment Label',
        ),
      ),
    );
  }

  void _showScanResult(BuildContext context, LigtasQrPayload payload) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScanResultSheet(payload: payload),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

final dashboardControllerProvider = Provider((ref) => DashboardController(ref));
