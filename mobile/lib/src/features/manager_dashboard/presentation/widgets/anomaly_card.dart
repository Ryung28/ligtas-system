import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../../../../core/design_system/app_theme.dart';
import '../../domain/entities/resource_anomaly.dart';
import 'package:intl/intl.dart';

class AnomalyCard extends StatelessWidget {
  final ResourceAnomaly anomaly;
  final VoidCallback? onTap;

  const AnomalyCard({
    super.key,
    required this.anomaly,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor();
    final typeIcon = _getTypeIcon();
    
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16), // 🛡️ COMPRESSION
      decoration: BoxDecoration(
        color: AppTheme.neutralGray900,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: severityColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  typeIcon,
                  color: severityColor,
                  size: 18,
                ),
              ),
              const Gap(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anomaly.itemName.toUpperCase(),
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(2),
                    Text(
                      _getTypeLabel(),
                      style: GoogleFonts.lexend(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: severityColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(12),
          Text(
            anomaly.reason,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
              fontSize: 11,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (anomaly.secondaryDetail != null) ...[
            const Gap(4),
            Text(
              anomaly.secondaryDetail!,
              style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryBlue.withValues(alpha: 0.8),
              ),
            ),
          ],
          const Spacer(),
          
          // 🏗️ ACTION ROW: Direct Dashboard Resolution
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: severityColor.withValues(alpha: 0.3)),
                    ),
                    child: Center(
                      child: Text(
                        anomaly.actionLabel,
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: severityColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  DateFormat.jm().format(anomaly.detectedAt),
                  style: GoogleFonts.lexend(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor() {
    switch (anomaly.severity) {
      case AnomalySeverity.critical: return AppTheme.destructiveRed;
      case AnomalySeverity.warning: return AppTheme.amberAccent;
      case AnomalySeverity.info: return AppTheme.primaryBlue;
    }
  }

  IconData _getTypeIcon() {
    switch (anomaly.type) {
      case AnomalyType.lowStock: return Icons.inventory_2_rounded;
      case AnomalyType.overdue: return Icons.history_toggle_off_rounded;
      case AnomalyType.expiring: return Icons.event_busy_rounded;
      case AnomalyType.maintenance: return Icons.build_rounded;
      case AnomalyType.dispatch: return Icons.local_shipping_rounded;
      case AnomalyType.audit: return Icons.fact_check_rounded;
    }
  }

  String _getTypeLabel() {
    switch (anomaly.type) {
      case AnomalyType.lowStock: return 'STOCK ANOMALY';
      case AnomalyType.overdue: return 'COMPLIANCE ALERT';
      case AnomalyType.expiring: return 'EXPIRY WARNING';
      case AnomalyType.maintenance: return 'MAINTENANCE DUE';
      case AnomalyType.dispatch: return 'FIELD REQUEST';
      case AnomalyType.audit: return 'FORENSIC AUDIT';
    }
  }
}
