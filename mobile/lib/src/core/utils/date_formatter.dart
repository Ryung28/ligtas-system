import 'package:intl/intl.dart';

class DateFormatter {
  /// Implements the 'Contextual Chronology' pattern for LIGTAS.
  /// 
  /// Today: 5:30 PM
  /// Yesterday: Yesterday
  /// Last 7 days: March 3 Thursday
  /// Older: Mar 3
  static String formatContextual(DateTime? date) {
    if (date == null) return 'N/A';

    final now = DateTime.now();
    final localDate = date.toLocal();
    
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfYesterday = startOfToday.subtract(const Duration(days: 1));
    final sevenDaysAgo = startOfToday.subtract(const Duration(days: 7));
    
    final messageStartOfDay = DateTime(localDate.year, localDate.month, localDate.day);

    if (messageStartOfDay == startOfToday) {
      // Today: 5:30 PM
      return DateFormat.jm().format(localDate);
    }

    if (messageStartOfDay == startOfYesterday) {
      return 'Yesterday';
    }

    if (localDate.isAfter(sevenDaysAgo)) {
      // Last 7 days: March 3 Thursday
      // Note: matches web Intl.DateTimeFormat with month: long, day: numeric, weekday: long
      return DateFormat('MMMM d EEEE').format(localDate);
    }

    // Older: Mar 3
    return DateFormat('MMM d').format(localDate);
  }

  static String formatGroupHeader(DateTime date) {
    final now = DateTime.now();
    final localDate = date.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(localDate.year, localDate.month, localDate.day);

    if (checkDate == today) return 'TODAY';
    if (checkDate == yesterday) return 'YESTERDAY';
    
    return DateFormat('MMMM d, y').format(localDate).toUpperCase();
  }

  static String formatRelative(DateTime? date) {
    if (date == null) return 'NEVER';
    final diff = DateTime.now().difference(date);
    
    if (diff.inSeconds < 60) return 'JUST NOW';
    if (diff.inMinutes < 60) return '${diff.inMinutes}M AGO';
    if (diff.inHours < 24) return '${diff.inHours}H AGO';
    if (diff.inDays < 7) return '${diff.inDays}D AGO';
    
    return DateFormat('MMM d').format(date).toUpperCase();
  }
}
