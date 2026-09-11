import '../../../shared/domain/entities/enums.dart';
import '../../../shared/domain/repositories/transaction_repository.dart';
import '../../../shared/domain/repositories/account_repository.dart';
import '../../../shared/domain/repositories/budget_repository.dart';
import '../../../shared/domain/repositories/goal_repository.dart';
import '../../../shared/domain/repositories/recurring_transaction_repository.dart';
import '../../../shared/domain/services/financial_calculator.dart';
import 'ai_tool.dart';

/// Builds the full set of [AITool]s the assistant can call, scoped to one
/// user. Every tool here is a thin wrapper around [FinancialCalculator] plus
/// repository reads — no tool ever fabricates a number, and every tool is
/// independently unit-testable without any AI model involved (see PRD 6.5,
/// "NEVER fabricate financial data").
class FinancialToolsRegistry {
  FinancialToolsRegistry({
    required this.userId,
    required this.transactionRepository,
    required this.accountRepository,
    required this.budgetRepository,
    required this.goalRepository,
    required this.recurringRepository,
    this.calculator = const FinancialCalculator(),
  });

  final int userId;
  final TransactionRepository transactionRepository;
  final AccountRepository accountRepository;
  final BudgetRepository budgetRepository;
  final GoalRepository goalRepository;
  final RecurringTransactionRepository recurringRepository;
  final FinancialCalculator calculator;

  List<AITool> buildTools() => [
        _getCurrentBalance(),
        _getAccountBalances(),
        _getMonthlyIncome(),
        _getMonthlyExpenses(),
        _getExpensesByCategory(),
        _getSpendingTrends(),
        _getRecentTransactions(),
        _getBudgetStatus(),
        _getRemainingBudget(),
        _getAllGoals(),
        _getGoalProgress(),
        _calculateAffordableSpending(),
        _calculateCashflowForecast(),
        _calculateSavingsRate(),
        _getRecurringExpenses(),
        _calculateRecurringMonthlyTotal(),
        _getTopSpendingCategories(),
        _getIncomeVsExpense(),
        _searchTransactions(),
      ];

  // -- Balance ------------------------------------------------------------

  AITool _getCurrentBalance() => AITool(
        name: 'get_current_balance',
        description: "Returns the user's total available balance across accounts, "
            'optionally as of a specific date or for a single account.',
        parameters: {
          'asOfDate': const ToolParameter(type: 'date', description: 'ISO date; defaults to today'),
          'accountId': const ToolParameter(type: 'number', description: 'Restrict to one account'),
        },
        execute: (args) async {
          final txns = await transactionRepository.getAllForUser(userId);
          if (txns.isEmpty) return const ToolResult.fail('No transactions recorded yet.');
          final asOf = _parseDate(args['asOfDate']);
          final accountId = args['accountId'] as int?;
          final balance = calculator.calculateCurrentBalance(txns, accountId: accountId, asOfDate: asOf);
          return ToolResult.ok({'balance': balance, 'asOfDate': (asOf ?? DateTime.now()).toIso8601String()});
        },
      );

  AITool _getAccountBalances() => AITool(
        name: 'get_account_balances',
        description: 'Returns the balance of every account, optionally as of a specific date.',
        parameters: {'asOfDate': const ToolParameter(type: 'date', description: 'ISO date; defaults to today')},
        execute: (args) async {
          final txns = await transactionRepository.getAllForUser(userId);
          final accounts = await accountRepository.getAllForUser(userId);
          final balances = calculator.calculateAccountBalances(txns, asOfDate: _parseDate(args['asOfDate']));
          return ToolResult.ok({
            'accounts': [
              for (final a in accounts) {'id': a.id, 'name': a.name, 'balance': balances[a.id] ?? 0.0}
            ],
          });
        },
      );

  // -- Income / Expenses ---------------------------------------------------

  AITool _getMonthlyIncome() => AITool(
        name: 'get_monthly_income',
        description: 'Total income recorded for a given month.',
        parameters: {'month': const ToolParameter(type: 'date', description: 'Any date within the target month', required: true)},
        execute: (args) async {
          final month = _parseDate(args['month']);
          if (month == null) return const ToolResult.fail('A month is required.');
          final txns = await transactionRepository.getAllForUser(userId);
          return ToolResult.ok({'month': _monthLabel(month), 'income': calculator.calculateMonthlyIncome(txns, month)});
        },
      );

