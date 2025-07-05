import 'package:intl/intl.dart';

class DateTimeUtils {
  static String formatDate(DateTime dateTime, {String? locale}) {
    final formatter = DateFormat('yyyy-MM-dd h:mm a', locale);
    return formatter.format(dateTime);
  }

  static String formatDateShort(DateTime dateTime, {String? locale}) {
    final formatter = DateFormat('MMM dd, h:mm a', locale);
    return formatter.format(dateTime);
  }

  static String formatDateLong(DateTime dateTime, {String? locale}) {
    final formatter = DateFormat('EEEE, MMMM dd, yyyy h:mm a', locale);
    return formatter.format(dateTime);
  }

  static String formatTime(DateTime dateTime, {String? locale}) {
    final formatter = DateFormat('h:mm a', locale);
    return formatter.format(dateTime);
  }
}
