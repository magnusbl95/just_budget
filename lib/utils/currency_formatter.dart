import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, {String symbol = r'$'}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatCompact(double amount, {String symbol = r'$'}) {
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 10000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}k';
    }
    return format(amount, symbol: symbol);
  }
}
