import '../entities/transaction.dart';
import '../entities/budget.dart';
import '../entities/financial_goal.dart';
import '../entities/recurring_transaction.dart';
import '../entities/enums.dart';
import '../../../core/utils/date_utils.dart';

/// Result of an affordability check. Deliberately structured (not a single
/// bool) so both the UI and the AI assistant can explain *why*, not just
/// answer yes/no.
class AffordabilityResult {
  final bool canAfford;
  final double projectedBalanceAfterPurchase;
  final double projectedBalanceBeforePurchase;
  final double totalUpcomingRecurringExpenses;
  final String? warning;

  const AffordabilityResult({
    required this.canAfford,
    required this.projectedBalanceAfterPurchase,
    required this.projectedBalanceBeforePurchase,
    required this.totalUpcomingRecurringExpenses,
    this.warning,
  });
}

class CashFlowDayPoint {
  final DateTime date;
  final double projectedBalance;
  final List<String> events; // human-readable, e.g. "Rent due: -₱15,000"

  const CashFlowDayPoint({required this.date, required this.projectedBalance, this.events = const []});
}

class CashFlowForecast {
  final List<CashFlowDayPoint> points;
  final double lowestProjectedBalance;
  final DateTime? lowestBalanceDate;

  const CashFlowForecast({
    required this.points,
    required this.lowestProjectedBalance,
    this.lowestBalanceDate,
  });
}

/// All financial math for the app lives here, and only here. Every function
/// is pure: same inputs -> same outputs, no DateTime.now(), no I/O. This is
/// what makes both the UI numbers and the AI assistant's tool results
/// trustworthy and testable — see PRD section 7.2.
class FinancialCalculator {
  const FinancialCalculator();

  // ---------------------------------------------------------------------
  // Balance
  // ---------------------------------------------------------------------

  double calculateCurrentBalance(List<Transaction> transactions, {int? accountId, DateTime? asOfDate}) {
    return transactions
        .where((t) => accountId == null || t.accountId == accountId)
        .where((t) => asOfDate == null || !t.date.isAfter(asOfDate))
        .fold(0.0, (sum, t) => sum + t.signedAmount);
  }

  Map<int, double> calculateAccountBalances(List<Transaction> transactions, {DateTime? asOfDate}) {
    final balances = <int, double>{};
    for (final t in transactions) {
      if (asOfDate != null && t.date.isAfter(asOfDate)) continue;
      balances[t.accountId] = (balances[t.accountId] ?? 0) + t.signedAmount;
    }
    return balances;
  }

  // ---------------------------------------------------------------------
  // Income / Expenses
  // ---------------------------------------------------------------------

