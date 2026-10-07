import 'package:intl/intl.dart';

abstract final class DateFormatter {
  static String timestamp(DateTime date) =>
      DateFormat('MMM d, yyyy · h:mm a', 'en_PH').format(date);
  static String header(DateTime date) =>
      DateFormat('EEEE, MMM d', 'en_PH').format(date);
  static String transaction(DateTime date, DateTime now) {
    final day = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final days = today.difference(day).inDays;
    if (days == 0) {
      return 'Today, ${DateFormat('h:mm a', 'en_PH').format(date)}';
    }
    if (days == 1) return 'Yesterday';
    return DateFormat('MMM d', 'en_PH').format(date);
  }
}
