import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/presentation/widgets/empty_state.dart';
import '../../../categories/presentation/categories_provider.dart';
import '../providers/transactions_provider.dart';
import '../widgets/transaction_row.dart';
import 'add_transaction_screen.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
        ],
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Couldn\'t load transactions: $e')),
        data: (transactions) {
          final categories = categoriesAsync.valueOrNull ?? [];
          final filtered = _query.isEmpty
              ? transactions
              : transactions
                  .where((t) => (t.description ?? '').toLowerCase().contains(_query.toLowerCase()))
                  .toList();

          if (transactions.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No transactions yet',
              message: 'Add your first transaction to start tracking your spending.',
              actionLabel: 'Add Transaction',
              onAction: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
              ),
            );
          }

          final grouped = <String, List<dynamic>>{};
          for (final t in filtered) {
            final key = DateFormat.yMMMM().format(t.date);
            grouped.putIfAbsent(key, () => []).add(t);
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    for (final group in grouped.entries) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        child: Text(
                          group.key,
                          style: AppTypography.supporting.copyWith(color: context.appColors.textSecondary),
                        ),
                      ),
                      for (final t in group.value)
                        TransactionRow(
                          transaction: t,
                          category: categories.where((c) => c.id == t.categoryId).firstOrNull,
                        ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

extension _FirstOrNullExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
