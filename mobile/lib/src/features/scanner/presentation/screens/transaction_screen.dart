import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/src/features/scanner/models/qr_payload.dart';
import 'package:mobile/src/features/scanner/services/scanner_switchboard.dart';
import 'package:mobile/src/features/scanner/widgets/scan_result_sheet.dart';

/// 🛡️ LIGTAS Transaction Screen
/// Decoupled from app.dart to enforce Feature-First Siloing.
/// Handles QR code payload parsing and presents the confirmation sheet.
class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processQrCode();
    });
  }

  void _processQrCode() {
    final qrCode = GoRouterState.of(context).uri.queryParameters['qrCode'];

    if (qrCode == null || qrCode.isEmpty) {
      _showError('No QR code data received');
      return;
    }

    final LigtasQrPayload? payload = LigtasQrPayload.tryParse(qrCode);

    if (payload == null) {
      _showError('Invalid QR Code. Please scan a LIGTAS label.');
      return;
    }

    // 🚀 UNIFIED DISPATCH: Delegate to Switchboard
    if (mounted) {
      LigtasScannerSwitchboard.dispatch(context, ref, payload);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) context.go('/dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
