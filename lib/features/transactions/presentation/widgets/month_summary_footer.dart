import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/utils/app_utils.dart';
import '../controllers/budget_provider.dart';
import '../controllers/monthly_expense_provider.dart';
import '../formatters/formatters.dart';

class MonthSummaryFooter extends ConsumerWidget {
  const MonthSummaryFooter({super.key, required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final budgetAsync = ref.watch(budgetForMonthProvider(month));
    final expensesAsync = ref.watch(monthExpenseOnlyProvider(month));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: budgetAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (e, _) => Text('Error: $e', style: TextStyle(color: cs.error)),
        data: (budget) {
          return expensesAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (e, _) =>
                Text('Error: $e', style: TextStyle(color: cs.error)),
            data: (expenseOnly) {
              final remaining = budget == null ? null : (budget - expenseOnly);
              final hasBudget = budget != null;

              return Column(
                children: [
                  _SummaryRow(
                    label: 'Budget:',
                    value: hasBudget ? fmtMoneyCompact(budget) : '-',
                  ),
                  const SizedBox(height: 4),
                  _SummaryRow(
                    label: 'Spent:',
                    value: fmtMoneyCompact(expenseOnly),
                  ),
                  const SizedBox(height: 4),
                  _SummaryRow(
                    label: 'Remaining:',
                    value: remaining == null ? '-' : fmtMoneyCompact(remaining),
                    valueColor: remaining == null
                        ? null
                        : (remaining >= 0 ? Colors.green : Colors.red),
                    isBold: true,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hasBudget
                            ? "Budget Set"
                            : "No Budget Set",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      IconButton(
                        tooltip: budget == null
                            ? "Set Budget"
                            : "Edit Budget",
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () =>
                            editBudgetDialog(context, ref, month, budget),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodyMedium),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            color: valueColor,
            fontWeight: isBold ? FontWeight.bold : null,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
