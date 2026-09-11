import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database_helper.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../data/repositories/goal_repository_impl.dart';
import '../../data/repositories/recurring_transaction_repository_impl.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../domain/repositories/recurring_transaction_repository.dart';
import '../../domain/services/financial_calculator.dart';
import '../../../infrastructure/ai/runtime/ai_config.dart';
import '../../../infrastructure/ai/runtime/ai_engine.dart';
import '../../../infrastructure/ai/runtime/local_llm_ai_engine.dart';
import '../../../infrastructure/ai/runtime/model_download_service.dart';
import '../../../infrastructure/ai/runtime/rule_based_ai_engine.dart';
import '../../../infrastructure/ai/tools/financial_tools_registry.dart';
import '../../../features/ai_assistant/domain/ai_orchestrator.dart';

/// The single-user app operates on a fixed local user row created during
/// onboarding (see PRD 9.2, screen 3). Multi-profile support, if ever
/// added, would swap this out for a "current user" provider backed by a
/// selection screen — everything downstream already reads userId from here.
final currentUserIdProvider = Provider<int>((ref) => 1);

final databaseHelperProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper.instance);

// -- Repositories -----------------------------------------------------------

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepositoryImpl(ref.watch(databaseHelperProvider)),
);

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepositoryImpl(ref.watch(databaseHelperProvider)),
);

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepositoryImpl(ref.watch(databaseHelperProvider)),
);

final budgetRepositoryProvider = Provider<BudgetRepository>(
  (ref) => BudgetRepositoryImpl(ref.watch(databaseHelperProvider)),
);

final goalRepositoryProvider = Provider<GoalRepository>(
  (ref) => GoalRepositoryImpl(ref.watch(databaseHelperProvider)),
);

final recurringRepositoryProvider = Provider<RecurringTransactionRepository>(
  (ref) => RecurringTransactionRepositoryImpl(ref.watch(databaseHelperProvider)),
);

// -- Domain services ----------------------------------------------------

final financialCalculatorProvider = Provider<FinancialCalculator>((ref) => const FinancialCalculator());

// -- AI ---------------------------------------------------------------------

// Model download service provider
final modelDownloadServiceProvider = Provider<ModelDownloadService>((ref) {
  return ModelDownloadService();
});

// Use AIConfig to easily switch between local LLM and rule-based responses
// Set AIConfig.useLocalLLM = true after downloading the model file
final aiEngineProvider = Provider<AIEngine>((ref) {
  if (AIConfig.useLocalLLM) {
    return LocalLLMAIEngine(
      modelFileName: AIConfig.modelFileName,
      contextSize: AIConfig.contextSize,
      nThreads: AIConfig.nThreads,
      downloadService: ref.watch(modelDownloadServiceProvider),
    );
  } else {
    return RuleBasedAIEngine();
  }
});

final financialToolsRegistryProvider = Provider<FinancialToolsRegistry>((ref) {
  return FinancialToolsRegistry(
    userId: ref.watch(currentUserIdProvider),
    transactionRepository: ref.watch(transactionRepositoryProvider),
    accountRepository: ref.watch(accountRepositoryProvider),
    budgetRepository: ref.watch(budgetRepositoryProvider),
    goalRepository: ref.watch(goalRepositoryProvider),
    recurringRepository: ref.watch(recurringRepositoryProvider),
    calculator: ref.watch(financialCalculatorProvider),
  );
});

final aiOrchestratorProvider = Provider<AIOrchestrator>((ref) {
  return AIOrchestrator(
    engine: ref.watch(aiEngineProvider),
    toolsRegistry: ref.watch(financialToolsRegistryProvider),
  );
});
