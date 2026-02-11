// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobileapplication/userdashboard/config/user_dashboard_fonts.dart';

class CalendarGridView extends StatelessWidget {
  final List<DateTime> days;
  final DateTime currentMonth;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isAdmin;
  final bool isEditing;
  final Function(DateTime, DateTime)? onDateRangeSelected;
  final Function(DateTime) startDateCallback;
  final Function(DateTime) endDateCallback;
  final double calendarSize;

  const CalendarGridView({
    super.key,
    required this.days,
    required this.currentMonth,
    required this.startDate,
    required this.endDate,
    required this.isAdmin,
    required this.isEditing,
    required this.onDateRangeSelected,
    required this.startDateCallback,
    required this.endDateCallback,
    required this.calendarSize,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final date = days[index];
        final isCurrentMonth = date.month == currentMonth.month;
        final isStartDate = startDate != null &&
            date.year == startDate!.year &&
            date.month == startDate!.month &&
            date.day == startDate!.day;
        final isEndDate = endDate != null &&
            date.year == endDate!.year &&
            date.month == endDate!.month &&
            date.day == endDate!.day;

        return CalendarDayCell(
            date: date,
            isCurrentMonth: isCurrentMonth,
            isStartDate: isStartDate,
            isEndDate: isEndDate,
            isEnabled: isCurrentMonth && (isAdmin || isEditing),
            isAdmin: isAdmin,
            onTap: () {
              if (startDate == null || endDate != null) {
                startDateCallback(date);
              } else {
                // At this point, startDate is guaranteed to be non-null
                final nonNullStartDate = startDate!;
                if (date.isBefore(nonNullStartDate)) {
                  endDateCallback(nonNullStartDate);
                  startDateCallback(date);
                } else {
                  endDateCallback(date);
                  if (onDateRangeSelected != null) {
                    onDateRangeSelected!(nonNullStartDate, date);
                  }
                }
              }
            });
      },
    );
  }
}

class CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final bool isCurrentMonth;
  final bool isStartDate;
  final bool isEndDate;
  final bool isEnabled;
  final bool isAdmin;
  final VoidCallback onTap;

  const CalendarDayCell({
    super.key,
    required this.date,
    required this.isCurrentMonth,
    required this.isStartDate,
    required this.isEndDate,
    required this.isEnabled,
    required this.isAdmin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isStartDate
              ? const Color(0xFF4CAF50)
              : isEndDate
                  ? const Color(0xFFE57373)
                  : Colors.transparent,
          border: !isStartDate && !isEndDate && isCurrentMonth
              ? Border.all(color: const Color(0xFF90CAF9))
              : null,
          boxShadow: (isStartDate || isEndDate)
              ? [
                  BoxShadow(
                    color: (isStartDate ? Colors.green : Colors.red)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: UserDashboardFonts.bodyText.copyWith(
              color: !isCurrentMonth
                  ? Colors.grey.withOpacity(0.3)
                  : isStartDate || isEndDate
                      ? Colors.white
                      : const Color(0xFF1565C0),
              fontWeight: isStartDate || isEndDate
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildCalendarHeader({
  required DateTime currentMonth,
  required VoidCallback onPreviousMonth,
  required VoidCallback onNextMonth,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    decoration: const BoxDecoration(
      color: Color(0xFF1565C0),
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('MMMM yyyy').format(currentMonth),
          style: UserDashboardFonts.extraLargeTextSemiBold.copyWith(
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon:
                  const Icon(Icons.chevron_left, color: Colors.white, size: 28),
              onPressed: onPreviousMonth,
              splashRadius: 24,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right,
                  color: Colors.white, size: 28),
              onPressed: onNextMonth,
              splashRadius: 24,
            ),
          ],
        ),
      ],
    ),
  );
}

Widget buildCalendarContainer({
  required double calendarSize,
  required Widget child,
}) {
  return Container(
    width: calendarSize,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.blue.shade100),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.1),
          blurRadius: 15,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}

Widget buildDetailsCard({
  required double calendarSize,
}) {
  return Container(
    width: calendarSize,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details:',
          style: UserDashboardFonts.bodyTextMedium,
        ),
        const SizedBox(height: 8),
        buildDateIndicator(
          label: 'Start Date',
          color: const Color(0xFFFF7B7B),
        ),
        const SizedBox(height: 4),
        buildDateIndicator(
          label: 'End Date',
          color: const Color(0xFF7BDCB5),
        ),
      ],
    ),
  );
}

Widget buildDateIndicator({
  required String label,
  required Color color,
}) {
  return Row(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: UserDashboardFonts.smallText,
      ),
    ],
  );
}
