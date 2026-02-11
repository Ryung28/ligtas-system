import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/app_theme.dart';

/// Horizontal scroll feature cards (reference: Education hub cards)
class DashboardFeatureCards extends StatelessWidget {
  const DashboardFeatureCards({super.key, required this.onOpenScanner});

  final VoidCallback onOpenScanner;

  static const _cards = [
    _FeatureCardData(
      title: 'My Items',
      subtitle: 'Track borrowings',
      description: 'View your borrowed items',
      icon: Icons.list_alt_rounded,
      color: Color(0xFF1976D2),
      route: '/loans',
    ),
    _FeatureCardData(
      title: 'Borrow Item',
      subtitle: 'Request equipment',
      description: 'Submit borrow request',
      icon: Icons.add_circle_outline_rounded,
      color: Color(0xFF2E7D32),
      route: '/loans/create',
    ),
    _FeatureCardData(
      title: 'Scan QR',
      subtitle: 'Quick borrow',
      description: 'Scan QR to borrow',
      icon: Icons.qr_code_scanner_rounded,
      color: Color(0xFF7B1FA2),
      isScanner: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.grid_view_rounded,
                color: AppTheme.primaryBlue,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Quick Access',
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.neutralGray900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 172,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _cards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final card = _cards[index];
              return _FeatureCard(
                data: card,
                onTap:
                    card.isScanner
                        ? onOpenScanner
                        : () => context.go(card.route!),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FeatureCardData {
  const _FeatureCardData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    this.route,
    this.isScanner = false,
  });

  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final String? route;
  final bool isScanner;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.data, required this.onTap});

  final _FeatureCardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = data.color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 152,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [color, color.withValues(alpha: 0.8)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(data.icon, size: 18, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data.title,
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.neutralGray900,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.subtitle,
                      style: GoogleFonts.roboto(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.neutralGray600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data.description,
                      style: GoogleFonts.roboto(
                        fontSize: 9,
                        color: AppTheme.neutralGray500,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: color,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
