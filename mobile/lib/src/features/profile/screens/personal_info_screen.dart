import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/widgets/app_toast.dart';
import '../controllers/profile_controller.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _orgController;
  bool _isEditing = false;
  bool _initialized = false;
  bool _hasAttemptedSave = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _orgController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final user = ref.read(profileControllerProvider).user;
      _nameController.text = user?.fullName ?? '';
      _phoneController.text = user?.phoneNumber ?? '';
      _orgController.text = user?.organization ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _orgController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _hasAttemptedSave = true);
    if (!_formKey.currentState!.validate()) {
      AppToast.showError(context, 'Please check the highlighted fields.');
      return;
    }
    try {
      await ref.read(profileControllerProvider.notifier).updateProfile(
            displayName: _nameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            organization: _orgController.text.trim(),
          );
      if (mounted) {
        setState(() {
          _isEditing = false;
          _hasAttemptedSave = false;
        });
        AppToast.showSuccess(context, 'Profile updated successfully.');
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, ExceptionHandler.getDisplayMessage(e));
      }
    }
  }

  void _handleCancel() {
    final user = ref.read(profileControllerProvider).user;
    _nameController.text = user?.fullName ?? '';
    _phoneController.text = user?.phoneNumber ?? '';
    _orgController.text = user?.organization ?? '';
    setState(() {
      _isEditing = false;
      _hasAttemptedSave = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    final state = ref.watch(profileControllerProvider);
    final user = state.user;
    final isLoading = state.isLoading;

    final initials = (user?.fullName.isNotEmpty == true)
        ? user!.fullName.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: sentinel.containerLowest,
      appBar: _buildAppBar(context, sentinel, isLoading),
      body: SafeArea(
        child: isLoading && !_isEditing
            ? Center(child: CircularProgressIndicator(color: sentinel.navy))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _hasAttemptedSave ? AutovalidateMode.always : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 🛡️ TACTICAL IDENTITY HEADER ──
                      Center(
                        child: Column(
                          children: [
                            _buildAvatar(sentinel, initials),
                            const Gap(20),
                            Text(
                              user?.fullName.toUpperCase() ?? 'IDENTIFYING...',
                              style: GoogleFonts.lexend(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: sentinel.navy,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              user?.email?.toLowerCase() ?? '',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: sentinel.navy.withOpacity(0.5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Gap(16),
                            _buildStatusBadge(sentinel, 'AUTHENTICATED'),
                          ],
                        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05),
                      ),

                      const Gap(40),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: sentinel.navy.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: sentinel.navy.withOpacity(0.10)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline_rounded, size: 16, color: sentinel.navy.withOpacity(0.6)),
                            const Gap(10),
                            Expanded(
                              child: Text(
                                'Tip: Keep your name, phone, and office updated here. Voucher Dispatch uses these fields when you tap "Identify as self".',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  height: 1.35,
                                  fontWeight: FontWeight.w600,
                                  color: sentinel.navy.withOpacity(0.72),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Gap(10),

                      Row(
                        children: [
                          _buildCompletenessChip(
                            sentinel,
                            label: 'Name',
                            done: (_nameController.text.trim().isNotEmpty),
                          ),
                          const Gap(8),
                          _buildCompletenessChip(
                            sentinel,
                            label: 'Phone',
                            done: (_phoneController.text.trim().isNotEmpty),
                          ),
                          const Gap(8),
                          _buildCompletenessChip(
                            sentinel,
                            label: 'Office',
                            done: (_orgController.text.trim().isNotEmpty),
                          ),
                        ],
                      ),

                      const Gap(20),

                      // ── 🛡️ FIELD MATRIX ──
                      _FieldGroupCard(
                        sentinel: sentinel,
                        title: 'YOUR INFORMATION',
                        children: [
                          _TacticalField(
                            sentinel: sentinel,
                            label: 'FULL NAME',
                            controller: _nameController,
                            icon: Icons.person_rounded,
                            enabled: _isEditing,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your full name.' : null,
                          ),
                          _TacticalField(
                            sentinel: sentinel,
                            label: 'PHONE NUMBER',
                            controller: _phoneController,
                            icon: Icons.phone_rounded,
                            enabled: _isEditing,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            validator: (v) {
                              final raw = (v ?? '').trim();
                              if (raw.isEmpty) return 'Please enter your phone number.';

                              // Accept 11-digit PH local mobile (09xxxxxxxxx)
                              final digits = raw.replaceAll(RegExp(r'\D'), '');
                              if (!digits.startsWith('09')) {
                                return 'Use a valid PH mobile format (09XXXXXXXXX).';
                              }
                              if (digits.length < 11) {
                                final missing = 11 - digits.length;
                                return 'Add $missing more digit${missing == 1 ? '' : 's'}.';
                              }
                              if (digits.length > 11) {
                                final extra = digits.length - 11;
                                return 'Remove $extra digit${extra == 1 ? '' : 's'}.';
                              }
                              return null;
                            },
                          ),
                          _TacticalField(
                            sentinel: sentinel,
                            label: 'OFFICE / ORGANIZATION',
                            controller: _orgController,
                            icon: Icons.business_rounded,
                            enabled: _isEditing,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your office or organization.' : null,
                            isLast: true,
                          ),
                        ],
                      ),

                      if (_isEditing) ...[
                        const Gap(32),
                        _buildActionButtons(sentinel, isLoading),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, SentinelColors sentinel, bool isLoading) {
    return AppBar(
      backgroundColor: sentinel.containerLowest,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: sentinel.navy),
        onPressed: () => context.pop(),
      ),
      centerTitle: true,
      title: Text(
        'OPERATIVE PROFILE',
        style: GoogleFonts.lexend(
          fontWeight: FontWeight.w900,
          fontSize: 14,
          letterSpacing: 1.5,
          color: sentinel.navy,
        ),
      ),
      actions: [
        if (!_isEditing)
          IconButton(
            onPressed: () => setState(() => _isEditing = true),
            icon: Icon(Icons.edit_note_rounded, color: sentinel.navy),
          )
        else
          TextButton(
            onPressed: isLoading ? null : _handleSave,
            child: Text(
              'SAVE',
              style: GoogleFonts.lexend(fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.successGreen),
            ),
          ),
        const Gap(12),
      ],
    );
  }

  Widget _buildAvatar(SentinelColors sentinel, String initials) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: sentinel.tactile.card,
      ),
      child: Center(
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: sentinel.navy.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials,
              style: GoogleFonts.lexend(
                color: sentinel.navy,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(SentinelColors sentinel, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: sentinel.navy.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user_rounded, size: 14, color: sentinel.navy.withOpacity(0.4)),
          const Gap(8),
          Text(
            status,
            style: GoogleFonts.lexend(
              color: sentinel.navy.withOpacity(0.5),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(SentinelColors sentinel, bool isLoading) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: isLoading ? null : _handleCancel,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('CANCEL', style: GoogleFonts.lexend(fontWeight: FontWeight.w900, fontSize: 13, color: sentinel.navy.withOpacity(0.4))),
          ),
        ),
        const Gap(16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: sentinel.navy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              shadowColor: sentinel.navy.withOpacity(0.3),
            ),
            child: isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('APPLY CHANGES', style: GoogleFonts.lexend(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildCompletenessChip(
    SentinelColors sentinel, {
    required String label,
    required bool done,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: done ? AppTheme.successGreen.withOpacity(0.08) : sentinel.navy.withOpacity(0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: done ? AppTheme.successGreen.withOpacity(0.35) : sentinel.navy.withOpacity(0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 14,
            color: done ? AppTheme.successGreen : sentinel.navy.withOpacity(0.4),
          ),
          const Gap(6),
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: done ? AppTheme.successGreen : sentinel.navy.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldGroupCard extends StatelessWidget {
  final SentinelColors sentinel;
  final String title;
  final List<Widget> children;

  const _FieldGroupCard({required this.sentinel, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: sentinel.navy.withOpacity(0.3),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: sentinel.tactile.card,
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _TacticalField extends StatelessWidget {
  final SentinelColors sentinel;
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool isLast;

  const _TacticalField({
    required this.sentinel,
    required this.label,
    required this.controller,
    required this.icon,
    required this.enabled,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            children: [
              Icon(icon, size: 20, color: enabled ? sentinel.navy : sentinel.navy.withOpacity(0.2)),
              const Gap(16),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  enabled: enabled,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: sentinel.navy,
                  ),
                  decoration: InputDecoration(
                    labelText: label,
                    labelStyle: GoogleFonts.lexend(
                      fontSize: 9,
                      color: sentinel.navy.withOpacity(0.4),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  validator: validator,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: sentinel.navy.withOpacity(0.05), indent: 56),
      ],
    );
  }
}
