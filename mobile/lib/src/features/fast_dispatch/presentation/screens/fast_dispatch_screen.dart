import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../providers/dispatch_controller.dart';
import '../../model/dispatch_session.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class FastDispatchScreen extends ConsumerStatefulWidget {
  const FastDispatchScreen({super.key});

  @override
  ConsumerState<FastDispatchScreen> createState() => _FastDispatchScreenState();
}

class _FastDispatchScreenState extends ConsumerState<FastDispatchScreen> {
  static const Color stitchNavy = Color(0xFF0F172A);
  static const Color stitchSurface = Color(0xFFF8FAFC);
  static const Color stitchBorder = Color(0xFFE2E8F0);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _officeController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _authController = TextEditingController();
  bool _didHydrateFromState = false;

  @override
  void dispose() {
    _nameController.dispose();
    _officeController.dispose();
    _contactController.dispose();
    _authController.dispose();
    super.dispose();
  }

  void _updateControllers(BorrowerInfo? borrower) {
    if (borrower != null) {
      _nameController.text = borrower.name;
      _officeController.text = borrower.office ?? '';
      _contactController.text = borrower.contact;
    }
  }

  void _hydrateFromDispatchState(DispatchState dispatch) {
    if (_didHydrateFromState) return;
    if (dispatch.borrower != null) {
      _updateControllers(dispatch.borrower);
    }
    if ((dispatch.approvedBy ?? '').isNotEmpty) {
      _authController.text = dispatch.approvedBy!;
    }
    _didHydrateFromState = true;
  }

  void _borrowForSelf() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final missing = <String>[];
      if (user.fullName.trim().isEmpty) missing.add('name');
      if ((user.phoneNumber?.trim().isEmpty ?? true)) missing.add('phone');
      if ((user.organization?.trim().isEmpty ?? true)) missing.add('office');

