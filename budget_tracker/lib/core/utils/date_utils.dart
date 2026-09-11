/// Date helpers for month-bucketed financial reporting. Kept pure/deterministic
/// (no DateTime.now() defaults hidden inside) so calculations stay testable.
class AppDateUtils {
  AppDateUtils._();

  static DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month, 1);

  static DateTime endOfMonth(DateTime date) {
    final firstOfNextMonth = date.month == 12
        ? DateTime(date.year + 1, 1, 1)
        : DateTime(date.year, date.month + 1, 1);
    return firstOfNextMonth.subtract(const Duration(milliseconds: 1));
  }

  static bool isInMonth(DateTime date, DateTime month) {
    return date.year == month.year && date.month == month.month;
  }

  static List<DateTime> lastNMonths(DateTime from, int n) {
    return List.generate(n, (i) {
      final month = from.month - i;
      final yearOffset = ((month - 1) ~/ 12) - (month <= 0 ? 1 : 0);
      final normalizedMonth = ((month - 1) % 12 + 12) % 12 + 1;
      return DateTime(from.year + yearOffset, normalizedMonth, 1);
    }).reversed.toList();
  }

  static int daysBetween(DateTime a, DateTime b) => b.difference(a).inDays;
}
