import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/theme/app_spacing.dart";
import "../../../../core/utils/currency_formatter.dart";
import "../../../../shared/domain/entities/transaction.dart";
import "../../../../shared/domain/entities/enums.dart";
import "../../../../shared/domain/entities/category.dart";
import "../../../../shared/presentation/widgets/category_icon.dart";
import "category_icon_mapper.dart";

/// One row in the transaction list (PRD screen 9.4). 64px tall, icon on
/// left, description/date in the middle, signed amount on the right.
class TransactionRow extends StatelessWidget {
  final Transaction transaction;
  final Category? category;
  final VoidCallback? onTap;

  const TransactionRow({super.key, required this.transaction, this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final isExpense = transaction.type == TransactionType.expense;
    final amountColor = transaction.type == TransactionType.income ? palette.positive : palette.textPrimary;
    final sign = transaction.type == TransactionType.income ? "+" : (isExpense ? "-" : "");

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: palette.divider)),
        ),
        child: Row(
          children: [
            CategoryIconWidget(
              icon: iconForCategory(category?.icon),
              color: colorFromHex(category?.color) ?? palette.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    transaction.description?.isNotEmpty == true ? transaction.description! : (category?.name ?? "Transaction"),
                    style: AppTypography.body,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    DateFormat("MMM d").format(transaction.date),
                    style: AppTypography.caption.copyWith(color: palette.textTertiary),
                  ),
                ],
              ),
            ),
            Text(
              "$sign${CurrencyFormatter.format(transaction.amount)}",
              style: AppTypography.body.copyWith(color: amountColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
