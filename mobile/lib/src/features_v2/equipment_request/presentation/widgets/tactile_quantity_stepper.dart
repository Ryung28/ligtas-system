import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'tactile_buttons.dart';

/// 🛡️ TACTILE QUANTITY STEPPER: [ - ] 02 [ + ]
/// Enhanced with Hybrid Manual Input and improved focus handling.
class TactileQuantityStepper extends StatefulWidget {
  final int value;
  final String label;
  final Function(int) onChanged;
  final int min;
  final int max;

  const TactileQuantityStepper({
    super.key,
    required this.value,
    this.label = 'units',
    required this.onChanged,
    this.min = 1,
    this.max = 999,
  });

  @override
  State<TactileQuantityStepper> createState() => _TactileQuantityStepperState();
}

class _TactileQuantityStepperState extends State<TactileQuantityStepper> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode();
    
    // 🛡️ RE-VALIDATE ON FOCUS LOSS
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _finalizeValue();
      }
    });
  }

  @override
  void didUpdateWidget(TactileQuantityStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update controller if we aren't currently editing
    if (widget.value.toString() != _controller.text && !_focusNode.hasFocus) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateValue(int newValue) {
    final sanitized = newValue.clamp(widget.min, widget.max);
    widget.onChanged(sanitized);
    _controller.text = sanitized.toString();
  }

  void _finalizeValue() {
    final val = _controller.text;
    final parsed = int.tryParse(val) ?? widget.min;
    _updateValue(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TactileCircleButton(
          icon: Icons.remove_rounded,
          sentinel: sentinel,
          size: 28,
          onTap: widget.value > widget.min ? () => _updateValue(widget.value - 1) : () {},
        ),
        const Gap(12),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 45,
              child: TextFormField(
                controller: _controller,
                focusNode: _focusNode,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: sentinel.navy,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  if (val.isEmpty) return; // Allow clearing the field
                  final parsed = int.tryParse(val);
                  if (parsed != null && parsed >= widget.min && parsed <= widget.max) {
                    widget.onChanged(parsed);
                  }
                },
                onFieldSubmitted: (val) => _finalizeValue(),
              ),
            ),
            Text(
              widget.label.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: sentinel.navy.withOpacity(0.5),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const Gap(12),
        TactileCircleButton(
          icon: Icons.add_rounded,
          sentinel: sentinel,
          size: 28,
          onTap: widget.value < widget.max ? () => _updateValue(widget.value + 1) : () {},
        ),
      ],
    );
  }
}
