import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_utils.dart';
import '../tools/ai_tool.dart';
import 'ai_engine.dart';

enum _Intent {
  affordability,
  monthlySpending,
  budgetStatus,
  goalProgress,
  savingsHelp,
  balance,
  recurring,
  unknown,
}

/// Fully offline, deterministic stand-in for the bundled on-device SLM.
///
/// It implements the same [AIEngine] contract the real transformer model
/// will implement (PRD 6.1/6.4: IntentDetector + ToolRouter), so the rest of
/// the app — orchestrator, chat UI, response validation — is already wired
/// for the real model and needs no changes when it's swapped in. Because it
/// never invents numbers (every figure it prints comes straight out of
/// `toolResults`), it also satisfies the "never fabricate financial data"
/// rule in the system prompt template by construction, not by hoping the
/// model behaves.
class RuleBasedAIEngine implements AIEngine {
  @override
  Future<bool> get isReady async => true;

  @override
  Future<AIEngineDecision> planToolCalls({
    required String userMessage,
    required List<AITool> availableTools,
    required List<AIEngineMessage> conversationHistory,
  }) async {
    final intent = _detectIntent(userMessage);
    final now = DateTime.now();
    final amount = _extractAmount(userMessage);

    switch (intent) {
      case _Intent.affordability:
        if (amount == null) {
          // Defaulting a missing amount to 0 used to mean "Can I afford
          // something?" silently got answered as "yes, ₱0 fits" — asking
          // for the amount is the honest answer here.
          return const AIEngineDecision(toolNamesToCall: ['get_current_balance']);
        }
        return AIEngineDecision(
          toolNamesToCall: const ['calculate_affordable_spending', 'get_current_balance'],
          toolArgs: {
            'calculate_affordable_spending': {
              'proposedAmount': amount,
              'startDate': now.toIso8601String(),
              'endDate': now.add(const Duration(days: 30)).toIso8601String(),
            },
          },
        );
      case _Intent.monthlySpending:
        return AIEngineDecision(
          toolNamesToCall: const ['get_monthly_expenses', 'get_expenses_by_category', 'get_top_spending_categories'],
          toolArgs: {
            'get_monthly_expenses': {'month': now.toIso8601String()},
            'get_expenses_by_category': {'month': now.toIso8601String()},
            'get_top_spending_categories': {'month': now.toIso8601String(), 'limit': 3},
          },
        );
      case _Intent.budgetStatus:
        return AIEngineDecision(
          toolNamesToCall: const ['get_budget_status'],
          toolArgs: {
            'get_budget_status': {'month': now.toIso8601String()},
          },
        );
      case _Intent.goalProgress:
        return const AIEngineDecision(toolNamesToCall: ['get_all_goals']);
      case _Intent.savingsHelp:
        return AIEngineDecision(
          toolNamesToCall: const ['calculate_savings_rate', 'get_top_spending_categories'],
          toolArgs: {
            'calculate_savings_rate': {'month': now.toIso8601String()},
            'get_top_spending_categories': {'month': now.toIso8601String(), 'limit': 3},
          },
        );
      case _Intent.balance:
        return const AIEngineDecision(toolNamesToCall: ['get_current_balance', 'get_account_balances']);
      case _Intent.recurring:
        return const AIEngineDecision(toolNamesToCall: ['get_recurring_expenses', 'calculate_recurring_monthly_total']);
      case _Intent.unknown:
        return const AIEngineDecision(toolNamesToCall: ['get_current_balance']);
    }
  }

  @override
  Future<String> generateResponse({
    required String userMessage,
    required Map<String, Map<String, dynamic>> toolResults,
    required List<AIEngineMessage> conversationHistory,
  }) async {
    final intent = _detectIntent(userMessage);

    switch (intent) {
      case _Intent.affordability:
        return _affordabilityResponse(toolResults);
      case _Intent.monthlySpending:
        return _monthlySpendingResponse(toolResults);
      case _Intent.budgetStatus:
        return _budgetStatusResponse(toolResults);
      case _Intent.goalProgress:
        return _goalProgressResponse(toolResults);
      case _Intent.savingsHelp:
        return _savingsResponse(toolResults);
      case _Intent.balance:
        return _balanceResponse(toolResults);
      case _Intent.recurring:
        return _recurringResponse(toolResults);
      case _Intent.unknown:
        return "I can help with balance, spending, budgets, goals, and affordability questions. "
            'Try something like "Can I afford ₱2,000 this weekend?" or "Where did I spend the most this month?"';
    }
  }

