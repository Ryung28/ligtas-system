import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/app_theme.dart';
import '../../scanner/widgets/scanner_view.dart';
import '../../scanner/models/qr_payload.dart';
import '../providers/dispatch_controller.dart';
import '../model/dispatch_session.dart';

class FastDispatchScreen extends ConsumerStatefulWidget {
  const FastDispatchScreen({super.key});

  @override
  ConsumerState<FastDispatchScreen> createState() => _FastDispatchScreenState();
}

class _FastDispatchScreenState extends ConsumerState<FastDispatchScreen> {
  static const Color stitchNavy = Color(0xFF0F172A);
  static const Color stitchSurface = Color(0xFFF8FAFC);
  static const Color stitchBorder = Color(0xFFE2E8F0);

  final TextEditingController _approvedByController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _approvedByController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openScanner({required bool isPerson}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScannerView(
          overlayText: isPerson ? 'SCAN PERSONNEL BADGE' : 'SCAN EQUIPMENT LABEL',
          onQrCodeDetected: (raw) {
            final payload = LigtasQrPayload.tryParse(raw);
            if (payload != null) {
              payload.when(
                equipment: (protocol, version, action, itemId, itemName) {
                  if (!isPerson) {
                    ref.read(fastDispatchControllerProvider.notifier).addItem(itemId, itemName);
                    Navigator.pop(context);
                  }
                },
                person: (id, name, role) {
                  if (isPerson) {
                    ref.read(fastDispatchControllerProvider.notifier).setBorrower(
                      BorrowerInfo(id: id, name: name, contact: '', office: role),
                    );
                    Navigator.pop(context);
                  }
                },
                station: (_, __) => null,
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fastDispatchControllerProvider);

    return Scaffold(
      backgroundColor: stitchSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('FAST DISPATCH', 
          style: GoogleFonts.lexend(color: stitchNavy, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: stitchNavy),
          onPressed: () => context.pop(),
        ),
      ),
      body: state.when(
        data: (dispatch) => Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionHeader('IDENTIFY BORROWER'),
                  _buildBorrowerCard(dispatch.borrower),
                  const Gap(24),
                  _buildSectionHeader('EQUIPMENT CART'),
                  if (dispatch.items.isEmpty)
                    _buildEmptyCart()
                  else
                    ...dispatch.items.map((item) => _buildCartItem(item)),
                  const Gap(16),
                  _buildScanAction(),
                  const Gap(24),
                  _buildSectionHeader('AUDIT DETAILS'),
                  _buildAuditForm(),
                ],
              ),
            ),
            _buildFooter(dispatch),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, 
        style: GoogleFonts.lexend(color: const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
    );
  }

  Widget _buildBorrowerCard(BorrowerInfo? borrower) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stitchBorder),
      ),
      child: borrower == null 
          ? InkWell(
              onTap: () => _openScanner(isPerson: true),
              child: Row(
                children: [
                  const Icon(Icons.person_add_rounded, color: Color(0xFF94A3B8)),
                  const Gap(16),
                  Text('SCAN OR SEARCH BORROWER', 
                    style: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            )
          : Row(
              children: [
                CircleAvatar(backgroundColor: stitchNavy, child: const Icon(Icons.person, color: Colors.white)),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(borrower.name.toUpperCase(), 
                        style: GoogleFonts.plusJakartaSans(color: stitchNavy, fontSize: 14, fontWeight: FontWeight.w800)),
                      Text(borrower.office ?? 'Field Staff', 
                        style: GoogleFonts.lexend(color: const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF94A3B8)),
                  onPressed: () => ref.read(fastDispatchControllerProvider.notifier).setBorrower(null as dynamic), // Placeholder reset
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stitchBorder, style: BorderStyle.none),
      ),
      child: Center(
        child: Text('NO ITEMS SCANNED', 
          style: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildCartItem(DispatchItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: stitchBorder),
      ),
      child: Row(
        children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.inventory_2_rounded, size: 16, color: stitchNavy)),
          const Gap(12),
          Expanded(child: Text(item.itemName.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: stitchNavy))),
          Text('x${item.quantity}', style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w700, color: stitchNavy)),
          const Gap(8),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
            onPressed: () => ref.read(fastDispatchControllerProvider.notifier).removeItem(item.inventoryId),
          ),
        ],
      ),
    );
  }

  Widget _buildScanAction() {
    return InkWell(
      onTap: () => _openScanner(isPerson: false),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: stitchNavy.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: stitchNavy.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner_rounded, color: stitchNavy, size: 20),
            const Gap(12),
            Text('ADD EQUIPMENT', style: GoogleFonts.lexend(color: stitchNavy, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: stitchBorder)),
      child: Column(
        children: [
          TextField(
            controller: _approvedByController,
            decoration: InputDecoration(
              labelText: 'APPROVED BY',
              labelStyle: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8)),
              hintText: 'Enter Supervisor Name',
              border: InputBorder.none,
            ),
          ),
          const Divider(height: 1),
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RELEASED BY', style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8))),
              Text('MANAGER (AUTH)', style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w700, color: stitchNavy)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(DispatchState state) {
    final canSubmit = state.borrower != null && state.items.isNotEmpty && !state.isSubmitting;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]),
      child: ElevatedButton(
        onPressed: canSubmit ? () => ref.read(fastDispatchControllerProvider.notifier).submit(_approvedByController.text) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: stitchNavy,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: state.isSubmitting 
          ? const CircularProgressIndicator(color: Colors.white)
          : Text('CONFIRM DISPATCH (${state.items.length} ITEMS)', 
              style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
      ),
    );
  }
}