      final borrower = BorrowerInfo(
        id: user.id,
        name: user.fullName,
        contact: user.phoneNumber ?? '',
        office: user.organization,
      );
      ref.read(fastDispatchControllerProvider.notifier).setBorrower(borrower);
      _updateControllers(borrower);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            missing.isEmpty
                ? 'Autofill used your profile details.'
                : 'Autofill partial - missing ${missing.join(', ')} in your profile.',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fastDispatchControllerProvider);
    final user = ref.watch(currentUserProvider);

    // 🕊️ SUCCESS LISTENER: Return to HQ on completion
    ref.listen(fastDispatchControllerProvider, (previous, next) {
      if (previous?.isLoading == true && next.hasValue && next.value?.selectedItem == null && next.value?.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('VOUCHER ISSUED SUCCESSFULLY', style: GoogleFonts.lexend(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white)),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    });

    final missingProfileFields = <String>[
      if ((user?.fullName.trim().isEmpty ?? true)) 'name',
      if ((user?.phoneNumber?.trim().isEmpty ?? true)) 'phone',
      if ((user?.organization?.trim().isEmpty ?? true)) 'office',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('VOUCHER DISPATCH', 
          style: GoogleFonts.lexend(color: stitchNavy, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: stitchNavy, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: state.when(
        data: (dispatch) {
          _hydrateFromDispatchState(dispatch);
          final item = dispatch.selectedItem;
          if (item == null) return const Center(child: Text('No item selected'));

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    const Gap(12),
                    _buildHeroSection(item),
                    const Gap(20),
                    _buildQuantitySelector(item),
                    const Gap(32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionLabel('PERSONNEL DATA'),
                        _buildSelfBadge(),
                      ],
                    ),
                    const Gap(16),
                    if (missingProfileFields.isNotEmpty) _buildProfileIncompleteBanner(missingProfileFields),
                    _buildBorrowerForm(dispatch),
                    const Gap(40),
                    _buildSectionLabel('AUTHORIZATION'),
                    const Gap(16),
                    _buildAuthorizationHub(user?.fullName ?? 'Manager'),
                    const Gap(40),
                  ],
                ),
              ),
              _buildFooter(dispatch),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHeroSection(DispatchItem item) {
    return Column(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: stitchSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: stitchBorder),
          ),
          child: item.imageUrl != null 
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(item.imageUrl!, fit: BoxFit.contain),
              )
            : Icon(Icons.inventory_2_outlined, size: 80, color: stitchNavy.withOpacity(0.1)),
        ).animate().scale(duration: 400.ms),
        const Gap(16),
        Text(item.itemName.toUpperCase(), 
          textAlign: TextAlign.center,
          style: GoogleFonts.lexend(fontSize: 22, fontWeight: FontWeight.w900, color: stitchNavy, letterSpacing: -0.5)),
        Text('SERIAL: LGT-${item.inventoryId.toString().padLeft(4, '0')}', 
          style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _buildSelfBadge() {
    final user = ref.read(currentUserProvider);
    final missing = <String>[];
    if ((user?.fullName.trim().isEmpty ?? true)) missing.add('name');
    if ((user?.phoneNumber?.trim().isEmpty ?? true)) missing.add('phone');
    if ((user?.organization?.trim().isEmpty ?? true)) missing.add('office');
    final tooltip = missing.isEmpty
        ? 'Autofill uses your Profile name, phone, and office.'
        : 'Profile is missing: ${missing.join(', ')}. Update Profile > Personal Info for accurate autofill.';

    final badge = Tooltip(
      message: tooltip,
      triggerMode: TooltipTriggerMode.tap,
      child: GestureDetector(
        onTap: _borrowForSelf,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: stitchNavy,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [BoxShadow(color: stitchNavy.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_pin_rounded, color: Colors.white, size: 12),
              const Gap(6),
              Text('IDENTIFY AS SELF',
                  style: GoogleFonts.lexend(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );

    if (missing.isEmpty) return badge;
    return badge
        .animate(onPlay: (controller) => controller.repeat(reverse: true, count: 2))
        .scale(begin: const Offset(1, 1), end: const Offset(1.03, 1.03), duration: 520.ms);
  }

  Widget _buildSectionLabel(String text) {
    return Text(text, 
      style: GoogleFonts.lexend(color: const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5));
  }

  Widget _buildQuantitySelector(DispatchItem item) {
    final notifier = ref.read(fastDispatchControllerProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: stitchSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stitchBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QUANTITY TO BORROW',
                  style: GoogleFonts.lexend(
                    color: const Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const Gap(4),
                Text(
                  '${item.quantity} unit${item.quantity > 1 ? 's' : ''}',
                  style: GoogleFonts.lexend(
                    color: stitchNavy,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: item.quantity > 1 ? () => notifier.updateItemQuantity(item.quantity - 1) : null,
            icon: const Icon(Icons.remove_circle_outline_rounded),
            color: stitchNavy,
          ),
          IconButton(
            onPressed: () => notifier.updateItemQuantity(item.quantity + 1),
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: stitchNavy,
          ),
        ],
      ),
    );
  }

  Widget _buildBorrowerForm(DispatchState dispatch) {
    return Column(
      children: [
        _buildVoucherField(
          'BORROWER NAME',
          _nameController,
          onChanged: (value) => ref.read(fastDispatchControllerProvider.notifier).updateBorrowerDraft(name: value),
        ),
        const Gap(16),
        _buildVoucherField(
          'UNIT / OFFICE',
          _officeController,
          onChanged: (value) => ref.read(fastDispatchControllerProvider.notifier).updateBorrowerDraft(office: value),
        ),
        const Gap(16),
        _buildVoucherField(
          'CONTACT NO.',
          _contactController,
          onChanged: (value) => ref.read(fastDispatchControllerProvider.notifier).updateBorrowerDraft(contact: value),
        ),
        if ((dispatch.error ?? '').isNotEmpty) ...[
          const Gap(10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              dispatch.error!,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.red.shade700,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProfileIncompleteBanner(List<String> missing) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFB45309)),
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profile incomplete',
                    style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF92400E))),
                const Gap(4),
                Text('Missing: ${missing.join(', ')}',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF92400E))),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/profile/personal-info'),
            child: Text('Complete now',
                style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w900, color: stitchNavy)),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherField(
    String label,
    TextEditingController controller, {
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.lexend(fontSize: 8, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8))),
        const Gap(4),
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: stitchNavy),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: stitchBorder, width: 2)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: stitchNavy, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorizationHub(String managerName) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: stitchSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: stitchBorder, width: 2),
      ),
      child: Column(
        children: [
          Text('AUTHORIZED BY', style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B))),
          const Gap(8),
          TextField(
            controller: _authController,
            textAlign: TextAlign.center,
            onChanged: (v) => ref.read(fastDispatchControllerProvider.notifier).updateApprovedBy(v),
            style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.w900, color: stitchNavy),
            decoration: InputDecoration(
              hintText: 'COMMANDER NAME',
              hintStyle: GoogleFonts.lexend(color: const Color(0xFFCBD5E1), fontSize: 18, fontWeight: FontWeight.w800),
              border: InputBorder.none,
            ),
          ),
          const Divider(thickness: 2, color: stitchBorder),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user_rounded, size: 14, color: Color(0xFF10B981)),
              const Gap(8),
              Text('ISSUED BY: ', style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8))),
              Text(managerName.toUpperCase(), style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w900, color: stitchNavy)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(DispatchState state) {
    final borrower = state.borrower;
    final hasRequiredBorrowerData = borrower != null &&
        borrower.name.trim().isNotEmpty &&
        borrower.contact.trim().isNotEmpty &&
        (borrower.office?.trim().isNotEmpty ?? false);
    final canSubmit = state.selectedItem != null && !state.isSubmitting;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton(
        onPressed: canSubmit
            ? () {
                if (!hasRequiredBorrowerData) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Complete borrower name, contact, and office to continue.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                ref.read(fastDispatchControllerProvider.notifier).submit();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: stitchNavy,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: state.isSubmitting 
          ? const CircularProgressIndicator(color: Colors.white)
          : Text('CONFIRM & ISSUE VOUCHER', 
              style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
      ),
    ).animate().slideY(begin: 0.2, duration: 400.ms);
  }
}
