import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/design_system/app_theme.dart';
import '../../auth/domain/models/user_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:gap/gap.dart';

class DigitalIdCard extends StatelessWidget {
  final UserModel? user;

  const DigitalIdCard({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).extension<LigtasColors>()!;
    final isGuest = user?.role.toLowerCase() == 'guest';
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: sentinel.navy,
        borderRadius: BorderRadius.circular(20),
        boxShadow: sentinel.tactile.card,
        border: Border.all(
          color: isGuest ? AppTheme.warningOrange.withOpacity(0.3) : Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // ── Background Scanlines / Texture ──
            Positioned.fill(
              child: Opacity(
                opacity: 0.03,
                child: CustomPaint(
                  painter: ScanlinePainter(),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: LIGTAS Branding and Auth Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LIGTAS',
                            style: GoogleFonts.lexend(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            isGuest ? 'TEMPORARY_ACCESS_UNIT' : 'AUTHORIZED_OPERATIVE_UNIT',
                            style: GoogleFonts.lexend(
                              color: isGuest ? AppTheme.warningOrange : Colors.white.withOpacity(0.4),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isGuest 
                              ? AppTheme.warningOrange.withOpacity(0.1) 
                              : AppTheme.successGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isGuest ? AppTheme.warningOrange : AppTheme.successGreen,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          isGuest ? 'GUEST' : 'VERIFIED',
                          style: GoogleFonts.lexend(
                            color: isGuest ? AppTheme.warningOrange : AppTheme.successGreen,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const Gap(40),
                  
                  // Operative name and Metadata
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'OPERATIVE_NAME',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              user?.fullName.toUpperCase() ?? 'UNIDENTIFIED_SUBJECT',
                              style: GoogleFonts.lexend(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Gap(16),
                            Text(
                              'SECTOR_AUTHENTICATION',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              (user?.organization ?? 'EXTERNAL_UNASSIGNED').toUpperCase(),
                              style: GoogleFonts.lexend(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // QR Section with industrial border
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: QrImageView(
                          data: user?.id ?? 'ligtas-pending',
                          version: QrVersions.auto,
                          size: 70.0,
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color(0xFF000000),
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Gap(24),

                  // Footer: Serial ID
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'SID_REF:',
                          style: GoogleFonts.lexend(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          (user?.id ?? 'PENDING_AUTH').toUpperCase(),
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.height; i += 4) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

