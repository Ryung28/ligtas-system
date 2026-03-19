import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/src/features/scanner/models/qr_payload.dart';
import 'package:mobile/src/features/scanner/widgets/scan_result_sheet.dart';

/// 🛡️ LIGTAS Transaction Screen
/// Decoupled from app.dart to enforce Feature-First Siloing.
/// Handles QR code payload parsing and presents the confirmation sheet.
class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
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
      _showError('Invalid QR Code. Please scan a LIGTAS equipment label.');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => ScanResultSheet(payload: payload),
    ).then((_) {
      if (mounted) context.go('/dashboard');
    });
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
