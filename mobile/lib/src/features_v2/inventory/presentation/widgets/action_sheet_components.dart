import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_action_sheet_v2/manager_action_mode.dart';
import 'tactical_image_picker.dart';
import '../../../../core/design_system/widgets/tactical_image_viewer.dart';

class ActionSheetHeader extends StatelessWidget {
  final int itemId;
  final String imageUrl;
  final String itemName;
  final String category;
  final IconData? categoryIcon;
  final String? itemCode;
  final SentinelColors sentinel;
  final bool isEditMode;
  final ValueChanged<String?> onImageUpdated;

  const ActionSheetHeader({
    super.key,
    required this.itemId,
    required this.imageUrl,
    required this.itemName,
    required this.category,
    this.categoryIcon,
    this.itemCode,
    required this.sentinel,
    required this.isEditMode,
    required this.onImageUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment
              .center, // 🛡️ ALIGNMENT FIX: Center to eliminate gaps
      children: [
        // ── 🛡️ TACTICAL THUMBNAIL + ACTION ──
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                if (imageUrl.isNotEmpty) {
                  TacticalImageViewer.show(
                    context,
                    url: imageUrl,
                    title: itemName,
                  );
                } else {
                  // 🛡️ QUICK CAPTURE: Open camera if no image exists
                  HapticFeedback.mediumImpact();
                  final newUrl = await TacticalImagePicker.captureAndUpload(
                    context,
                    itemId: itemId,
                  );
                  if (newUrl != null) onImageUpdated(newUrl);
                }
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.onyxBlack.withOpacity(0.05),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child:
                      imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => Shimmer.fromColors(
                                  baseColor: const Color(0xFFE2E8F0),
                                  highlightColor: Colors.white,
                                  child: Container(color: Colors.white),
                                ),
                          )
                          : Icon(
                            Icons.inventory_2_outlined,
                            color: AppTheme.carbonGray.withOpacity(0.2),
                          ),
                ),
              ),
            ),
            if (isEditMode) ...[
              const Gap(6), // 🛡️ Tighter vertical gap
              GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final newUrl = await TacticalImagePicker.captureAndUpload(
                    context,
                    itemId: itemId,
                  );
                  if (newUrl != null) onImageUpdated(newUrl);
                },
                child: Text(
                  'CHANGE PHOTO',
                  style: GoogleFonts.lexend(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF334155), // Tactical Slate Charcoal
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
        const Gap(16),

        // ── HEADER INFO ──
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Eyebrow label — Lexend, uppercase, tracking (analyst terminal pattern)
              Row(
                children: [
                  Icon(
                    categoryIcon ?? Icons.inventory_2_outlined,
                    color: AppTheme.neutralGray600,
                    size: 10,
                  ),
                  const Gap(5),
                  Text(
                    category.toUpperCase(),
                    style: GoogleFonts.lexend(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.neutralGray600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const Gap(5),
              // Item name — PlusJakartaSans headline value (analyst terminal KpiCard pattern)
              Text(
                itemName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.neutralGray900,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (itemCode != null && itemCode!.isNotEmpty) ...[
                const Gap(4),
                // Code/SKU — Lexend badge style
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.neutralGray900.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    itemCode!.toUpperCase(),
                    style: GoogleFonts.lexend(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.neutralGray600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class ActionSheetToggleBar extends StatelessWidget {
  final ManagerMode currentMode;
  final ValueChanged<ManagerMode> onModeSelected;
  final SentinelColors sentinel;

  const ActionSheetToggleBar({
    super.key,
    required this.currentMode,
    required this.onModeSelected,
    required this.sentinel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 2,
      ), // 🛡️ SHADOW FIX: Giving the raised shadow room to breathe
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: sentinel.containerLow,
        borderRadius: BorderRadius.circular(16),
        boxShadow:
            sentinel.tactile.recessed, // 🛡️ RECESSED TRAY (Skeuomorphic Depth)
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'IDENTITY',
              isActive: currentMode == ManagerMode.edit,
              onTap: () => onModeSelected(ManagerMode.edit),
              activeColor: const Color(0xFF1E293B),
              sentinel: sentinel,
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: 'RESTOCK',
              isActive: currentMode == ManagerMode.restock,
              onTap: () => onModeSelected(ManagerMode.restock),
              activeColor: AppTheme.emeraldGreen,
              sentinel: sentinel,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;
  final SentinelColors sentinel;

  const _ToggleButton({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.activeColor,
    required this.sentinel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          // 🛡️ RAISED SWITCH: Button pops out when active
          boxShadow: isActive ? sentinel.tactile.raised : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.lexend(
            fontSize: 9,
            fontWeight:
                FontWeight.w900, // 🛡️ ELITE WEIGHT: Bold for all states
            color:
                isActive
                    ? activeColor
                    : AppTheme
                        .onyxBlack, // 🛡️ INK FIX: Solid Black for field-readability
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final int max;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    return Container(
      decoration: BoxDecoration(
        color: sentinel.containerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove_rounded, size: 18),
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          Text(
            quantity.toString().padLeft(2, '0'),
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppTheme.onyxBlack,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 18),
            onPressed: quantity < max ? () => onChanged(quantity + 1) : null,
          ),
        ],
      ),
    );
  }
}

class SmallTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const SmallTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppTheme.carbonGray,
          ),
        ),
        const Gap(6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.onyxBlack,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
              color: AppTheme.carbonGray.withOpacity(0.4),
              fontSize: 12,
            ),
            filled: true,
            fillColor: sentinel.containerLow,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