  double calculateMonthlyIncome(List<Transaction> transactions, DateTime month) {
    return transactions
        .where((t) => t.type == TransactionType.income && AppDateUtils.isInMonth(t.date, month))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double calculateMonthlyExpenses(List<Transaction> transactions, DateTime month, {int? categoryId}) {
    return transactions
        .where((t) => t.type == TransactionType.expense && AppDateUtils.isInMonth(t.date, month))
        .where((t) => categoryId == null || t.categoryId == categoryId)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double calculateAverageMonthlyExpenses(List<Transaction> transactions, DateTime from, int months) {
    final monthList = AppDateUtils.lastNMonths(from, months);
    if (monthList.isEmpty) return 0;
    final total = monthList.fold(0.0, (sum, m) => sum + calculateMonthlyExpenses(transactions, m));
    return total / monthList.length;
  }

  Map<int, double> calculateExpensesByCategory(List<Transaction> transactions, DateTime month) {
    final result = <int, double>{};
    for (final t in transactions) {
      if (t.type != TransactionType.expense || !AppDateUtils.isInMonth(t.date, month)) continue;
      result[t.categoryId] = (result[t.categoryId] ?? 0) + t.amount;
    }
    return result;
  }

  List<MapEntry<int, double>> topSpendingCategories(List<Transaction> transactions, DateTime month, {int limit = 5}) {
    final byCategory = calculateExpensesByCategory(transactions, month);
    final sorted = byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }

  // ---------------------------------------------------------------------
  // Savings
  // ---------------------------------------------------------------------

  /// Savings rate as a fraction of income (0.0-1.0). Returns 0 when income
  /// is 0 rather than dividing by zero — callers should check income
  /// separately if they need to distinguish "no income" from "0% saved".
  double calculateSavingsRate(List<Transaction> transactions, DateTime month) {
    final income = calculateMonthlyIncome(transactions, month);
    if (income <= 0) return 0;
    final expenses = calculateMonthlyExpenses(transactions, month);
    return ((income - expenses) / income).clamp(-double.infinity, 1.0);
  }

  // ---------------------------------------------------------------------
  // Budgets
  // ---------------------------------------------------------------------

  double calculateBudgetUsage(Budget budget, List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .where((t) => budget.coversDate(t.date))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double calculateBudgetRemaining(Budget budget, List<Transaction> transactions) {
    return budget.totalBudget - calculateBudgetUsage(budget, transactions);
  }

  /// Fraction spent, e.g. 0.78 for 78%. Not clamped to 1.0 so callers can
  /// detect and flag overspending (>100%).
  double calculateBudgetPercentage(Budget budget, List<Transaction> transactions) {
    if (budget.totalBudget <= 0) return 0;
    return calculateBudgetUsage(budget, transactions) / budget.totalBudget;
  }

  double calculateBudgetItemUsage(int categoryId, Budget budget, List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.expense && t.categoryId == categoryId)
        .where((t) => budget.coversDate(t.date))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // ---------------------------------------------------------------------
  // Goals
  // ---------------------------------------------------------------------

  double calculateGoalProgress(FinancialGoal goal) => goal.progressPercentage;

  /// Projects a completion date assuming a constant monthly contribution.
  /// Returns null if the contribution is 0 or negative (goal never completes).
  DateTime? calculateGoalCompletionDate(FinancialGoal goal, double monthlyContribution, {required DateTime from}) {
    if (monthlyContribution <= 0) return null;
    if (goal.isComplete) return from;
    final monthsNeeded = (goal.remainingAmount / monthlyContribution).ceil();
    final targetMonth = from.month - 1 + monthsNeeded;
    return DateTime(from.year + targetMonth ~/ 12, targetMonth % 12 + 1, from.day);
  }

  /// Required monthly savings to hit goal.targetDate exactly, given `from`
  /// as today. Returns null if there's no target date or it's already past.
  double? calculateRequiredMonthlySavings(FinancialGoal goal, {required DateTime from}) {
    if (goal.targetDate == null || !goal.targetDate!.isAfter(from)) return null;
    final monthsRemaining = ((goal.targetDate!.year - from.year) * 12 + (goal.targetDate!.month - from.month))
        .clamp(1, 1 << 30);
    return goal.remainingAmount / monthsRemaining;
  }

  // ---------------------------------------------------------------------
  // Recurring transactions
  // ---------------------------------------------------------------------

  double calculateRecurringMonthlyTotal(List<RecurringTransaction> recurring) {
    double total = 0;
    for (final r in recurring.where((r) => r.isActive)) {
      final occurrencesPerMonth = 30.0 / r.frequency.approxDays * (1 / r.interval);
      final signedAmount = r.type == TransactionType.expense ? -r.amount : r.amount;
      total += signedAmount * occurrencesPerMonth;
    }
    return total;
  }

  // ---------------------------------------------------------------------
  // Cash flow / affordability
  // ---------------------------------------------------------------------

  /// Projects daily balance forward by applying known recurring transactions
  /// on top of the current balance. This is the backbone of both the
  /// Analytics forecast and the AI's `calculate_cashflow_forecast` tool.
  CashFlowForecast calculateCashFlowForecast({
    required double currentBalance,
    required List<RecurringTransaction> recurringTransactions,
    required DateTime startDate,
    required int days,
  }) {
    final endDate = startDate.add(Duration(days: days));
    final events = <DateTime, List<String>>{};

    for (final r in recurringTransactions.where((r) => r.isActive)) {
      for (final date in r.occurrencesBetween(startDate, endDate)) {
        final signed = r.type == TransactionType.expense ? -r.amount : r.amount;
        final label = '${r.description}: ${signed >= 0 ? '+' : ''}${signed.toStringAsFixed(0)}';
        events.putIfAbsent(DateTime(date.year, date.month, date.day), () => []).add(label);
      }
    }

    final points = <CashFlowDayPoint>[];
    double runningBalance = currentBalance;
    double lowest = currentBalance;
    DateTime? lowestDate = startDate;

    for (int i = 0; i <= days; i++) {
      final day = DateTime(startDate.year, startDate.month, startDate.day).add(Duration(days: i));
      final dayEvents = events[day] ?? const [];
      for (final r in recurringTransactions.where((r) => r.isActive)) {
        for (final occDate in r.occurrencesBetween(day, day)) {
          if (occDate.year == day.year && occDate.month == day.month && occDate.day == day.day) {
            runningBalance += r.type == TransactionType.expense ? -r.amount : r.amount;
          }
        }
      }
      points.add(CashFlowDayPoint(date: day, projectedBalance: runningBalance, events: dayEvents));
      if (runningBalance < lowest) {
        lowest = runningBalance;
        lowestDate = day;
      }
    }

    return CashFlowForecast(points: points, lowestProjectedBalance: lowest, lowestBalanceDate: lowestDate);
  }

  /// Determines whether a proposed purchase fits, factoring in known
  /// upcoming recurring obligations between `startDate` and `endDate`.
  /// This backs both the "Can I afford ₱X?" AI conversation and the home
  /// screen's budget-status card.
  AffordabilityResult calculateAffordableSpending({
    required double currentBalance,
    required List<RecurringTransaction> recurringExpenses,
    required double proposedAmount,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final upcomingRecurringTotal = recurringExpenses
        .where((r) => r.isActive && r.type == TransactionType.expense)
        .fold(0.0, (sum, r) {
      final occurrences = r.occurrencesBetween(startDate, endDate).length;
      return sum + (r.amount * occurrences);
    });

    final balanceBefore = currentBalance - upcomingRecurringTotal;
    final balanceAfter = balanceBefore - proposedAmount;

    String? warning;
    if (balanceAfter < 0) {
      warning = 'This purchase would put your projected balance below zero.';
    } else if (balanceAfter < currentBalance * 0.1 && currentBalance > 0) {
      warning = 'This would use most of your available buffer.';
    }

    return AffordabilityResult(
      canAfford: balanceAfter >= 0,
      projectedBalanceBeforePurchase: balanceBefore,
      projectedBalanceAfterPurchase: balanceAfter,
      totalUpcomingRecurringExpenses: upcomingRecurringTotal,
      warning: warning,
    );
  }

  // ---------------------------------------------------------------------
  // Trends
  // ---------------------------------------------------------------------

  /// Percentage change in a category's spend vs its trailing average over
  /// the prior `months`. Positive = spending more than usual.
  double calculateCategoryTrend(int categoryId, List<Transaction> transactions, DateTime currentMonth, int months) {
    final current = calculateMonthlyExpenses(transactions, currentMonth, categoryId: categoryId);
    final priorMonths = AppDateUtils.lastNMonths(currentMonth, months + 1)
        .where((m) => !AppDateUtils.isInMonth(m, currentMonth));
    if (priorMonths.isEmpty) return 0;
    final priorTotal = priorMonths.fold(
        0.0, (sum, m) => sum + calculateMonthlyExpenses(transactions, m, categoryId: categoryId));
    final priorAverage = priorTotal / priorMonths.length;
    if (priorAverage <= 0) return current > 0 ? 1.0 : 0.0;
    return (current - priorAverage) / priorAverage;
  }

  Map<DateTime, double> calculateSpendingTrend(List<Transaction> transactions, DateTime from, int months) {
    final monthList = AppDateUtils.lastNMonths(from, months);
    return {for (final m in monthList) m: calculateMonthlyExpenses(transactions, m)};
  }
}
