import 'package:intl/intl.dart';

class Formatters {
  static String currency(double amount, {String symbol = '৳'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static String date(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String time(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String dateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }
}
