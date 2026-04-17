import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat('#,##0', 'id_ID');

  static String format(num amount) {
    return 'Rp ${_formatter.format(amount)}';
  }

  static String formatCompact(num amount) {
    // Tanpa prefix "Rp" untuk kasus tertentu
    return _formatter.format(amount);
  }
}
