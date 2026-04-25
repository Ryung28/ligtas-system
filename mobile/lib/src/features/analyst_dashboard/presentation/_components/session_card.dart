import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/features/analyst_dashboard/domain/entities/activity_event.dart';
import 'package:mobile/src/features/analyst_dashboard/presentation/_components/audit_vault_components.dart';
import 'package:mobile/src/features/analyst_dashboard/presentation/_components/session_status_chip.dart';
import 'package:mobile/src/features/analyst_dashboard/presentation/widgets/models/activity_session.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SessionCard
// • Single-item session  → tap opens CommandDetailSheet
// • Multi-item session   → tap expands inline AuditLedgerRows
// Design: identity-first avatar · minimal chrome · status chip
// ─────────────────────────────────────────────────────────────────────────────
class SessionCard extends ConsumerStatefulWidget {
  final ActivitySession session;

  const SessionCard({super.key, required this.session});

  @override
  ConsumerState<SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends ConsumerState<SessionCard> {
  bool _expanded = false;
  String? get _sessionOrigin {
    for (final event in widget.session.events) {
      final origin = event.createdOrigin ?? event.lastUpdatedOrigin;
      if (origin != null && origin.isNotEmpty) return origin;
    }
    return null;
  }

  Widget? _buildOriginIcon() {
    final origin = _sessionOrigin;
    if (origin == null) return null;
    if (origin == 'Web') {
      return const Icon(Icons.monitor_rounded, size: 13, color: Color(0xFF60A5FA));
    }
    if (origin == 'Mobile') {
      return const Icon(Icons.smartphone_rounded, size: 13, color: Color(0xFFF59E0B));
    }
    return null;
  }

  Color get _accentColor {
    switch (widget.session.type) {
      case EventType.assetOut:
        return const Color(0xFF2563EB); // Web blue-600
      case EventType.assetIn:
        return const Color(0xFF059669); // Web emerald-600
      case EventType.requisitionApproved:
        return const Color(0xFF059669);
      case EventType.maintenance:
      case EventType.reserved:
        return const Color(0xFFF59E0B);
      case EventType.requisitionDenied:
      case EventType.requisitionRejected:
      case EventType.securityTrigger:
        return const Color(0xFFE11D48); // Web rose-600
      case EventType.mixed:
        return const Color(0xFF64748B); // Slate-500
      default:
        return AppTheme.neutralGray500;
    }
  }

  bool get _isMultiItem => widget.session.events.length > 1;

  void _handleTap() {
    HapticFeedback.lightImpact();
    if (_isMultiItem) {
      setState(() => _expanded = !_expanded);
    } else {
      _showDetail(widget.session.events.first);
    }
  }

  void _showDetail(ActivityEvent event) {
    CommandDetailSheet.show(context, ref, event);
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final color = _accentColor;
    final isCompact = MediaQuery.of(context).size.width < 390;

    return Column(
      children: [
                // ── Summary row ──
                InkWell(
                  onTap: _handleTap,
                  splashColor: color.withOpacity(0.06),
                  highlightColor: color.withOpacity(0.04),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Identity-first avatar with session count badge
                        _ActorAvatarBadge(
                          initials: session.actorInitials,
                          color: AppTheme.neutralGray800, // FIXED CHARCOAL IDENTITY
                          badgeColor: color, // STATUS-BASED BADGE
                          itemCount: session.events.length,
                        ),
                        const Gap(12),

                        // Title + actor + status chip
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.sessionTitle,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Gap(3),
                              Row(
                                children: [
                                  _InlineMetaIcon(
                                    icon: Icons.person_outline_rounded,
                                    size: isCompact ? 12 : 13,
                                  ),
                                  const Gap(4),
                                  Expanded(
                                    child: Text(
                                      session.sessionSubtitle,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF334155),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (_buildOriginIcon() != null) ...[
                                    const Gap(8),
                                    _buildOriginIcon()!,
                                  ],
                                  if (!isCompact) ...[
                                    const Gap(10),
                                    const _InlineMetaIcon(
                                      icon: Icons.inventory_2_outlined,
                                    ),
                                    const Gap(4),
                                    Text(
                                      session.events.length > 1 ? 'Items' : 'Equipment',
                                      style: GoogleFonts.lexend(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF64748B),
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const Gap(5),
                              SessionStatusChip(type: session.type),
                            ],
                          ),
                        ),
                        Gap(isCompact ? 6 : 10),

                        // Time + chevron
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              session.timeDisplay,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: isCompact ? 10 : 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            if (_isMultiItem) ...[
                              const Gap(6),
                              AnimatedRotation(
                                turns: _expanded ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: AppTheme.neutralGray400,
                                ),
                              ),
                            ] else ...[
                              const Gap(6),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: AppTheme.neutralGray300,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Expanded item list ──
                if (_isMultiItem)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    child: _expanded
                        ? _ExpandedItems(
                            session: session,
                            onCollapse: () {
                              HapticFeedback.selectionClick();
                              setState(() => _expanded = false);
                            },
                          )
                        : const SizedBox.shrink(),
                  ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ExpandedItems — inline list shown when a multi-item session is expanded
// ─────────────────────────────────────────────────────────────────────────────
class _ExpandedItems extends StatelessWidget {
  final ActivitySession session;
  final VoidCallback onCollapse;

  const _ExpandedItems({
    required this.session,
    required this.onCollapse,
  });

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          height: 1,
          color: const Color(0xFFF1F5F9),
        ),
        ...session.events.asMap().entries.map((entry) {
          final isLast = entry.key == session.events.length - 1;
          return Column(
            children: [
              AuditLedgerRow(event: entry.value, sentinel: sentinel),
              if (!isLast)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 28),
                  height: 1,
                  color: const Color(0xFFF8FAFC),
                ),
            ],
          );
        }),
        // Collapse footer
        InkWell(
          onTap: onCollapse,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.keyboard_arrow_up_rounded,
                  size: 15,
                  color: AppTheme.neutralGray400,
                ),
                const Gap(4),
                Text(
                  'COLLAPSE',
                  style: GoogleFonts.lexend(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.neutralGray400,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InlineMetaIcon extends StatelessWidget {
  final IconData icon;
  final double size;

  const _InlineMetaIcon({
    required this.icon,
    this.size = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: const Color(0xFF64748B),
    );
  }
}

class _ActorAvatarBadge extends StatelessWidget {
  final String initials;
  final Color color;
  final Color badgeColor;
  final int itemCount;

  const _ActorAvatarBadge({
    required this.initials,
    required this.color,
    required this.badgeColor,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    final isMulti = itemCount > 1;
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.30), width: 1),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: GoogleFonts.lexend(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.1,
              ),
            ),
          ),
          if (isMulti)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: badgeColor, // USE THE SEMANTIC STATUS COLOR HERE
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.4),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$itemCount',
                  style: GoogleFonts.lexend(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