  AITool _getMonthlyExpenses() => AITool(
        name: 'get_monthly_expenses',
        description: 'Total expenses for a given month, optionally filtered by category.',
        parameters: {
          'month': const ToolParameter(type: 'date', description: 'Any date within the target month', required: true),
          'categoryId': const ToolParameter(type: 'number', description: 'Restrict to one category'),
        },
        execute: (args) async {
          final month = _parseDate(args['month']);
          if (month == null) return const ToolResult.fail('A month is required.');
          final txns = await transactionRepository.getAllForUser(userId);
          final expenses = calculator.calculateMonthlyExpenses(txns, month, categoryId: args['categoryId'] as int?);
          return ToolResult.ok({'month': _monthLabel(month), 'expenses': expenses});
        },
      );

  AITool _getExpensesByCategory() => AITool(
        name: 'get_expenses_by_category',
        description: 'Breaks down a month\'s expenses by category.',
        parameters: {'month': const ToolParameter(type: 'date', description: 'Any date within the target month', required: true)},
        execute: (args) async {
          final month = _parseDate(args['month']);
          if (month == null) return const ToolResult.fail('A month is required.');
          final txns = await transactionRepository.getAllForUser(userId);
          final byCategory = calculator.calculateExpensesByCategory(txns, month);
          return ToolResult.ok({'month': _monthLabel(month), 'byCategory': byCategory});
        },
      );

  AITool _getSpendingTrends() => AITool(
        name: 'get_spending_trends',
        description: 'Total spend per month over the trailing N months, for trend analysis.',
        parameters: {'months': const ToolParameter(type: 'number', description: 'Number of months to include', defaultValue: 6)},
        execute: (args) async {
          final txns = await transactionRepository.getAllForUser(userId);
          final months = (args['months'] as num?)?.toInt() ?? 6;
          final trend = calculator.calculateSpendingTrend(txns, DateTime.now(), months);
          return ToolResult.ok({
            'trend': trend.map((month, total) => MapEntry(_monthLabel(month), total)),
          });
        },
      );

  AITool _getRecentTransactions() => AITool(
        name: 'get_recent_transactions',
        description: 'Most recent transactions, optionally filtered by category or type.',
        parameters: {
          'limit': const ToolParameter(type: 'number', description: 'Max results', defaultValue: 10),
          'categoryId': const ToolParameter(type: 'number', description: 'Restrict to one category'),
          'type': const ToolParameter(type: 'string', description: 'expense | income | transfer'),
        },
        execute: (args) async {
          var txns = await transactionRepository.getAllForUser(userId);
          final categoryId = args['categoryId'] as int?;
          final type = args['type'] as String?;
          if (categoryId != null) txns = txns.where((t) => t.categoryId == categoryId).toList();
          if (type != null) txns = txns.where((t) => t.type.dbValue == type).toList();
          final limit = (args['limit'] as num?)?.toInt() ?? 10;
          final limited = txns.take(limit);
          return ToolResult.ok({
            'transactions': [
              for (final t in limited)
                {
                  'id': t.id,
                  'amount': t.amount,
                  'type': t.type.dbValue,
                  'description': t.description,
                  'date': t.date.toIso8601String(),
                }
            ],
          });
        },
      );

  // -- Budget ---------------------------------------------------------------

  AITool _getBudgetStatus() => AITool(
        name: 'get_budget_status',
        description: 'Overall budget usage for the month containing the given date.',
        parameters: {'month': const ToolParameter(type: 'date', description: 'Any date within the target month', required: true)},
        execute: (args) async {
          final month = _parseDate(args['month']) ?? DateTime.now();
          final budget = await budgetRepository.getActiveForDate(userId, month);
          if (budget == null) return const ToolResult.fail('No active budget found for that period.');
          final txns = await transactionRepository.getAllForUser(userId);
          return ToolResult.ok({
            'budgetName': budget.name,
            'totalBudget': budget.totalBudget,
            'spent': calculator.calculateBudgetUsage(budget, txns),
            'remaining': calculator.calculateBudgetRemaining(budget, txns),
            'percentUsed': calculator.calculateBudgetPercentage(budget, txns),
          });
        },
      );

  AITool _getRemainingBudget() => AITool(
        name: 'get_remaining_budget',
        description: 'Remaining budget for one category in a given month.',
        parameters: {
          'categoryId': const ToolParameter(type: 'number', description: 'Category to check', required: true),
          'month': const ToolParameter(type: 'date', description: 'Any date within the target month', required: true),
        },
        execute: (args) async {
          final month = _parseDate(args['month']) ?? DateTime.now();
          final categoryId = args['categoryId'] as int?;
          if (categoryId == null) return const ToolResult.fail('categoryId is required.');
          final budget = await budgetRepository.getActiveForDate(userId, month);
          if (budget == null) return const ToolResult.fail('No active budget found for that period.');
          final items = await budgetRepository.getItemsForBudget(budget.id!);
          final item = items.where((i) => i.categoryId == categoryId).firstOrNull;
          if (item == null) return const ToolResult.fail('No budget item set for that category.');
          final txns = await transactionRepository.getAllForUser(userId);
          final used = calculator.calculateBudgetItemUsage(categoryId, budget, txns);
          return ToolResult.ok({'categoryBudget': item.amount, 'used': used, 'remaining': item.amount - used});
        },
      );

