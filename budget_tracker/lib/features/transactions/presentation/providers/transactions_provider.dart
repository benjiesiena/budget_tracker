import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/domain/entities/transaction.dart';
import '../../../../shared/presentation/providers/app_providers.dart';

/// Loads and holds all transactions for the current user. Kept as a single
/// flat list (not paginated) for now — see PRD 15.2 memory targets; a real
/// deployment with years of history would switch this to a paged query, but
/// the [FinancialCalculator] contract (pure functions over a `List<Transaction>`)
/// wouldn't need to change, only how this provider fetches pages.
class TransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    final repo = ref.watch(transactionRepositoryProvider);
    final userId = ref.watch(currentUserIdProvider);
    return repo.getAllForUser(userId);
  }

  Future<void> addTransaction(Transaction transaction) async {
    final repo = ref.read(transactionRepositoryProvider);
    await repo.create(transaction);
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final repo = ref.read(transactionRepositoryProvider);
    await repo.update(transaction);
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteTransaction(int id) async {
    final repo = ref.read(transactionRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
    await future;
  }
}

final transactionsProvider = AsyncNotifierProvider<TransactionsNotifier, List<Transaction>>(
  TransactionsNotifier.new,
);
