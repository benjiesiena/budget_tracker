import 'package:flutter_test/flutter_test.dart';

import 'package:budget_tracker/shared/domain/entities/transaction.dart';
import 'package:budget_tracker/shared/domain/entities/enums.dart';
import 'package:budget_tracker/infrastructure/ai/tools/financial_tools_registry.dart';
import 'package:budget_tracker/infrastructure/ai/runtime/rule_based_ai_engine.dart';
import 'package:budget_tracker/features/ai_assistant/domain/ai_orchestrator.dart';

import 'financial_tools_registry_test.dart';

/// End-to-end pipeline test: real tools + real engine + real orchestrator,
/// asking a question in plain English and checking the final chat text.
///
/// This is deliberately not a unit test of any single piece — it exists
/// because a bug where the orchestrator stored each tool's full
/// {success, data, error} envelope instead of unwrapping `data` slipped
/// past every other test: the calculator tests never touched the
/// orchestrator, and the tools-registry tests checked ToolResult objects
/// directly rather than what the orchestrator did with them afterward.
/// Only a full run of "ask a question, read the reply" caught it.
void main() {
  test('affordability answer reflects the real balance, not a silently-defaulted zero', () async {
    final txns = [
      Transaction(
        userId: 1,
        accountId: 1,
        categoryId: 1,
        type: TransactionType.income,
        amount: 7500,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final registry = FinancialToolsRegistry(
      userId: 1,
      transactionRepository: FakeTransactionRepository(txns),
      accountRepository: FakeAccountRepository(),
      budgetRepository: FakeBudgetRepository(),
      goalRepository: FakeGoalRepository([]),
      recurringRepository: FakeRecurringRepository([]),
    );

    final orchestrator = AIOrchestrator(engine: RuleBasedAIEngine(), toolsRegistry: registry);

    final reply = await orchestrator.sendMessage(
      userMessage: 'Can I afford to spend 2000 pesos this weekend?',
      conversationId: 1,
      history: const [],
    );

    // The bug produced "₱0" for both before/after balances regardless of
    // actual data. With a real 7,500 balance and no recurring expenses, a
    // 2,000 purchase should clearly be affordable and should quote 7,500
    // and 5,500 somewhere in the reply — not zero.
    expect(reply.content, isNot(contains('₱0.00')));
    expect(reply.content.toLowerCase(), contains('yes'));
  });
}
