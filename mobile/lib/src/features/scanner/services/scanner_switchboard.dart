import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../navigation/providers/navigation_provider.dart';
import '../../fast_dispatch/providers/dispatch_controller.dart';
import '../models/qr_payload.dart';
import '../widgets/scan_result_sheet.dart';

/// 🛡️ ResQTrack TACTICAL SWITCHBOARD
/// Centralized intent dispatcher for all QR scan events.
class LigtasScannerSwitchboard {
  LigtasScannerSwitchboard._();

  static void dispatch(BuildContext context, WidgetRef ref, LigtasQrPayload payload) {
    // 🛡️ TACTICAL: Suppress dock during transaction lifecycle
    ref.read(isDockSuppressedProvider.notifier).state = true;

    payload.when(
      equipment: (protocol, version, action, itemId, itemName) {
        // 🚀 FAST DISPATCH BRIDGE: Hydrate controller and navigate to Hub
        ref.read(fastDispatchControllerProvider.notifier).selectItem(itemId, itemName);
        
        context.push('/manager/dispatch');
        ref.read(isDockSuppressedProvider.notifier).state = false;
      },
      station: (stationId, locationName) {
        // 🚀 STATION INTENT: Critical Hub Triage
        final encodedName = Uri.encodeComponent(locationName);
        context.push('/manager/station/$stationId?name=$encodedName');
        ref.read(isDockSuppressedProvider.notifier).state = false;
      },
      person: (personId, personName, role, phone) {
        // 👥 PERSONNEL INTENT: Identity verification
        context.push('/transaction'); // Legacy transaction screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Personnel Identified: $personName ($role)'),
            backgroundColor: const Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(isDockSuppressedProvider.notifier).state = false;
      },
    );
  }
}
