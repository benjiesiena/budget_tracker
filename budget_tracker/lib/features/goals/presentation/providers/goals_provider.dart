import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../../../shared/domain/entities/financial_goal.dart";
import "../../../../shared/presentation/providers/app_providers.dart";

final goalsProvider = FutureProvider<List<FinancialGoal>>((ref) async {
  final repo = ref.watch(goalRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  return repo.getAllForUser(userId);
});
