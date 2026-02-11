// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:mobileapplication/admindashboard/banpage/ban_period_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileapplication/userdashboard/config/user_dashboard_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mobileapplication/userdashboard/usersettingsv2/usersettings_provider_v2.dart';

class BanPeriodCalendar extends StatefulWidget {
  final Function(DateTime, DateTime)? onDateRangeSelected;
  final bool isAdmin;

  const BanPeriodCalendar({
    super.key,
    this.onDateRangeSelected,
    this.isAdmin = false,
  });

  @override
  _BanPeriodCalendarState createState() => _BanPeriodCalendarState();
}

class _BanPeriodCalendarState extends State<BanPeriodCalendar>
    with TickerProviderStateMixin {
  late DateTime _currentMonth;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _banPeriodDescription;
  bool _isEditing = false;
  bool _isLoading = true;
  StreamSubscription? _banPeriodSubscription;
  final BanPeriodService _banPeriodService = BanPeriodService();
  final _updateController = StreamController<Map<String, dynamic>>.broadcast();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _setupAnimations();
    _setupBanPeriodStream();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  void _setupBanPeriodStream() {
    _updateController.stream.distinct((previous, next) {
      final prevStart = previous['startDate'] as Timestamp?;
      final prevEnd = previous['endDate'] as Timestamp?;
      final nextStart = next['startDate'] as Timestamp?;
      final nextEnd = next['endDate'] as Timestamp?;

      return prevStart?.toDate() == nextStart?.toDate() &&
          prevEnd?.toDate() == nextEnd?.toDate();
    }).listen(_updateBanPeriod);

    _banPeriodSubscription = _banPeriodService.getCurrentBanPeriod().listen(
      (snapshot) {
        if (!mounted || _isEditing) return;

        final data = snapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          _updateController.add(data);
        }

        if (_isLoading) {
          setState(() => _isLoading = false);
        }
      },
      onError: (error) {
        if (_isLoading) {
          setState(() => _isLoading = false);
        }
      },
    );
  }

  void _updateBanPeriod(Map<String, dynamic> data) {
    if (!mounted || _isEditing) return;

    final startTimestamp = data['startDate'] as Timestamp?;
    final endTimestamp = data['endDate'] as Timestamp?;
    final description = data['description'] as String?;

    final newStartDate = startTimestamp?.toDate();
    final newEndDate = endTimestamp?.toDate();

    if (_startDate != newStartDate || _endDate != newEndDate || _banPeriodDescription != description) {
      setState(() {
        _startDate = newStartDate;
        _endDate = newEndDate;
        _banPeriodDescription = description;
      });
    }
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final daysBefore = first.weekday - 1;
    final firstToDisplay = first.subtract(Duration(days: daysBefore));

    final last = DateTime(month.year, month.month + 1, 0);
    final daysAfter = 7 - last.weekday;
    final lastToDisplay = last.add(Duration(days: daysAfter));

    return List.generate(
      lastToDisplay.difference(firstToDisplay).inDays + 1,
      (index) => firstToDisplay.add(Duration(days: index)),
    );
  }

  bool _isDateInRange(DateTime date) {
    if (_startDate == null || _endDate == null) return false;
    return date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
        date.isBefore(_endDate!.add(const Duration(days: 1)));
  }

  bool _isDateStart(DateTime date) {
    return _startDate != null &&
        date.year == _startDate!.year &&
        date.month == _startDate!.month &&
        date.day == _startDate!.day;
  }

  bool _isDateEnd(DateTime date) {
    return _endDate != null &&
        date.year == _endDate!.year &&
        date.month == _endDate!.month &&
        date.day == _endDate!.day;
  }

  void _onDateTap(DateTime date) {
    if (!widget.isAdmin) return;

    setState(() {
      _isEditing = true;
      if (_startDate == null || _endDate != null) {
        _startDate = date;
        _endDate = null;
      } else if (date.isBefore(_startDate!)) {
        _endDate = _startDate;
        _startDate = date;
      } else {
        _endDate = date;
      }
    });
  }

  void _showUpdateConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Update Ban Period'),
          ],
        ),
        content: const Text('Are you sure you want to update the ban period?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                if (_startDate == null || _endDate == null) {
                  throw Exception('Please select both start and end dates');
                }
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Updating ban period...'),
                    duration: Duration(seconds: 1),
                  ),
                );

                await _banPeriodService.updateBanPeriod(
                  startDate: _startDate!,
                  endDate: _endDate!,
                );

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ban period updated successfully'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                  ),
                );
                setState(() => _isEditing = false);
              } catch (e) {
                if (!mounted) return;

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Error'),
                    content: Text(e.toString()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _banPeriodSubscription?.cancel();
    _updateController.close();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProviderV2>(
      builder: (context, settingsProvider, _) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final themeColors = settingsProvider.getCurrentThemeColors(isDarkMode);

        final Color backgroundColor = themeColors['background']!;

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildModernHeader(isDarkMode, themeColors),
                      _isLoading
                          ? _buildLoadingState(themeColors)
                          : _buildModernCalendar(isDarkMode, themeColors),
                      if (widget.isAdmin &&
                          _isEditing &&
                          _startDate != null &&
                          _endDate != null)
                        _buildUpdateButton(),
                      const SizedBox(height: 12), // Bottom padding for scroll
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernHeader(bool isDarkMode, Map<String, Color> themeColors) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeColors['primary']!,
            themeColors['accent']!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeColors['primary']!.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fishing Ban Period',
                      style: UserDashboardFonts.largeTextSemiBold.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Current schedule and calendar view',
                      style: UserDashboardFonts.bodyTextMedium.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          if (_startDate != null && _endDate != null) ...[
            const SizedBox(height: 16),
            _buildDateRangeDisplay(),
            // Show description if available
            if (_banPeriodDescription != null && _banPeriodDescription!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildDescriptionCard(),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildDateRangeDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDateCard(
              'Start Date',
              _startDate!,
              Icons.play_arrow_rounded,
              Colors.greenAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDateCard(
              'End Date',
              _endDate!,
              Icons.stop_rounded,
              Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(
      String label, DateTime date, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: UserDashboardFonts.smallText.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMM dd, yyyy').format(date),
            style: UserDashboardFonts.bodyTextMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.white.withOpacity(0.9),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reason',
                  style: UserDashboardFonts.smallText.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _banPeriodDescription!,
                  style: UserDashboardFonts.bodyTextMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(Map<String, Color> themeColors) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading ban period data...'),
        ],
      ),
    );
  }

  Widget _buildModernCalendar(bool isDarkMode, Map<String, Color> themeColors) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: themeColors['card']!,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCalendarHeader(isDarkMode),
          _buildCalendarGrid(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _currentMonth =
                    DateTime(_currentMonth.year, _currentMonth.month - 1);
              });
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                color: isDarkMode ? Colors.white : Colors.grey.shade700,
                size: 20,
              ),
            ),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_currentMonth),
            style: UserDashboardFonts.largeTextSemiBold.copyWith(
              color: isDarkMode ? Colors.white : Colors.grey.shade800,
              fontSize: 18,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _currentMonth =
                    DateTime(_currentMonth.year, _currentMonth.month + 1);
              });
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: isDarkMode ? Colors.white : Colors.grey.shade700,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(bool isDarkMode) {
    final days = _getDaysInMonth(_currentMonth);
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Week day headers - Compact
          Row(
            children: weekDays
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: UserDashboardFonts.smallText.copyWith(
                            color: isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),
          // Calendar grid - Fixed height to prevent overflow
          SizedBox(
            height: 180, // Fixed height to prevent overflow
            child: Column(
              children: List.generate(6, (weekIndex) {
                final weekDays = days.skip(weekIndex * 7).take(7).toList();
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: weekDays
                          .map((date) => Expanded(
                                child: _buildCalendarDay(date, isDarkMode),
                              ))
                          .toList(),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 6),
          // Additional info section - Compact
          _buildCalendarInfo(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(DateTime date, bool isDarkMode) {
    final isCurrentMonth = date.month == _currentMonth.month;
    final isToday = date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;
    final isInRange = _isDateInRange(date);
    final isStart = _isDateStart(date);
    final isEnd = _isDateEnd(date);

    return GestureDetector(
      onTap: () => _onDateTap(date),
      child: Container(
        margin: const EdgeInsets.all(0.5),
        decoration: BoxDecoration(
          color: _getDayColor(isInRange, isStart, isEnd, isToday, isDarkMode),
          borderRadius: BorderRadius.circular(6),
          border: isToday
              ? Border.all(
                  color: Colors.blue,
                  width: 1,
                )
              : null,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: UserDashboardFonts.bodyTextMedium.copyWith(
              color: _getDayTextColor(isInRange, isStart, isEnd, isToday,
                  isCurrentMonth, isDarkMode),
              fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Color _getDayColor(
      bool isInRange, bool isStart, bool isEnd, bool isToday, bool isDarkMode) {
    if (isStart || isEnd) {
      return Colors.blue;
    }
    if (isInRange) {
      return Colors.blue.withOpacity(0.2);
    }
    if (isToday) {
      return Colors.blue.withOpacity(0.1);
    }
    return Colors.transparent;
  }

  Color _getDayTextColor(bool isInRange, bool isStart, bool isEnd, bool isToday,
      bool isCurrentMonth, bool isDarkMode) {
    if (isStart || isEnd) {
      return Colors.white;
    }
    if (isToday) {
      return Colors.blue;
    }
    if (!isCurrentMonth) {
      return isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400;
    }
    return isDarkMode ? Colors.white : Colors.grey.shade800;
  }

  Widget _buildCalendarInfo(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade600,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Legend',
                style: UserDashboardFonts.bodyTextMedium.copyWith(
                  color: isDarkMode ? Colors.white : Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLegendItem(
                  'Today',
                  Colors.blue,
                  isDarkMode,
                ),
              ),
              Expanded(
                child: _buildLegendItem(
                  'Ban Period',
                  Colors.red,
                  isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildLegendItem(
                  'Start Date',
                  Colors.green,
                  isDarkMode,
                ),
              ),
              Expanded(
                child: _buildLegendItem(
                  'End Date',
                  Colors.orange,
                  isDarkMode,
                ),
              ),
            ],
          ),
          if (_startDate != null && _endDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.blue,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Current ban period: ${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}',
                      style: UserDashboardFonts.smallText.copyWith(
                        color: isDarkMode
                            ? Colors.blue.shade300
                            : Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDarkMode) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: UserDashboardFonts.smallText.copyWith(
            color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _showUpdateConfirmation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.update_rounded, size: 20),
            const SizedBox(width: 8),
            Text(
              'Update Ban Period',
              style: UserDashboardFonts.bodyTextMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
