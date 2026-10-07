import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pesoflow/app/theme/app_colors.dart';
import 'package:pesoflow/app/theme/app_typography.dart';
import 'package:pesoflow/core/formatting/money_formatter.dart';

import 'package:pesoflow/features/transactions/domain/manual_transaction_draft.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/budgets/application/budgets_provider.dart';
import 'package:pesoflow/features/budgets/domain/budget_plan.dart';

Future<void> showBudgetEditor(
  BuildContext context,
  BudgetPlan plan, {
  TransactionCategory? category,
  bool creating = false,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) =>
      _BudgetEditor(plan: plan, initialCategory: category, creating: creating),
);

class _BudgetEditor extends ConsumerStatefulWidget {
  const _BudgetEditor({
    required this.plan,
    required this.initialCategory,
    required this.creating,
  });
  final BudgetPlan plan;
  final TransactionCategory? initialCategory;
  final bool creating;
  @override
  ConsumerState<_BudgetEditor> createState() => _BudgetEditorState();
}

class _BudgetEditorState extends ConsumerState<_BudgetEditor> {
  final form = GlobalKey<FormState>();
  late TransactionCategory? category = widget.initialCategory;
  late final amount = TextEditingController(text: _initialAmount());
  String? error;
  bool saving = false;
  String _initialAmount() {
    final matches = widget.plan.allowances.where((a) => a.category == category);
    final limit = widget.creating
        ? 0
        : category == null
        ? widget.plan.monthlyLimit
        : matches.first.limit;
    return '${limit ~/ 100}.${(limit % 100).toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (saving || !form.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      await ref
          .read(budgetPlansProvider.notifier)
          .setLimit(
            widget.plan.year,
            widget.plan.month,
            category,
            parsePhpAmount(amount.text)!,
          );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => saving = false);
        setState(
          () => error =
              'Could not save the budget. Check your limit and try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = TransactionCategory.values
        .where(
          (c) =>
              isExpenseCategory(c) &&
              (!widget.creating ||
                  !widget.plan.allowances.any((a) => a.category == c)),
        )
        .toList();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.creating ? 'New budget' : 'Edit budget',
                  style: AppTypography.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Monthly limits repeat from their starting month and use your saved transactions.',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.mutedInk,
                  ),
                ),
                const SizedBox(height: 16),
                if (widget.creating)
                  DropdownButtonFormField<String>(
                    key: const ValueKey('budget-category'),
                    isExpanded: true,
                    initialValue: category?.name ?? 'monthly',
                    decoration: const InputDecoration(
                      labelText: 'Allowance',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: 'monthly',
                        child: Text(
                          'Monthly budget',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      for (final c in options)
                        DropdownMenuItem(
                          value: c.name,
                          child: Text(
                            categoryLabel(c),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) => setState(() {
                      category = value == null || value == 'monthly'
                          ? null
                          : TransactionCategory.values.byName(value);
                      error = null;
                    }),
                  )
                else
                  Text(
                    category == null
                        ? 'Monthly budget'
                        : categoryLabel(category!),
                    style: AppTypography.headlineSmall,
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const ValueKey('budget-limit-input'),
                  controller: amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: AppTypography.numericLarge,
                  decoration: const InputDecoration(
                    labelText: 'PHP limit',
                    prefixText: '₱ ',
                    border: OutlineInputBorder(),
                    errorMaxLines: 3,
                  ),
                  validator: (value) => parsePhpAmount(value ?? '') == null
                      ? 'Enter a positive amount with up to 2 decimals.'
                      : null,
                  onChanged: (_) => setState(() => error = null),
                ),
                const SizedBox(height: 8),
                if (category == null)
                  Text(
                    'Category allowances: ${MoneyFormatter.php(widget.plan.allocated)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.mutedInk,
                    ),
                  ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      error!,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.colors.danger,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: saving ? null : save,
                  child: Text(saving ? 'Saving…' : 'Save budget'),
                ),
                if (!widget.creating)
                  TextButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Delete this budget?'),
                          content: const Text('Transactions remain unchanged.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(c, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(c, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true) return;
                      try {
                        await ref
                            .read(budgetPlansProvider.notifier)
                            .remove(category);
                        if (context.mounted) Navigator.pop(context);
                      } catch (_) {
                        if (mounted) {
                          setState(
                            () => error = 'Could not delete. Please try again.',
                          );
                        }
                      }
                    },
                    child: const Text('Delete budget'),
                  ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
