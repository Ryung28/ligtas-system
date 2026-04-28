import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../scanner/widgets/scanner_view.dart';
import '../../scanner/models/qr_payload.dart';
import '../../scanner/services/scanner_switchboard.dart';

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
              return 'That QR is not supported. Please scan an item label.';
            }

            // 🚀 UNIFIED DISPATCH: Delegate to Switchboard
            Navigator.of(context).pop();
            LigtasScannerSwitchboard.dispatch(context, ref, payload);
            return null;
          },
          overlayText: 'QUICK SCAN',
        ),
      ),
    );
  }
}

final dashboardControllerProvider = Provider((ref) => DashboardController(ref));
