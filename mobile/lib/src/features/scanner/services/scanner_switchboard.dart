import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../navigation/providers/navigation_provider.dart';
import '../models/qr_payload.dart';
import '../widgets/scan_result_sheet.dart';

/// 🛡️ LIGTAS TACTICAL SWITCHBOARD
/// Centralized intent dispatcher for all QR scan events.
/// Decouples UI entry points (FAB, Deep-link, Camera) from business routing.
class LigtasScannerSwitchboard {
  LigtasScannerSwitchboard._();

  static void dispatch(BuildContext context, WidgetRef ref, LigtasQrPayload payload) {
    // 🛡️ TACTICAL: Suppress dock during transaction lifecycle
    ref.read(isDockSuppressedProvider.notifier).state = true;

    payload.when(
      equipment: (protocol, version, action, itemId, itemName) {
        // 🛠️ EQUIPMENT INTENT: Item-level transaction sheet
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          isDismissible: true,
          builder: (context) => ScanResultSheet(payload: payload),
        ).then((_) {
          // Restore dock after sheet is dismissed
          ref.read(isDockSuppressedProvider.notifier).state = false;
        });
      },
      station: (stationId, locationName) {
        // 🚀 STATION INTENT: Critical Hub Triage
        final encodedName = Uri.encodeComponent(locationName);
        context.push('/manager/station/$stationId?name=$encodedName');
        // Restore dock as we are moving to a full-screen view
        ref.read(isDockSuppressedProvider.notifier).state = false;
      },
      person: (personId, personName, role) {
        // 👥 PERSONNEL INTENT: Identity verification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Personnel Identified: $personName ($role)'),
            backgroundColor: const Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Instant restoration for non-navigating intents
        ref.read(isDockSuppressedProvider.notifier).state = false;
      },
    );
  }
}
