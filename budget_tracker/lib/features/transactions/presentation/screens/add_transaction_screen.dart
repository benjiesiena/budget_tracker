import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/domain/entities/transaction.dart';
import '../../../../shared/domain/entities/enums.dart';
import '../../../../shared/domain/entities/category.dart';
import '../../../../shared/presentation/providers/app_providers.dart';
import '../../../../shared/presentation/widgets/amount_input.dart';
import '../../../accounts/presentation/accounts_provider.dart';
import '../../../categories/presentation/categories_provider.dart';
import '../providers/transactions_provider.dart';

/// Add/edit transaction screen (PRD wireframe 9.5). A single screen handles
/// both create and edit — pass an existing [initial] transaction to edit it.
class AddTransactionScreen extends ConsumerStatefulWidget {
  final Transaction? initial;

  const AddTransactionScreen({super.key, this.initial});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  late TransactionType _type;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now();
  int? _categoryId;
  int? _accountId;
  bool _saving = false;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    _type = t?.type ?? TransactionType.expense;
    _amountController.text = t != null ? t.amount.toStringAsFixed(0) : '';
    _descriptionController.text = t?.description ?? '';
    _notesController.text = t?.notes ?? '';
    _date = t?.date ?? DateTime.now();
    _categoryId = t?.categoryId;
    _accountId = t?.accountId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final accountsAsync = ref.watch(accountsProvider);
    final isEditing = widget.initial != null;

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        centerTitle: true,
        title: Text(isEditing ? 'Edit ${_typeLabel(_type)}' : 'Add ${_typeLabel(_type)}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(value: TransactionType.expense, label: Text('Expense')),
                ButtonSegment(value: TransactionType.income, label: Text('Income')),
                ButtonSegment(value: TransactionType.transfer, label: Text('Transfer')),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() {
                _type = s.first;
                _categoryId = null;
              }),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            Text('Amount', style: AppTypography.supporting.copyWith(color: context.appColors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            AmountInput(controller: _amountController, errorText: _amountError),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            Text('Category', style: AppTypography.supporting.copyWith(color: context.appColors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            categoriesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error loading categories: $e'),
              data: (categories) {
                final relevant = categories.where((c) => c.type.dbValue == _type.dbValue).toList();
                _categoryId ??= relevant.isNotEmpty ? relevant.first.id : null;
                return _picker<Category>(
                  value: relevant.where((c) => c.id == _categoryId).firstOrNull,
                  items: relevant,
                  labelOf: (c) => c.name,
                  onSelect: (c) => setState(() => _categoryId = c.id),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            Text('Description', style: AppTypography.supporting.copyWith(color: context.appColors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            TextField(controller: _descriptionController, decoration: const InputDecoration(hintText: 'e.g. Lunch')),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            Text('Date', style: AppTypography.supporting.copyWith(color: context.appColors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.md),
                decoration: BoxDecoration(color: context.appColors.surfaceVariant, borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat.yMMMd().format(_date)),
                    Icon(Icons.calendar_today, size: 18, color: context.appColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            Text('Account', style: AppTypography.supporting.copyWith(color: context.appColors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            accountsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error loading accounts: $e'),
              data: (accounts) {
                _accountId ??= accounts.isNotEmpty ? accounts.first.id : null;
                return _picker(
                  value: accounts.where((a) => a.id == _accountId).firstOrNull,
                  items: accounts,
                  labelOf: (a) => a.name,
                  onSelect: (a) => setState(() => _accountId = a.id),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(hintText: 'Add notes (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Save ${_typeLabel(_type)}'),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _picker<T>({
    required T? value,
    required List<T> items,
    required String Function(T) labelOf,
    required ValueChanged<T> onSelect,
  }) {
    return InkWell(
      onTap: items.isEmpty
          ? null
          : () async {
              final selected = await showModalBottomSheet<T>(
                context: context,
                builder: (ctx) => SafeArea(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final item in items)
                        ListTile(title: Text(labelOf(item)), onTap: () => Navigator.pop(ctx, item)),
                    ],
                  ),
                ),
              );
              if (selected != null) onSelect(selected);
            },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.md),
        decoration: BoxDecoration(color: context.appColors.surfaceVariant, borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value != null ? labelOf(value) : (items.isEmpty ? 'None available' : 'Select')),
            Icon(Icons.chevron_right, color: context.appColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _amountError = 'Enter a valid amount');
      return;
    }
    if (_categoryId == null || _accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category and account.')),
      );
      return;
    }

    setState(() {
      _saving = true;
      _amountError = null;
    });

    final userId = ref.read(currentUserIdProvider);
    final now = DateTime.now();
    final transaction = Transaction(
      id: widget.initial?.id,
      userId: userId,
      accountId: _accountId!,
      categoryId: _categoryId!,
      type: _type,
      amount: amount,
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      date: _date,
      createdAt: widget.initial?.createdAt ?? now,
      updatedAt: now,
    );

    final notifier = ref.read(transactionsProvider.notifier);
    if (widget.initial != null) {
      await notifier.updateTransaction(transaction);
    } else {
      await notifier.addTransaction(transaction);
    }

    if (mounted) Navigator.of(context).pop();
  }

  String _typeLabel(TransactionType type) => switch (type) {
        TransactionType.expense => 'Expense',
        TransactionType.income => 'Income',
        TransactionType.transfer => 'Transfer',
      };
}

extension _FirstOrNullExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
