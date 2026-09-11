import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/domain/entities/budget.dart';
import '../../../../shared/domain/entities/enums.dart';
import '../../../../shared/presentation/providers/app_providers.dart';
import '../../../../shared/presentation/widgets/amount_input.dart';
import '../../../categories/presentation/categories_provider.dart';
import '../providers/budgets_provider.dart';

/// Create a monthly budget (PRD wireframe 9.6 / onboarding screen 5), with
/// optional per-category limits. Always scoped to the current calendar
/// month — creating a budget for a different period isn't exposed in this
/// screen yet, though `BudgetRepository.create` already supports it.
class AddBudgetScreen extends ConsumerStatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  late final TextEditingController _nameController;
  final _totalController = TextEditingController();
  final Map<int, TextEditingController> _categoryControllers = {};
  bool _saving = false;
  String? _totalError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: DateFormat.yMMMM().format(DateTime.now()));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalController.dispose();
    for (final c in _categoryControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(int categoryId) {
    return _categoryControllers.putIfAbsent(categoryId, () => TextEditingController());
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final palette = context.appColors;

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        centerTitle: true,
        title: const Text('Create Budget'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Budget name', style: AppTypography.supporting.copyWith(color: palette.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            TextField(controller: _nameController),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            Text('Total monthly budget', style: AppTypography.supporting.copyWith(color: palette.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            AmountInput(controller: _totalController, errorText: _totalError),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            Text('Category limits (optional)', style: AppTypography.supporting.copyWith(color: palette.textSecondary)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Leave a category blank to skip setting a limit for it.',
              style: AppTypography.caption.copyWith(color: palette.textTertiary),
            ),
            const SizedBox(height: AppSpacing.md),
            categoriesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: LinearProgressIndicator(),
              ),
              error: (e, _) => Text('Error loading categories: $e'),
              data: (categories) {
                final expenseCategories = categories.where((c) => c.type == CategoryType.expense).toList();
                return Column(
                  children: [
                    for (final category in expenseCategories)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          children: [
                            Expanded(child: Text(category.name, style: AppTypography.body)),
                            SizedBox(
                              width: 120,
                              child: TextField(
                                controller: _controllerFor(category.id!),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.right,
                                decoration: const InputDecoration(hintText: '0', isDense: true),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Budget'),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final total = double.tryParse(_totalController.text.trim());
    if (total == null || total <= 0) {
      setState(() => _totalError = 'Enter a valid amount');
      return;
    }

    setState(() {
      _saving = true;
      _totalError = null;
    });

    final userId = ref.read(currentUserIdProvider);
    final now = DateTime.now();
    final budget = Budget(
      userId: userId,
      name: _nameController.text.trim().isEmpty ? DateFormat.yMMMM().format(now) : _nameController.text.trim(),
      type: BudgetType.monthly,
      periodStart: AppDateUtils.startOfMonth(now),
      periodEnd: AppDateUtils.endOfMonth(now),
      totalBudget: total,
      strategy: BudgetStrategy.zeroBased,
      createdAt: now,
      updatedAt: now,
    );

    // budgetId here is a placeholder — BudgetRepositoryImpl.create assigns
    // the real, freshly-inserted budget's id to every item itself.
    final items = <BudgetItem>[];
    for (final entry in _categoryControllers.entries) {
      final amount = double.tryParse(entry.value.text.trim());
      if (amount == null || amount <= 0) continue;
      items.add(BudgetItem(
        budgetId: 0,
        categoryId: entry.key,
        amount: amount,
        createdAt: now,
        updatedAt: now,
      ));
    }

    await ref.read(budgetRepositoryProvider).create(budget, items);
    ref.invalidate(activeBudgetProvider);

    if (mounted) Navigator.of(context).pop();
  }
}
