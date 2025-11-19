// utils/helpers.dart
String formatCurrency(double amount) {
  return '${AppConstants.currency} ${amount.toStringAsFixed(2)}';
}

bool isEmailValid(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}