  // -- Goals ------------------------------------------------------------------

  AITool _getAllGoals() => AITool(
        name: 'get_all_goals',
        description: "Lists the user's active financial goals with progress.",
        parameters: const {},
        execute: (args) async {
          final goals = await goalRepository.getAllForUser(userId);
          return ToolResult.ok({
            'goals': [
              for (final g in goals)
                {
                  'id': g.id,
                  'name': g.name,
                  'targetAmount': g.targetAmount,
                  'currentAmount': g.currentAmount,
                  'progressPercentage': g.progressPercentage,
                  'targetDate': g.targetDate?.toIso8601String(),
                }
            ],
          });
        },
      );

  AITool _getGoalProgress() => AITool(
        name: 'get_goal_progress',
        description: 'Detailed progress for a single goal.',
        parameters: {'goalId': const ToolParameter(type: 'number', description: 'Goal to check', required: true)},
        execute: (args) async {
          final goalId = args['goalId'] as int?;
          if (goalId == null) return const ToolResult.fail('goalId is required.');
          final goal = await goalRepository.getById(goalId);
          if (goal == null) return const ToolResult.fail('Goal not found.');
          return ToolResult.ok({
            'name': goal.name,
            'targetAmount': goal.targetAmount,
            'currentAmount': goal.currentAmount,
            'remainingAmount': goal.remainingAmount,
            'progressPercentage': goal.progressPercentage,
            'targetDate': goal.targetDate?.toIso8601String(),
          });
        },
      );

  // -- Calculations -------------------------------------------------------

  AITool _calculateAffordableSpending() => AITool(
        name: 'calculate_affordable_spending',
        description: 'Checks whether a proposed purchase fits current balance and upcoming '
            'recurring obligations between two dates. This is the primary "Can I afford X?" tool.',
        parameters: {
          'proposedAmount': const ToolParameter(type: 'number', description: 'Amount to spend', required: true),
          'startDate': const ToolParameter(type: 'date', description: 'Usually today', required: true),
          'endDate': const ToolParameter(type: 'date', description: 'End of the window to check', required: true),
        },
        execute: (args) async {
          final proposedAmount = (args['proposedAmount'] as num?)?.toDouble();
          final startDate = _parseDate(args['startDate']);
          final endDate = _parseDate(args['endDate']);
          if (proposedAmount == null || startDate == null || endDate == null) {
            return const ToolResult.fail('proposedAmount, startDate, and endDate are all required.');
          }
          final txns = await transactionRepository.getAllForUser(userId);
          final recurring = await recurringRepository.getAllForUser(userId);
          final currentBalance = calculator.calculateCurrentBalance(txns);
          final result = calculator.calculateAffordableSpending(
            currentBalance: currentBalance,
            recurringExpenses: recurring,
            proposedAmount: proposedAmount,
            startDate: startDate,
            endDate: endDate,
          );
          return ToolResult.ok({
            'canAfford': result.canAfford,
            'currentBalance': currentBalance,
            'projectedBalanceBeforePurchase': result.projectedBalanceBeforePurchase,
            'projectedBalanceAfterPurchase': result.projectedBalanceAfterPurchase,
            'upcomingRecurringExpenses': result.totalUpcomingRecurringExpenses,
            if (result.warning != null) 'warning': result.warning,
          });
        },
      );

  AITool _calculateCashflowForecast() => AITool(
        name: 'calculate_cashflow_forecast',
        description: 'Projects daily balance forward N days using known recurring transactions, '
            'and flags the lowest point in the forecast window.',
        parameters: {
          'days': const ToolParameter(type: 'number', description: 'Days to project forward', defaultValue: 30),
          'startDate': const ToolParameter(type: 'date', description: 'Usually today'),
        },
        execute: (args) async {
          final txns = await transactionRepository.getAllForUser(userId);
          final recurring = await recurringRepository.getAllForUser(userId);
          final startDate = _parseDate(args['startDate']) ?? DateTime.now();
          final days = (args['days'] as num?)?.toInt() ?? 30;
          final forecast = calculator.calculateCashFlowForecast(
            currentBalance: calculator.calculateCurrentBalance(txns),
            recurringTransactions: recurring,
            startDate: startDate,
            days: days,
          );
          return ToolResult.ok({
            'lowestProjectedBalance': forecast.lowestProjectedBalance,
            'lowestBalanceDate': forecast.lowestBalanceDate?.toIso8601String(),
            'endingBalance': forecast.points.isNotEmpty ? forecast.points.last.projectedBalance : null,
          });
        },
      );

