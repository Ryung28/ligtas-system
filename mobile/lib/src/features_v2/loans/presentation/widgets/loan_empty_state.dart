import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';

class LoanEmptyState extends StatelessWidget {
  final String statusType;

  const LoanEmptyState({super.key, required this.statusType});

  @override
  Widget build(BuildContext context) {
    String title = 'No pending requests';
    String description = 'Items you request for allocation will appear here for tracking and approval.';
    IconData icon = Icons.inventory_2_rounded;

    if (statusType == 'overdue') {
      title = 'Clear of overdue units';
      description = 'All mission equipment has been successfully tracked and returned on schedule.';
      icon = Icons.verified_rounded;
    } else if (statusType == 'history') {
      title = 'Archived records empty';
      description = 'Complete borrow and return sequences to populate your mission history.';
      icon = Icons.history_rounded;
    } else if (statusType == 'active') {
      title = 'No active deployments';
      description = 'Deployment records will synchronize here once your requests are authorized.';
      icon = Icons.layers_rounded;
    }

    final sentinel = Theme.of(context).sentinel;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Bespoke 3D Frosted Illustration Simulation ──
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Abstract Pulse Background
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [sentinel.containerLow.withOpacity(0.5), Colors.white],
                    ),
                  ),
                ),

                // Frosted Clipboard Base
                Container(
                  width: 128,
                  height: 160,
                  decoration: sentinel.glass.copyWith(
                    boxShadow: sentinel.tactile.raised,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Container(
                              width: 48,
                              height: 4,
                              decoration: BoxDecoration(
                                color: sentinel.navy.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const Gap(12),
                            _buildLine(context, 0.75),
                            const Gap(12),
                            _buildLine(context, 1.0),
                            const Gap(12),
                            _buildLine(context, 0.66),
                            const Spacer(),
                            Opacity(
                              opacity: 0.1,
                              child: Icon(
                                Icons.inventory_2_rounded,
                                size: 44,
                                color: sentinel.navy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Refraction Highlights (Top Right)
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryBlue.withOpacity(0.05),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Gap(24),
          
          // ── Text Content ──
          Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: sentinel.navy,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              description,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: sentinel.onSurfaceVariant.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLine(BuildContext context, double widthFactor) {
    final sentinel = Theme.of(context).sentinel;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: constraints.maxWidth * widthFactor,
            height: 8,
            decoration: BoxDecoration(
              color: sentinel.navy.withOpacity(0.05),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }
}
