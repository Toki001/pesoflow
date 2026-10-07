import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/formatting/money_formatter.dart';
import '../../demo_workspace/application/demo_workspace_providers.dart';
import '../../transactions/domain/manual_transaction_draft.dart';
import '../../transactions/domain/transaction.dart';
import '../application/budgets_provider.dart';
import '../domain/budget_plan.dart';

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

  void save() {
    if (!form.currentState!.validate()) return;
    try {
      ref
          .read(demoBudgetPlansProvider.notifier)
          .setLimit(
            widget.plan.year,
            widget.plan.month,
            category,
            parsePhpAmount(amount.text)!,
          );
      Navigator.pop(context);
    } on ArgumentError catch (e) {
      setState(() => error = e.message.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = TransactionCategory.values
        .where(
          (c) =>
              ![
                TransactionCategory.transfer,
                TransactionCategory.income,
                TransactionCategory.refund,
              ].contains(c) &&
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
                  ref.watch(demoPersistenceEnabledProvider)
                      ? 'Demo budget plans are saved on this device.'
                      : 'Changes apply to this demo session only.',
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
                FilledButton(onPressed: save, child: const Text('Save budget')),
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
