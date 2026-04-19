import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/core/design_system/widgets/tactical_forensic_detail_sheet.dart';
import 'package:mobile/src/features/analyst_dashboard/domain/entities/resource_anomaly.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/src/features/navigation/providers/navigation_provider.dart';

import 'action_hero_panel.dart';
import 'anomaly_shared_widgets.dart';
import 'force_return_dialog.dart';

class AnomalyActionSheetV2 extends ConsumerWidget {
  final ResourceAnomaly anomaly;
  const AnomalyActionSheetV2({super.key, required this.anomaly});

  static Future<T?> show<T>(BuildContext context, WidgetRef ref, ResourceAnomaly anomaly) async {
    ref.read(isDockSuppressedProvider.notifier).state = true;
    final result = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnomalyActionSheetV2(anomaly: anomaly),
    );
    ref.read(isDockSuppressedProvider.notifier).state = false;
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverdue = anomaly.category == AnomalyCategory.overdue ||
        anomaly.reason.toLowerCase().contains('overdue');

    if (isOverdue) return OverdueHeroPanel(anomaly: anomaly);
    return ActionHeroPanel(anomaly: anomaly);
  }
}

class OverdueHeroPanel extends ConsumerWidget {
  final ResourceAnomaly anomaly;
  const OverdueHeroPanel({super.key, required this.anomaly});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final analystName = user?.fullName ?? 'Analyst';
    final sentinel = Theme.of(context).sentinel;

    final person = anomaly.borrowerName ?? 'Unknown Person';
    final org = anomaly.borrowerOrg ?? 'No Org';
    final approvedBy = anomaly.approvedByName ?? 'System';
    final releasedBy = anomaly.releasedByName ?? 'Pending';

    final sentOutDate = anomaly.borrowedAt != null
        ? DateFormat('dd, MMM yyyy\nh:mm a').format(anomaly.borrowedAt!.toLocal())
        : 'N/A';
    final isMobile = anomaly.platformOrigin == 'Mobile';
    final hasReturn = anomaly.borrowId != null && anomaly.inventoryId != null;

    return TacticalForensicDetailSheet(
      id: anomaly.id,
      title: anomaly.itemName,
      statusLabel: 'OVERDUE',
      accentColor: AppTheme.errorRed,
      statusIcon: Icons.timer_off_rounded,
      imagePath: anomaly.imageUrl,
      heroTagPrefix: 'anomaly',
      categoryLabel: 'OVERDUE',
      details: [
        DetailRowData(
          icon: Icons.person_outline_rounded,
          label: 'REQUESTER',
          value: person,
          zone: 'Personnel',
          isHalfWidth: false,
          trailing: Icon(
            isMobile ? Icons.smartphone_rounded : Icons.monitor_rounded,
            size: 11,
            color: isMobile ? Colors.orange : AppTheme.primaryBlue.withOpacity(0.6),
          ),
        ),
        DetailRowData(
          icon: Icons.business_rounded,
          label: 'ORGANIZATION',
          value: org,
          zone: 'Personnel',
          isHalfWidth: false,
        ),
        DetailRowData(
          icon: Icons.shield_outlined,
          label: 'APPROVED BY',
          value: approvedBy,
          zone: 'Transaction',
          isHalfWidth: true,
        ),
        DetailRowData(
          icon: Icons.check_circle_outline_rounded,
          label: 'HANDED BY',
          value: releasedBy,
          zone: 'Transaction',
          isHalfWidth: false,
        ),
        DetailRowData(
          icon: Icons.calendar_month_rounded,
          label: 'TIMESTAMP',
          value: sentOutDate.replaceAll('\n', ' '),
          zone: 'Transaction',
          isHalfWidth: false,
        ),
      ],
      analystNotes: null,
      actionHub: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasReturn)
            AnomalySharedUI.buildConfirmButton(
              sentinel: sentinel,
              label: 'PROCESS RETURN',
              icon: Icons.assignment_return_rounded,
              isProcessing: false,
              onPressed: () => ForceReturnDialog.show(context, anomaly, analystName),
            ),
        ],
      ),
    );
  }
}