  AITool _calculateSavingsRate() => AITool(
        name: 'calculate_savings_rate',
        description: 'Savings rate (fraction of income not spent) for a given month.',
        parameters: {'month': const ToolParameter(type: 'date', description: 'Any date within the target month', required: true)},
        execute: (args) async {
          final month = _parseDate(args['month']);
          if (month == null) return const ToolResult.fail('A month is required.');
          final txns = await transactionRepository.getAllForUser(userId);
          final income = calculator.calculateMonthlyIncome(txns, month);
          if (income <= 0) return const ToolResult.fail('No income recorded for that month.');
          return ToolResult.ok({'month': _monthLabel(month), 'savingsRate': calculator.calculateSavingsRate(txns, month)});
        },
      );

  // -- Recurring ------------------------------------------------------------

  AITool _getRecurringExpenses() => AITool(
        name: 'get_recurring_expenses',
        description: 'Lists all active recurring expenses (subscriptions, bills, etc).',
        parameters: const {},
        execute: (args) async {
          final recurring = await recurringRepository.getAllForUser(userId);
          final expenses = recurring.where((r) => r.type == TransactionType.expense);
          return ToolResult.ok({
            'recurringExpenses': [
              for (final r in expenses)
                {'id': r.id, 'description': r.description, 'amount': r.amount, 'frequency': r.frequency.name}
            ],
          });
        },
      );

  AITool _calculateRecurringMonthlyTotal() => AITool(
        name: 'calculate_recurring_monthly_total',
        description: 'Net monthly total of all recurring transactions (income minus expenses), normalized to a monthly rate.',
        parameters: const {},
        execute: (args) async {
          final recurring = await recurringRepository.getAllForUser(userId);
          return ToolResult.ok({'monthlyTotal': calculator.calculateRecurringMonthlyTotal(recurring)});
        },
      );

  // -- Analytics --------------------------------------------------------------

  AITool _getTopSpendingCategories() => AITool(
        name: 'get_top_spending_categories',
        description: 'Highest-spend categories for a given month.',
        parameters: {
          'month': const ToolParameter(type: 'date', description: 'Any date within the target month', required: true),
          'limit': const ToolParameter(type: 'number', description: 'How many categories to return', defaultValue: 5),
        },
        execute: (args) async {
          final month = _parseDate(args['month']);
          if (month == null) return const ToolResult.fail('A month is required.');
          final txns = await transactionRepository.getAllForUser(userId);
          final limit = (args['limit'] as num?)?.toInt() ?? 5;
          final top = calculator.topSpendingCategories(txns, month, limit: limit);
          return ToolResult.ok({
            'topCategories': [for (final e in top) {'categoryId': e.key, 'amount': e.value}],
          });
        },
      );

  AITool _getIncomeVsExpense() => AITool(
        name: 'get_income_vs_expense',
        description: 'Income, expenses, and resulting savings for a given month.',
        parameters: {'month': const ToolParameter(type: 'date', description: 'Any date within the target month', required: true)},
        execute: (args) async {
          final month = _parseDate(args['month']);
          if (month == null) return const ToolResult.fail('A month is required.');
          final txns = await transactionRepository.getAllForUser(userId);
          final income = calculator.calculateMonthlyIncome(txns, month);
          final expenses = calculator.calculateMonthlyExpenses(txns, month);
          return ToolResult.ok({'month': _monthLabel(month), 'income': income, 'expenses': expenses, 'savings': income - expenses});
        },
      );

  // -- Search -----------------------------------------------------------------

  AITool _searchTransactions() => AITool(
        name: 'search_transactions',
        description: 'Free-text search over transaction descriptions and notes.',
        parameters: {'query': const ToolParameter(type: 'string', description: 'Search text', required: true)},
        execute: (args) async {
          final query = args['query'] as String?;
          if (query == null || query.trim().isEmpty) return const ToolResult.fail('query is required.');
          final results = await transactionRepository.search(userId, query.trim());
          return ToolResult.ok({
            'results': [
              for (final t in results)
                {'id': t.id, 'description': t.description, 'amount': t.amount, 'date': t.date.toIso8601String()}
            ],
          });
        },
      );

  // -- Helpers ------------------------------------------------------------

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String _monthLabel(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}';
}

extension _FirstOrNullExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
