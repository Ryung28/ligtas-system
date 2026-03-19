import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../domain/entities/loan_item.dart';
import '../../../../core/design_system/app_theme.dart';

class LoanCardGlass extends StatelessWidget {
  final LoanItem loan;
  final VoidCallback onTap;
  final VoidCallback? onReturn;

  const LoanCardGlass({
    super.key,
    required this.loan,
    required this.onTap,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    // Determine Status colors and labels matching V1 exactly
    Color accentColor = const Color(0xFF3B82F6); // Active Blue
    String statusLabel = 'Active';

    if (loan.status == LoanStatus.returned) {
      accentColor = const Color(0xFF10B981); // Emerald
      statusLabel = 'Returned';
    } else if (loan.status == LoanStatus.pending) {
      accentColor = const Color(0xFFF59E0B); // Amber
      statusLabel = 'Pending';
    } else if (loan.status == LoanStatus.overdue) {
      accentColor = const Color(0xFFEF4444); // Red
      statusLabel = 'Overdue';
    } else if (loan.status == LoanStatus.cancelled) {
      accentColor = const Color(0xFF64748B); // Slate
      statusLabel = 'Cancelled';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // 1. Icon Container with Hero parity
                  Hero(
                    tag: 'loan_icon_${loan.id}',
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: accentColor.withOpacity(0.08)),
                      ),
                      child: Center(
                        child: _getSmartIcon(loan.itemName, accentColor),
                      ),
                    ),
                  ),
                  const Gap(16),
                  
                  // 2. Main Content with Hero parity
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'loan_title_${loan.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              loan.itemName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.6,
                              ),
                            ),
                          ),
                        ),
                        const Gap(2),
                        Text(
                          '${loan.status == LoanStatus.pending ? 'Requested' : 'Due ${_calculateDueDays(loan.expectedReturnDate)}'}  •  ${loan.quantityBorrowed} Items',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
  
                  // 3. Status or Action Area
                  const Gap(12),
                  if (onReturn != null && (loan.status == LoanStatus.active || loan.status == LoanStatus.overdue))
                    _buildGlassReturnButton(accentColor)
                  else
                    // 4. Status Pill (Fallback)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: accentColor.withOpacity(0.15)),
                      ),
                      child: Text(
                        statusLabel.toUpperCase(),
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassReturnButton(Color accentColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onReturn,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentColor.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.assignment_return_rounded, size: 14, color: accentColor),
              const Gap(6),
              Text(
                'RETURN',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateDueDays(DateTime dueDate) {
    final diff = dueDate.difference(DateTime.now()).inDays;
    if (diff < 0) return '${diff.abs()} days ago';
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return '$diff days';
  }

  Widget _getSmartIcon(String name, [Color? activeColor]) {
    IconData iconData = Icons.inventory_2_outlined;
    Color color = activeColor ?? Colors.grey[700]!;

    final n = name.toLowerCase();
    if (n.contains('radio') || n.contains('comms')) {
      iconData = Icons.settings_input_antenna_rounded;
    } else if (n.contains('bolt') || n.contains('power') || n.contains('gen')) {
      iconData = Icons.bolt_rounded;
    } else if (n.contains('drone') || n.contains('fly')) {
      iconData = Icons.flight_takeoff_rounded;
    } else if (n.contains('med') || n.contains('aid')) {
      iconData = Icons.medical_services_rounded;
    }

    return Icon(iconData, color: color, size: 28);
  }
}
