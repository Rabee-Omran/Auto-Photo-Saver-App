import 'package:intl/intl.dart';

class FileSizeUtils {
  static String formatFileSize(
    int bytes, {
    String? locale,
    String? bytesUnit,
    String? kbUnit,
    String? mbUnit,
    String? gbUnit,
  }) {
    if (bytes < 1024) {
      return '$bytes ${bytesUnit ?? 'B'}';
    } else if (bytes < 1024 * 1024) {
      final kb = bytes / 1024;
      return '${_formatNumber(kb, locale)} ${kbUnit ?? 'KB'}';
    } else if (bytes < 1024 * 1024 * 1024) {
      final mb = bytes / (1024 * 1024);
      return '${_formatNumber(mb, locale)} ${mbUnit ?? 'MB'}';
    } else {
      final gb = bytes / (1024 * 1024 * 1024);
      return '${_formatNumber(gb, locale)} ${gbUnit ?? 'GB'}';
    }
  }

  static String _formatNumber(double number, String? locale) {
    final formatter = NumberFormat('#.##', locale);
    return formatter.format(number);
  }
}
