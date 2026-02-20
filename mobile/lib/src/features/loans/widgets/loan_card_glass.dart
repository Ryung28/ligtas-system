import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../models/loan_model.dart';
import '../../../core/design_system/app_theme.dart';

class LoanCardGlass extends StatelessWidget {
  final LoanModel loan;
  final VoidCallback onTap;

  const LoanCardGlass({
    super.key,
    required this.loan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = loan.daysOverdue > 0;
    
    // Premium Color Palette
    Color accentColor = const Color(0xFF3B82F6); // Active Blue
    String statusLabel = 'Active';

    if (loan.status == LoanStatus.returned) {
      accentColor = const Color(0xFF10B981); // Emerald
      statusLabel = 'Returned';
    } else if (loan.status == LoanStatus.pending) {
      accentColor = const Color(0xFFF59E0B); // Amber
      statusLabel = 'Pending';
    } else if (isOverdue) {
      accentColor = const Color(0xFFEF4444); // Red
      statusLabel = 'Overdue';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withValues(alpha: 0.98),
          ],
        ),
        boxShadow: [
          if (isOverdue)
            BoxShadow(
              color: AppTheme.errorRed.withValues(alpha: 0.08),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            )
          else ...[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
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
                  // 1. Icon Container (Premium Tint)
                  Hero(
                    tag: 'loan_icon_${loan.id}',
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: accentColor.withValues(alpha: 0.08)),
                      ),
                      child: Center(
                        child: _getSmartIcon(loan.itemName, accentColor),
                      ),
                    ),
                  ),
                  const Gap(16),
                  
                  // 2. Main Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'loan_title_${loan.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              loan.itemName.isNotEmpty ? loan.itemName : 'Pending Resolve',
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
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
  
                  // 3. Status Pill (Sophisticated Shimmer Glass)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accentColor.withValues(alpha: 0.12),
                          accentColor.withValues(alpha: 0.06),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: accentColor.withValues(alpha: 0.15)),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      statusLabel.toUpperCase(),
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
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
    } else if (n.contains('drone') || n.contains('fly')) {
      iconData = Icons.flight_takeoff_rounded;
    } else if (n.contains('jacket') || n.contains('vest')) {
      iconData = Icons.shield_moon_rounded;
    } else if (n.contains('boat') || n.contains('raft')) {
      iconData = Icons.directions_boat_rounded;
    } else if (n.contains('generator') || n.contains('power')) {
      iconData = Icons.bolt_rounded;
    } else if (n.contains('med') || n.contains('aid')) {
      iconData = Icons.medical_services_rounded;
    }

    return Icon(iconData, color: color, size: 28);
  }
}
