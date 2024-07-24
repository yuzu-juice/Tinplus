import 'package:intl/intl.dart';

class DateUtils {
  static DateTime truncateToDate(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static String formatDate(DateTime date, {String format = 'yyyy年MM月dd日'}) {
    return DateFormat(format).format(date);
  }

  static DateTime parseDate(String dateString, {String format = 'yyyy-MM-dd'}) {
    return DateFormat(format).parse(dateString);
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }
}
