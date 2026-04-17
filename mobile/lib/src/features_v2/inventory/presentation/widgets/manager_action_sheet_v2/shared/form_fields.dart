import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';

/// Reusable labeled text field used across all action sheet forms.
class SheetTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Color? labelColor;
  final ValueChanged<String>? onChanged;

  const SheetTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.labelColor,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    final color = labelColor ?? AppTheme.carbonGray;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w900, color: color),
        ),
        const Gap(8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.onyxBlack,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
              color: sentinel.onSurfaceVariant.withOpacity(0.4),
              fontSize: 13,
            ),
            filled: true,
            fillColor: sentinel.containerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}

/// Labeled numeric field with an optional status dot and accent colour.
class SheetNumberField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final Color? statusColor;
  final ValueChanged<String>? onChanged;

  const SheetNumberField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.statusColor,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (statusColor != null) ...[
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
              ),
              const Gap(6),
            ],
            Text(
              label,
              style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppTheme.carbonGray.withOpacity(0.8),
              ),
            ),
          ],
        ),
        const Gap(8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: statusColor ?? AppTheme.onyxBlack,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
              color: sentinel.onSurfaceVariant.withOpacity(0.4),
              fontSize: 13,
            ),
            filled: true,
            fillColor: statusColor != null
                ? statusColor!.withOpacity(0.04)
                : sentinel.containerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: statusColor != null
                  ? BorderSide(color: statusColor!.withOpacity(0.2), width: 1.5)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: statusColor != null
                  ? BorderSide(color: statusColor!.withOpacity(0.2), width: 1.5)
                  : BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}

/// A tappable date row that opens a date picker and fires [onSelected].
class SheetDatePicker extends StatelessWidget {
  final String label;
  final String emptyLabel;
  final DateTime? value;
  final ValueChanged<DateTime> onSelected;

  const SheetDatePicker({
    super.key,
    required this.label,
    required this.emptyLabel,
    this.value,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    final display = value == null
        ? emptyLabel
        : '${value!.day}/${value!.month}/${value!.year}';

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
        const Gap(8),
        GestureDetector(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (d != null) onSelected(d);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: sentinel.containerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month_rounded, size: 16, color: sentinel.primary),
                const Gap(12),
                Text(
                  display,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onyxBlack,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.black26),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
