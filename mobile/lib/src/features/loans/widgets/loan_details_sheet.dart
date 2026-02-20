import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../models/loan_model.dart';
import '../../../core/design_system/app_theme.dart';

class LoanDetailsSheet extends StatelessWidget {
  final LoanModel loan;

  const LoanDetailsSheet({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            blurRadius: 40,
            color: Colors.black12,
            offset: Offset(0, -10),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.neutralGray200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(32),
            Row(
              children: [
                Hero(
                  tag: 'loan_icon_${loan.id}',
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: _getSmartIcon(loan.itemName),
                    ),
                  ),
                ),
                const Gap(20),
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
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.neutralGray900,
                              letterSpacing: -1.0,
                            ),
                          ),
                        ),
                      ),
                      const Gap(4),
                      Text(
                        'ASSET-${loan.itemCode}',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'RobotoMono',
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(32),
            
            _buildDetailRow(
              icon: Icons.person_outline_rounded,
              label: 'Borrower',
              value: loan.borrowerName,
            ),
            const Gap(16),
            _buildDetailRow(
              icon: Icons.calendar_today_rounded,
              label: 'Borrow Date',
              value: _formatDate(loan.borrowDate),
            ),
            const Gap(16),
            _buildDetailRow(
              icon: Icons.event_available_rounded,
              label: 'Expected Return',
              value: _formatDate(loan.expectedReturnDate),
            ),
            
            if (loan.purpose.isNotEmpty) ...[
              const Gap(24),
              const Text(
                'PURPOSE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.neutralGray400,
                  letterSpacing: 1.5,
                ),
              ),
              const Gap(8),
              Text(
                loan.purpose,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.neutralGray700,
                  height: 1.5,
                ),
              ),
            ],
            
            const Gap(40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neutralGray900,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Close Details',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.neutralGray100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppTheme.neutralGray600),
        ),
        const Gap(16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppTheme.neutralGray400,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.neutralGray800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _getSmartIcon(String name) {
    IconData iconData = Icons.inventory_2_outlined;
    Color color = Colors.grey[700]!;

    final n = name.toLowerCase();
    if (n.contains('radio') || n.contains('comms')) {
      iconData = Icons.settings_input_antenna_rounded;
      color = Colors.blueGrey[700]!;
    } else if (n.contains('drone') || n.contains('fly')) {
      iconData = Icons.flight_takeoff_rounded;
      color = Colors.indigo[400]!;
    } else if (n.contains('jacket') || n.contains('vest')) {
      iconData = Icons.shield_moon_rounded;
      color = Colors.orange[400]!;
    } else if (n.contains('boat') || n.contains('raft')) {
      iconData = Icons.directions_boat_rounded;
      color = Colors.blue[400]!;
    } else if (n.contains('generator') || n.contains('power')) {
      iconData = Icons.bolt_rounded;
      color = Colors.amber[600]!;
    } else if (n.contains('med') || n.contains('aid')) {
      iconData = Icons.medical_services_rounded;
      color = Colors.red[400]!;
    }

    return Icon(iconData, color: color, size: 28);
  }
}
