import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/domain/entities/financial_goal.dart';
import '../../../../shared/presentation/providers/app_providers.dart';
import '../../../../shared/presentation/widgets/amount_input.dart';
import '../providers/goals_provider.dart';

/// Create a financial goal (PRD wireframe 9.2 screen 6 / 9.7). Target date
/// is optional — without one, the goal still tracks progress, it just
/// won't have a suggested monthly contribution (that calculation needs a
/// deadline; see FinancialCalculator.calculateRequiredMonthlySavings).
class AddGoalScreen extends ConsumerStatefulWidget {
  const AddGoalScreen({super.key});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController(text: '0');
  DateTime? _targetDate;
  bool _saving = false;
  String? _nameError;
  String? _targetError;

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        centerTitle: true,
        title: const Text('New Goal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('What are you saving for?', style: AppTypography.supporting.copyWith(color: palette.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: 'e.g. Emergency Fund', errorText: _nameError),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            Text('Target amount', style: AppTypography.supporting.copyWith(color: palette.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            AmountInput(controller: _targetController, errorText: _targetError),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            Text('Already saved (optional)', style: AppTypography.supporting.copyWith(color: palette.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            AmountInput(controller: _currentController),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            Text('Target date (optional)', style: AppTypography.supporting.copyWith(color: palette.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.md),
                decoration:
                    BoxDecoration(color: palette.surfaceVariant, borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_targetDate != null ? DateFormat.yMMMd().format(_targetDate!) : 'No target date set'),
                    if (_targetDate != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _targetDate = null),
                      )
                    else
                      Icon(Icons.calendar_today, size: 18, color: palette.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Goal'),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final target = double.tryParse(_targetController.text.trim());
    final current = double.tryParse(_currentController.text.trim()) ?? 0;

    setState(() {
      _nameError = name.isEmpty ? 'Give this goal a name' : null;
      _targetError = (target == null || target <= 0) ? 'Enter a valid target amount' : null;
    });
    if (_nameError != null || _targetError != null) return;

    setState(() => _saving = true);

    final userId = ref.read(currentUserIdProvider);
    final now = DateTime.now();
    final goal = FinancialGoal(
      userId: userId,
      name: name,
      targetAmount: target!,
      currentAmount: current,
      targetDate: _targetDate,
      createdAt: now,
      updatedAt: now,
    );

    await ref.read(goalRepositoryProvider).create(goal);
    ref.invalidate(goalsProvider);

    if (mounted) Navigator.of(context).pop();
  }
}
