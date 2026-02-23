import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/app_theme.dart';
import '../../dashboard/widgets/dashboard_background.dart';
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
      _nameController.text = user?.displayName ?? '';
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
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref.read(profileControllerProvider.notifier).updateProfile(
            displayName: _nameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            organization: _orgController.text.trim(),
          );
      if (mounted) {
        setState(() => _isEditing = false);
        _showSnackBar('Profile updated successfully ✓', AppTheme.successGreen);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Update failed: ${e.toString()}', AppTheme.errorRed);
      }
    }
  }

  void _handleCancel() {
    final user = ref.read(profileControllerProvider).user;
    _nameController.text = user?.displayName ?? '';
    _phoneController.text = user?.phoneNumber ?? '';
    _orgController.text = user?.organization ?? '';
    setState(() => _isEditing = false);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final user = state.user;
    final isLoading = state.isLoading;

    final initials = (user?.displayName?.isNotEmpty == true)
        ? user!.displayName!.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase()
        : (user?.email?.isNotEmpty == true ? user!.email![0].toUpperCase() : '?');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(isLoading),
      body: Stack(
        children: [
          const DashboardBackground(),
          SafeArea(
            child: isLoading && !_isEditing
                ? const Center(child: CircularProgressIndicator.adaptive())
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                    physics: const BouncingScrollPhysics(),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Avatar Section ──
                          Center(
                            child: Column(
                              children: [
                                _buildAvatar(initials),
                                const Gap(16),
                                Text(
                                  user?.displayName ?? 'Your Name',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.8,
                                    color: AppTheme.neutralGray900,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  user?.email ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.neutralGray600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Gap(12),
                                _buildStatusBadge(user?.status),
                              ],
                            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.08),
                          ),

                          const Gap(36),

                          // ── Profile Details Section ──
                          _FieldGroupCard(
                            title: 'PROFILE DETAILS',
                            children: [
                              _PremiumField(
                                label: 'Full Name',
                                controller: _nameController,
                                icon: Icons.person_rounded,
                                enabled: _isEditing,
                                delay: 100,
                                validator: (v) =>
                                    v == null || v.trim().isEmpty ? 'Name is required' : null,
                              ),
                              _PremiumField(
                                label: 'Phone Number',
                                controller: _phoneController,
                                icon: Icons.phone_rounded,
                                enabled: _isEditing,
                                delay: 160,
                                keyboardType: TextInputType.phone,
                              ),
                              _PremiumField(
                                label: 'Organization / Department',
                                controller: _orgController,
                                icon: Icons.business_rounded,
                                enabled: _isEditing,
                                delay: 220,
                                isLast: true,
                              ),
                            ],
                          ),

                          const Gap(20),

                          // ── System Info Section ──
                          _FieldGroupCard(
                            title: 'SYSTEM INFO',
                            children: [
                              _InfoRow(
                                label: 'Account Status',
                                value: user?.status.toUpperCase() ?? '—',
                                icon: Icons.shield_rounded,
                                color: _statusColor(user?.status),
                                delay: 300,
                              ),
                              _InfoRow(
                                label: 'User Role',
                                value: user?.role.toUpperCase() ?? '—',
                                icon: Icons.manage_accounts_rounded,
                                color: AppTheme.primaryBlue,
                                delay: 360,
                                isLast: true,
                              ),
                            ],
                          ),

                          if (_isEditing) ...[
                            const Gap(28),
                            _buildActionButtons(isLoading),
                          ],
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isLoading) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Personal Information',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
      ),
      actions: [
        if (!_isEditing)
          _buildEditButton()
        else
          _buildSaveButton(isLoading),
        const Gap(8),
      ],
    );
  }

  Widget _buildEditButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: TextButton.icon(
        onPressed: () => setState(() => _isEditing = true),
        icon: const Icon(Icons.edit_rounded, size: 16),
        label: const Text('Edit'),
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.primaryBlue,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isLoading) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: TextButton(
        onPressed: isLoading ? null : _handleSave,
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.successGreen,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Save'),
      ),
    );
  }

  Widget _buildAvatar(String initials) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryBlue, AppTheme.primaryBlueDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 38,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7, height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const Gap(6),
          Text(
            (status ?? 'pending').toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isLoading) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : _handleCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppTheme.neutralGray300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
        const Gap(12),
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: isLoading ? null : _handleSave,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active': return AppTheme.successGreen;
      case 'pending': return AppTheme.warningAmber;
      case 'suspended': return AppTheme.errorRed;
      default: return AppTheme.neutralGray500;
    }
  }
}

// ── Reusable Field Group Card ──────────────────────────────────────────────────
class _FieldGroupCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _FieldGroupCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: AppTheme.neutralGray500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

// ── Editable/Read-Only Field ─────────────────────────────────────────────────
class _PremiumField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool enabled;
  final int delay;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool isLast;

  const _PremiumField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.enabled,
    required this.delay,
    this.keyboardType,
    this.validator,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 20, color: enabled ? AppTheme.primaryBlue : AppTheme.neutralGray400),
              const Gap(16),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  enabled: enabled,
                  keyboardType: keyboardType,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: enabled ? AppTheme.neutralGray900 : AppTheme.neutralGray600,
                  ),
                  decoration: InputDecoration(
                    labelText: label,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      color: AppTheme.neutralGray500,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  validator: validator,
                ),
              ),
              if (enabled)
                Icon(Icons.edit_outlined, size: 16, color: AppTheme.neutralGray400),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: AppTheme.neutralGray200,
            indent: 56,
          ),
      ],
    ).animate().fadeIn(delay: delay.ms, duration: 400.ms);
  }
}

// ── Read-Only Info Row ────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final int delay;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.delay,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.neutralGray500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, color: AppTheme.neutralGray200, indent: 56),
      ],
    ).animate().fadeIn(delay: delay.ms, duration: 400.ms);
  }
}
