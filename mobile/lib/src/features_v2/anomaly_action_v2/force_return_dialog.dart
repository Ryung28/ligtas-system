import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/core/design_system/widgets/top_notice.dart';
import 'package:mobile/src/features/analyst_dashboard/domain/entities/resource_anomaly.dart';
import 'package:mobile/src/features/analyst_dashboard/presentation/controllers/analyst_dashboard_controller.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';
import 'anomaly_shared_widgets.dart';

class ForceReturnDialog extends ConsumerStatefulWidget {
  final ResourceAnomaly anomaly;
  final String analystName;

  const ForceReturnDialog({super.key, required this.anomaly, required this.analystName});

  static void show(BuildContext context, ResourceAnomaly anomaly, String analystName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ForceReturnDialog(anomaly: anomaly, analystName: analystName),
    );
  }

  @override
  ConsumerState<ForceReturnDialog> createState() => _ForceReturnDialogState();
}

class _ForceReturnDialogState extends ConsumerState<ForceReturnDialog> {
  final _receivingOfficerController = TextEditingController();
  final _returnNotesController = TextEditingController();
  String _returnCondition = 'good';
  bool _isProcessing = false;

  @override
  void dispose() {
    _receivingOfficerController.dispose();
    _returnNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const charcoal = Color(0xFF0A0E14);
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(12),
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(2)))),
          const Gap(20),
          Flexible(
            child: CustomScrollView(
              shrinkWrap: true, physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(context).viewInsets.bottom + 32),
                  sliver: SliverList(delegate: SliverChildListDelegate([
                    Row(
                      children: [
                        const Icon(Icons.assignment_return_rounded, color: charcoal, size: 22),
                        const Gap(12),
                        Text('Process Return', style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.w900, color: charcoal, letterSpacing: -0.5)),
                      ],
                    ),
                    const Gap(6),
                    Text(widget.anomaly.category.name.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
                    const Gap(20),
                    
                    _buildLabel('Receiving Officer *'),
                    const Gap(10),
                    _buildTextField(_receivingOfficerController, 'Enter name...', suffix: TextButton(onPressed: () => setState(() => _receivingOfficerController.text = widget.analystName), child: Text('Use my name', style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w800, color: charcoal)))),
                    const Gap(28),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Condition State *'),
                              const Gap(10),
                              Container(
                                decoration: AnomalySharedUI.premiumShadow(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withOpacity(0.04))),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _returnCondition, isExpanded: true, icon: const Icon(Icons.expand_more_rounded, size: 18, color: charcoal),
                                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: charcoal), borderRadius: BorderRadius.circular(16),
                                      items: [
                                        _conditionItem('good', 'Good Condition', AppTheme.emeraldGreen),
                                        _conditionItem('maintenance', 'Needs Maintenance', AppTheme.warningOrange),
                                        _conditionItem('damaged', 'Damaged', AppTheme.errorRed),
                                        _conditionItem('lost', 'Lost Asset', Colors.grey),
                                      ],
                                      onChanged: (v) => setState(() => _returnCondition = v!),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Audit Notes'),
                              const Gap(10),
                              _buildTextField(_returnNotesController, 'Optional notes...'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const Gap(32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: charcoal.withOpacity(0.03), borderRadius: BorderRadius.circular(20), border: Border.all(color: charcoal.withOpacity(0.05))),
                      child: Row(
                        children: [
                          Icon(Icons.verified_user_rounded, size: 18, color: charcoal.withOpacity(0.4)),
                          const Gap(14),
                          Expanded(child: Text('ResQTrack-Audit: Timestamps and personnel ID will be recorded upon recovery.', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: charcoal.withOpacity(0.5), height: 1.4))),
                        ],
                      ),
                    ),
                    const Gap(32),

                    Row(
                      children: [
                        Expanded(child: TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)), child: Text('Cancel', style: GoogleFonts.lexend(fontWeight: FontWeight.w700, color: charcoal.withOpacity(0.3))))),
                        const Gap(12),
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: charcoal.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))]),
                            child: ElevatedButton.icon(
                              onPressed: _isProcessing ? null : _handleForceReturn,
                              icon: const Icon(Icons.check_circle_rounded, size: 20),
                              label: Text('Confirm Recovery', style: GoogleFonts.lexend(fontWeight: FontWeight.w900, fontSize: 14)),
                              style: ElevatedButton.styleFrom(backgroundColor: charcoal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ])),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text.toUpperCase(), style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.0));

  Widget _buildTextField(TextEditingController c, String hint, {Widget? suffix}) {
    return Container(
      decoration: AnomalySharedUI.premiumShadow(),
      child: TextField(
        controller: c, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF001A33)),
        decoration: InputDecoration(
          hintText: hint, hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B).withOpacity(0.4)),
          suffixIcon: suffix, filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF001A33), width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  DropdownMenuItem<String> _conditionItem(String value, String label, Color color) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2))])),
          const Gap(10),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  Future<void> _handleForceReturn() async {
    if (_receivingOfficerController.text.isEmpty) { HapticFeedback.heavyImpact(); return; }
    final borrowId = widget.anomaly.borrowId; final inventoryId = widget.anomaly.inventoryId;
    if (borrowId == null || inventoryId == null) return;
    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();
    final user = ref.read(currentUserProvider);
    final receivedByName = _receivingOfficerController.text.isNotEmpty ? _receivingOfficerController.text : widget.analystName;
    
    final result = await ref.read(analystDashboardControllerProvider.notifier).forceReturn(
      borrowId: borrowId, inventoryId: inventoryId, quantity: widget.anomaly.borrowedQty > 0 ? widget.anomaly.borrowedQty : 1,
      receivedByName: receivedByName, receivedByUserId: user?.id ?? '', returnCondition: _returnCondition,
      returnNotes: _returnNotesController.text.trim().isEmpty ? null : _returnNotesController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);
    if (result.success) {
      Navigator.pop(context);
      Navigator.pop(context);
      TopNotice.show(
        context,
        message: 'Return processed successfully.',
        type: TopNoticeType.success,
      );
    } else {
      TopNotice.show(
        context,
        message: result.error ?? 'Force return failed.',
        type: TopNoticeType.error,
      );
    }
  }
}