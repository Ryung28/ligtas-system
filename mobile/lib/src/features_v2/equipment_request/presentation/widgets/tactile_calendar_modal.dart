import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'tactile_buttons.dart';

// 🛡️ TACTILE CALENDAR MODAL: The Shell + Picker Logic
class TactileCalendarModal extends StatefulWidget {
  final DateTime initialDate;
  final DateTime? minDate;
  final String? title;
  final Function(DateTime)? onDateSelected;

  const TactileCalendarModal({
    super.key,
    required this.initialDate,
    this.minDate,
    this.title,
    this.onDateSelected,
  });

  @override
  State<TactileCalendarModal> createState() => _TactileCalendarModalState();
}

class _TactileCalendarModalState extends State<TactileCalendarModal> {
  late DateTime _selectedDate;
  late DateTime _viewMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _viewMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  void _onDayTap(DateTime day) {
    setState(() => _selectedDate = day);
    if (widget.onDateSelected != null) {
      widget.onDateSelected!(day);
    }
    Navigator.of(context).pop(day);
  }

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    final daysInMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_viewMonth.year, _viewMonth.month, 1).weekday % 7;
    
    final days = <DateTime?>[];
    for (var i = 0; i < firstWeekday; i++) days.add(null);
    for (var i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(_viewMonth.year, _viewMonth.month, i));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag Handle
        Container(width: 40, height: 4, decoration: BoxDecoration(color: sentinel.navy.withOpacity(0.1), borderRadius: BorderRadius.circular(2))),
        const Gap(24),

        if (widget.title != null) ...[
          Text(
            widget.title!.toUpperCase(),
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: sentinel.navy.withOpacity(0.5),
              letterSpacing: 1.5,
            ),
          ),
          const Gap(16),
        ],
        
        // Month Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TactileCircleButton(
              icon: Icons.chevron_left_rounded,
              sentinel: sentinel,
              size: 36,
              onTap: () => setState(() => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1)),
            ),
            Text(
              '${_getMonthName(_viewMonth.month)} ${_viewMonth.year}',
              style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w800, color: sentinel.navy),
            ),
            TactileCircleButton(
              icon: Icons.chevron_right_rounded,
              sentinel: sentinel,
              size: 36,
              onTap: () => setState(() => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1)),
            ),
          ],
        ),
        const Gap(24),
        
        // Grid Builder for Native Snap Performance
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, 
              mainAxisSpacing: 8, 
              crossAxisSpacing: 8,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              if (day == null) return const SizedBox();
              
              final isSelected = day.day == _selectedDate.day && day.month == _selectedDate.month && day.year == _selectedDate.year;
              final isPast = widget.minDate != null && 
                             day.isBefore(DateTime(widget.minDate!.year, widget.minDate!.month, widget.minDate!.day));
              
              return GestureDetector(
                onTap: isPast ? null : () => _onDayTap(day),
                child: Opacity(
                  opacity: isPast ? 0.2 : 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? sentinel.navy : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: isSelected ? [] : [
                        const BoxShadow(color: Colors.white, offset: Offset(-1, -1), blurRadius: 2),
                        BoxShadow(color: const Color(0xFFA2B1C6).withOpacity(0.1), offset: const Offset(1, 1), blurRadius: 2),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: GoogleFonts.lexend(
                          fontSize: 13, 
                          fontWeight: FontWeight.w800, 
                          color: isSelected ? Colors.white : sentinel.navy,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }
}
