import "package:intl/intl.dart";

/// Formats amounts using the user's chosen currency. Centralized so every
/// screen and AI tool response renders money identically.
class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(double amount, {String currencyCode = "PHP", String locale = "en_PH"}) {
    final symbol = _symbolFor(currencyCode);
    final formatter = NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: 2);
    return formatter.format(amount);
  }

  /// Compact form for charts / small UI, e.g. "20.4K" instead of "20,420.00".
  static String formatCompact(double amount, {String currencyCode = "PHP"}) {
    final symbol = _symbolFor(currencyCode);
    final formatter = NumberFormat.compactCurrency(symbol: symbol, decimalDigits: 1);
    return formatter.format(amount);
  }

  static String _symbolFor(String currencyCode) {
    switch (currencyCode) {
      case "PHP":
        return "\u20b1";
      case "USD":
        return "\$";
      case "EUR":
        return "\u20ac";
      case "JPY":
        return "\u00a5";
      case "GBP":
        return "\u00a3";
      default:
        return currencyCode;
    }
  }
}
