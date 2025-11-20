// utils/helpers.dart

import 'package:intl/intl.dart';

class Helpers {
  // Robust date/time formatting with a clean fallback
  static String formatDateTime(DateTime dateTime) {
    try {
      // Example output: "Nov 19, 2025 \n(9:29 PM)"
      return DateFormat('MMM d, yyyy \n(h:mm a)').format(dateTime);
    } on FormatException {
      // Fallback format on failure: "19/11/2025 21:29"
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  // Uses NumberFormat for robust currency formatting (recommended)
  static String formatCurrency(double amount,
      {String symbol = 'Ksh', String locale = 'en_KE'}) {
    // Example output: "Ksh 1,234.56"
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String cleanString(String text) {
    return text.trim();
  }

  static String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}