  // -- Intent detection (PRD 6.4 IntentDetector, extended slightly) --------

  _Intent _detectIntent(String raw) {
    final q = raw.toLowerCase();
    final hasSpend = q.contains('spend') || q.contains('buy') || q.contains('purchase');
    if (hasSpend && (q.contains('afford') || q.contains('can i'))) return _Intent.affordability;
    if (hasSpend && (q.contains('month') || q.contains('where'))) return _Intent.monthlySpending;
    if (q.contains('budget')) return _Intent.budgetStatus;
    if (q.contains('goal') || q.contains('saving for')) return _Intent.goalProgress;
    if (q.contains('save') || q.contains('savings rate')) return _Intent.savingsHelp;
    if (q.contains('balance') || q.contains('how much do i have')) return _Intent.balance;
    if (q.contains('subscription') || q.contains('recurring') || q.contains('bills')) return _Intent.recurring;
    return _Intent.unknown;
  }

  /// Pulls the first currency-like number out of the message, e.g.
  /// "Can I spend 2000 this weekend?" -> 2000.0, "₱1,500" -> 1500.0.
  double? _extractAmount(String raw) {
    final match = RegExp(r'[\d,]+(\.\d+)?').firstMatch(raw.replaceAll('₱', '').replaceAll('\$', ''));
    if (match == null) return null;
    return double.tryParse(match.group(0)!.replaceAll(',', ''));
  }

  // -- Response templates ---------------------------------------------------
  // Every value interpolated below is read directly from `toolResults` —
  // nothing here is invented, per the system prompt's anti-hallucination rule.

  String _affordabilityResponse(Map<String, Map<String, dynamic>> results) {
    final affordability = results['calculate_affordable_spending'];
    if (affordability == null) return "I couldn't check that — try asking again with an amount, like \"Can I afford ₱2,000?\"";
    final canAfford = affordability['canAfford'] as bool? ?? false;
    final before = (affordability['projectedBalanceBeforePurchase'] as num?)?.toDouble() ?? 0;
    final after = (affordability['projectedBalanceAfterPurchase'] as num?)?.toDouble() ?? 0;
    final recurring = (affordability['upcomingRecurringExpenses'] as num?)?.toDouble() ?? 0;
    final warning = affordability['warning'] as String?;

    final buffer = StringBuffer();
    buffer.writeln(canAfford ? 'Yes, that looks affordable.' : 'That would be tight — probably not right now.');
    buffer.writeln();
    buffer.writeln('Upcoming recurring expenses: ${CurrencyFormatter.format(recurring)}');
    buffer.writeln('Projected balance before this purchase: ${CurrencyFormatter.format(before)}');
    buffer.writeln('Projected balance after: ${CurrencyFormatter.format(after)}');
    if (warning != null) {
      buffer.writeln();
      buffer.write(warning);
    }
    return buffer.toString().trim();
  }

  String _monthlySpendingResponse(Map<String, Map<String, dynamic>> results) {
    final expenses = results['get_monthly_expenses'];
    final top = results['get_top_spending_categories'];
    if (expenses == null) return "I don't have enough transaction data to answer that yet.";
    final total = (expenses['expenses'] as num?)?.toDouble() ?? 0;
    final buffer = StringBuffer('You\'ve spent ${CurrencyFormatter.format(total)} this month so far.');
    final topCategories = top?['topCategories'] as List?;
    if (topCategories != null && topCategories.isNotEmpty) {
      buffer.writeln();
      buffer.writeln();
      buffer.writeln('Top categories:');
      for (final c in topCategories) {
        buffer.writeln('• Category #${c['categoryId']}: ${CurrencyFormatter.format((c['amount'] as num).toDouble())}');
      }
    }
    return buffer.toString().trim();
  }

