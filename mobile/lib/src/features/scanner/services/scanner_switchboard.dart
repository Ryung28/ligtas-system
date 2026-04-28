import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../navigation/providers/navigation_provider.dart';
import '../../fast_dispatch/providers/dispatch_controller.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../models/qr_payload.dart';
import '../widgets/scan_result_sheet.dart';

/// 🛡️ ResQTrack TACTICAL SWITCHBOARD
/// Centralized intent dispatcher for all QR scan events.
class LigtasScannerSwitchboard {
  LigtasScannerSwitchboard._();

  static void dispatch(BuildContext context, dynamic ref, LigtasQrPayload payload) {
    // 🛡️ TACTICAL: Suppress dock during transaction lifecycle
    ref
        .read(dockSuppressionControllerProvider.notifier)
        .suppress(DockSuppressionReason.fullScreenFlow);

    payload.when(
      equipment: (protocol, version, action, itemId, itemName) {
        final user = ref.read(currentUserProvider);
        final isManager = user?.canEdit ?? false;

        if (isManager) {
          // 🚀 MANAGER FLOW: Fast Dispatch Hub
          ref.read(fastDispatchControllerProvider.notifier).selectItem(itemId, itemName);
          context.push('/manager/dispatch');
        } else {
          // 📦 USER FLOW: Quick Borrow Sheet
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => ScanResultSheet(payload: payload),
          );
        }
        
        ref.read(dockSuppressionControllerProvider.notifier).release(DockSuppressionReason.fullScreenFlow);
      },
      station: (stationId, locationName) {
        // 🚀 STATION INTENT: Critical Hub Triage
        final encodedName = Uri.encodeComponent(locationName);
        context.push('/manager/station/$stationId?name=$encodedName');
        ref
            .read(dockSuppressionControllerProvider.notifier)
            .release(DockSuppressionReason.fullScreenFlow);
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
        ref
            .read(dockSuppressionControllerProvider.notifier)
            .release(DockSuppressionReason.fullScreenFlow);
      },
    );
  }
}