  String _budgetStatusResponse(Map<String, Map<String, dynamic>> results) {
    final status = results['get_budget_status'];
    if (status == null || status.containsKey('error')) {
      return "You don't have an active budget set up for this period yet.";
    }
    final spent = (status['spent'] as num).toDouble();
    final total = (status['totalBudget'] as num).toDouble();
    final remaining = (status['remaining'] as num).toDouble();
    final pct = ((status['percentUsed'] as num).toDouble() * 100).round();
    final over = remaining < 0;
    return "You've used $pct% of your ${status['budgetName']} budget "
        '(${CurrencyFormatter.format(spent)} of ${CurrencyFormatter.format(total)}). '
        '${over ? 'You are ${CurrencyFormatter.format(remaining.abs())} over budget.' : '${CurrencyFormatter.format(remaining)} remaining.'}';
  }

  String _goalProgressResponse(Map<String, Map<String, dynamic>> results) {
    final data = results['get_all_goals'];
    final goals = data?['goals'] as List?;
    if (goals == null || goals.isEmpty) return "You don't have any active goals set up yet.";
    final buffer = StringBuffer('Here\'s where your goals stand:\n');
    for (final g in goals) {
      final pct = ((g['progressPercentage'] as num).toDouble() * 100).round();
      buffer.writeln(
          '• ${g['name']}: ${CurrencyFormatter.format((g['currentAmount'] as num).toDouble())} of ${CurrencyFormatter.format((g['targetAmount'] as num).toDouble())} ($pct%)');
    }
    return buffer.toString().trim();
  }

  String _savingsResponse(Map<String, Map<String, dynamic>> results) {
    final rate = results['calculate_savings_rate'];
    if (rate == null || rate.containsKey('error')) return "I don't have enough income data yet to calculate a savings rate.";
    final pct = ((rate['savingsRate'] as num).toDouble() * 100).round();
    final top = results['get_top_spending_categories']?['topCategories'] as List?;
    final buffer = StringBuffer("You're saving about $pct% of your income this month.");
    if (top != null && top.isNotEmpty) {
      buffer.writeln();
      buffer.write('Your biggest expense categories right now might be the best place to look for more room.');
    }
    return buffer.toString();
  }

  String _balanceResponse(Map<String, Map<String, dynamic>> results) {
    final balance = results['get_current_balance'];
    if (balance == null) return "I don't have any transaction data yet.";
    return 'Your current available balance is ${CurrencyFormatter.format((balance['balance'] as num).toDouble())}.';
  }

  String _recurringResponse(Map<String, Map<String, dynamic>> results) {
    final total = results['calculate_recurring_monthly_total'];
    final list = results['get_recurring_expenses']?['recurringExpenses'] as List?;
    if (total == null) return "You don't have any recurring transactions set up yet.";
    final monthly = (total['monthlyTotal'] as num).toDouble();
    final buffer = StringBuffer(
        'Your recurring transactions net to about ${CurrencyFormatter.format(monthly)} per month.');
    if (list != null && list.isNotEmpty) {
      buffer.writeln();
      buffer.writeln();
      buffer.writeln('Recurring expenses:');
      for (final r in list) {
        buffer.writeln('• ${r['description']}: ${CurrencyFormatter.format((r['amount'] as num).toDouble())} (${r['frequency']})');
      }
    }
    return buffer.toString().trim();
  }
}

// Small helper kept local since it's only used for the greeting header,
// which the chat screen builds separately from this engine.
String greetingForNow(DateTime now) {
  final hour = now.hour;
  if (hour < 12) return 'Good morning';
  if (hour < 18) return 'Good afternoon';
  return 'Good evening';
}

// Referenced by tests to keep month-key formatting consistent with the
// tools registry without duplicating the logic there.
String monthKey(DateTime d) => AppDateUtils.startOfMonth(d).toIso8601String();
