import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:pesoflow/app/theme/app_colors.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/core/time/clock.dart';
import 'package:pesoflow/features/accounts/domain/financial_account.dart';
import 'package:pesoflow/features/accounts/presentation/manual_account_editor.dart';
import 'package:pesoflow/app/theme/app_typography.dart';
import 'package:pesoflow/core/formatting/money_formatter.dart';
import 'package:pesoflow/core/widgets/budget_progress_bar.dart';
import 'package:pesoflow/core/widgets/category_icon.dart';
import 'package:pesoflow/core/widgets/finance_card.dart';
import 'package:pesoflow/core/widgets/task_screen.dart';

import 'package:pesoflow/features/transactions/application/transactions_provider.dart';
import 'package:pesoflow/features/budgets/application/budgets_provider.dart';

import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/transactions/domain/transaction_query.dart';
import 'package:pesoflow/features/transactions/domain/manual_transaction_draft.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({this.transaction, super.key});
  final TransactionRecord? transaction;
  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final amount = TextEditingController();
  final merchant = TextEditingController();
  final note = TextEditingController();
  final amountFocus = FocusNode();
  final formKey = GlobalKey<FormState>();
  TransactionKind kind = TransactionKind.expense;
  TransactionCategory category = TransactionCategory.food;
  String accountId = '';
  String destinationId = '';
  String get account => accounts[accountId]?.$1 ?? 'Choose account';
  String get destination => accounts[destinationId]?.$1 ?? 'Choose account';
  late DateTime date;
  bool saving = false;
  Map<String, (String, int)> get accounts {
    final w = ref.read(workspaceProvider);
    return {
      for (final a in w.accounts.where(
        (a) => !a.archived && a.source == BalanceSource.manual,
      ))
        a.id: (
          a.name,
          accountBalance(
            a,
            w.ledger.where(
              (t) => !t.occurredAt.isAfter(ref.read(clockProvider)()),
            ),
          ),
        ),
    };
  }

  static const categories = [
    (TransactionCategory.food, Icons.restaurant),
    (TransactionCategory.groceries, Icons.shopping_basket_outlined),
    (TransactionCategory.transport, Icons.directions_car_outlined),
    (TransactionCategory.shopping, Icons.shopping_bag_outlined),
    (TransactionCategory.bills, Icons.receipt_long_outlined),
    (TransactionCategory.subscriptions, Icons.subscriptions_outlined),
  ];
  String get typeLabel => switch (kind) {
    TransactionKind.expense => 'Expense',
    TransactionKind.income => 'Income',
    TransactionKind.transfer => 'Transfer',
    _ => 'Expense',
  };
  @override
  void initState() {
    super.initState();
    date = ref.read(clockProvider)();
    if (accounts.isNotEmpty) accountId = accounts.keys.first;
    if (accounts.length > 1) destinationId = accounts.keys.elementAt(1);
    final original = widget.transaction;
    if (original != null) {
      amount.text =
          '${original.amount ~/ 100}.${(original.amount % 100).toString().padLeft(2, '0')}';
      merchant.text = original.merchant;
      note.text = original.note;
      kind = original.kind;
      category = original.category;
      accountId = original.accountId ?? '';
      destinationId = original.destinationAccountId ?? '';
      date = original.occurredAt;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ScaffoldMessenger.of(context).removeCurrentSnackBar();
    });
  }

  @override
  void dispose() {
    amount.dispose();
    merchant.dispose();
    note.dispose();
    amountFocus.dispose();
    super.dispose();
  }

  void reset() => setState(() {
    formKey.currentState?.reset();
    amount.text = '0.00';
    merchant.clear();
    note.clear();
    category = TransactionCategory.food;
    accountId = accounts.keys.firstOrNull ?? '';
    destinationId =
        accounts.keys.where((id) => id != accountId).firstOrNull ?? '';
    date = ref.read(clockProvider)();
  });
  void increment(int centavos) => setState(() {
    final value = (parsePhpAmount(amount.text) ?? 0) + centavos;
    amount.text = '${value ~/ 100}.${(value % 100).toString().padLeft(2, '0')}';
  });
  Future<void> pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030, 12, 31),
    );
    if (selected == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(date),
    );
    if (time != null && mounted) {
      setState(
        () => date = DateTime(
          selected.year,
          selected.month,
          selected.day,
          time.hour,
          time.minute,
        ),
      );
    }
  }

  Future<void> switchAccount({bool receiving = false}) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              receiving ? 'To account' : 'Choose account',
              style: AppTypography.headlineMedium,
            ),
            for (final entry in accounts.entries)
              ListTile(
                title: Text(entry.value.$1),
                subtitle: Text(
                  'Tracked balance: ${MoneyFormatter.php(entry.value.$2)}',
                ),
                onTap: () => Navigator.pop(context, entry.key),
              ),
          ],
        ),
      ),
    );
    if (selected != null && mounted) {
      setState(() {
        if (receiving) {
          destinationId = selected;
        } else {
          accountId = selected;
        }
      });
    }
  }

  Future<void> moreCategories() async {
    final selected = await showModalBottomSheet<TransactionCategory>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final c in TransactionCategory.values.where(
              (c) => kind == TransactionKind.income
                  ? isIncomeCategory(c)
                  : isExpenseCategory(c),
            ))
              ListTile(
                title: Text(categoryLabel(c)),
                trailing: c == category ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, c),
              ),
          ],
        ),
      ),
    );
    if (selected != null && mounted) setState(() => category = selected);
  }

  Future<void> save() async {
    if (saving) return;
    if (!accounts.containsKey(accountId) ||
        (kind == TransactionKind.transfer &&
            !accounts.containsKey(destinationId))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create and select an account first.')),
      );
      return;
    }
    final validFields = formKey.currentState!.validate();
    final parsedAmount = parsePhpAmount(amount.text);
    // ListView can dispose offscreen field states. Validate the draft values too.
    if (parsedAmount == null ||
        (kind != TransactionKind.transfer && merchant.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a positive PHP amount and a merchant or payer.'),
        ),
      );
      return;
    }
    if (!validFields) return;
    if (kind == TransactionKind.transfer && accountId == destinationId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose two different transfer accounts.'),
        ),
      );
      return;
    }
    setState(() => saving = true);
    final draft = ManualTransactionDraft(
      amount: parsedAmount,
      merchant: kind == TransactionKind.transfer ? 'Transfer' : merchant.text,
      account: account,
      accountId: accountId,
      destinationAccount: destination,
      destinationAccountId: destinationId,
      occurredAt: date,
      kind: kind,
      category: category,
      note: note.text,
    );
    try {
      if (widget.transaction case final original?) {
        await ref
            .read(ledgerProvider.notifier)
            .update(
              draft
                  .toRecord(original.id)
                  .copyWith(
                    excludedFromBudget: original.excludedFromBudget,
                    recurring: original.recurring,
                    tags: {
                      ...original.tags,
                      ...draft.toRecord(original.id).tags,
                    }.toList(),
                  ),
            );
      } else {
        await ref.read(ledgerProvider.notifier).createManual(draft);
      }
      if (!mounted) return;
      ref
          .read(transactionQueryProvider.notifier)
          .set(TransactionQuery(year: date.year, month: date.month));
      context.go('/transactions');
    } catch (_) {
      if (mounted) {
        setState(() => saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not save. Your entries are still here; please try again.',
            ),
          ),
        );
      }
    }
  }

  InputDecoration field(String hint, {IconData? icon}) => InputDecoration(
    hintText: hint,
    prefixIcon: icon == null ? null : Icon(icon, size: 20),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: context.colors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: context.colors.border),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final value = parsePhpAmount(amount.text) ?? 0;
    final large = MediaQuery.textScalerOf(context).scale(14) > 19;
    final label = AppTypography.labelMedium;
    final small = AppTypography.bodySmall;
    ref.watch(workspaceProvider);
    ref.watch(ledgerProvider);
    ref.watch(budgetPlansProvider);
    final plan = ref
        .read(budgetPlansProvider.notifier)
        .viewFor(date.year, date.month);
    final matches = plan.allowances.where((a) => a.category == category);
    final budget = matches.isEmpty
        ? (0, 0)
        : (matches.first.spent, matches.first.limit);
    final spent = budget.$1;
    Widget title(String text) => Text(text, style: label);
    Widget quickButton(
      String text,
      VoidCallback onTap, {
      bool selected = false,
    }) => OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected
            ? c.soft(c.primary, AppColors.primarySoft)
            : c.mutedSurface,
        foregroundColor: selected ? c.primary : c.ink,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        textStyle: small,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text),
    );
    return TaskScreen(
      title: '${widget.transaction == null ? 'Add' : 'Edit'} $typeLabel',
      centerTitle: true,
      actions: [TextButton(onPressed: reset, child: const Text('Reset'))],
      footer: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(top: BorderSide(color: c.border)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: saving ? null : save,
            style: FilledButton.styleFrom(
              textStyle: AppTypography.headlineSmall,
            ),
            child: Text(
              'Save $typeLabel — ${MoneyFormatter.php(value)}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      child: accounts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add an account first',
                      style: AppTypography.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Create a manually tracked account before recording transactions.',
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () async {
                        await showManualAccountEditor(context);
                        if (mounted) {
                          setState(() {
                            accountId = accounts.keys.firstOrNull ?? '';
                          });
                        }
                      },
                      child: const Text('Add Manual Account'),
                    ),
                  ],
                ),
              ),
            )
          : Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: c.mutedSurface,
                      border: Border.all(color: c.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        for (final (type, text) in [
                          (TransactionKind.expense, 'Expense'),
                          (TransactionKind.income, 'Income'),
                          (TransactionKind.transfer, 'Transfer'),
                        ])
                          Expanded(
                            child: Semantics(
                              selected: kind == type,
                              button: true,
                              child: TextButton(
                                onPressed: () => setState(() {
                                  kind = type;
                                  category = type == TransactionKind.income
                                      ? TransactionCategory.salary
                                      : TransactionCategory.food;
                                }),
                                style: TextButton.styleFrom(
                                  backgroundColor: kind == type
                                      ? c.surface
                                      : Colors.transparent,
                                  foregroundColor: kind == type
                                      ? c.ink
                                      : c.mutedInk,
                                ),
                                child: Text(text),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FinanceCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'PHILIPPINE PESO (PHP)',
                          style: AppTypography.labelSmall.copyWith(
                            color: c.mutedInk,
                            letterSpacing: .7,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('₱', style: AppTypography.headlineLarge),
                            const SizedBox(width: 8),
                            Flexible(
                              child: SizedBox(
                                width: 200,
                                child: TextFormField(
                                  key: const ValueKey('amount-input'),
                                  controller: amount,
                                  focusNode: amountFocus,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  textAlign: TextAlign.center,
                                  style: AppTypography.display,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    errorMaxLines: 3,
                                  ),
                                  validator: (text) =>
                                      parsePhpAmount(text ?? '') == null
                                      ? 'Enter a positive PHP amount with up to 2 decimals.'
                                      : null,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Enter transaction value',
                          style: small.copyWith(color: c.mutedInk),
                        ),
                        const SizedBox(height: 16),
                        Divider(color: c.border),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            for (final (text, delta) in [
                              ('+₱50', 5000),
                              ('+₱100', 10000),
                              ('+₱500', 50000),
                            ])
                              quickButton(text, () => increment(delta)),
                            quickButton(
                              'Exact',
                              () => amountFocus.requestFocus(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (kind != TransactionKind.transfer) ...[
                    FinanceCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          title(
                            kind == TransactionKind.income
                                ? 'Payer / Source'
                                : 'Merchant / Payee',
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const ValueKey('merchant-input'),
                            controller: merchant,
                            maxLength: 100,
                            style: AppTypography.bodyMedium,
                            decoration: field(
                              'e.g. Jollibee, Grab, SM Store',
                              icon: Icons.storefront_outlined,
                            ).copyWith(counterText: ''),
                            validator: (text) =>
                                text == null || text.trim().isEmpty
                                ? 'Enter a merchant or payer.'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Text(
                                  'Recent:',
                                  style: small.copyWith(color: c.mutedInk),
                                ),
                                const SizedBox(width: 8),
                                for (final name
                                    in ref
                                        .watch(ledgerProvider)
                                        .where((t) => t.kind == kind)
                                        .map((t) => t.merchant)
                                        .toSet()
                                        .take(4))
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: quickButton(
                                      name,
                                      () =>
                                          setState(() => merchant.text = name),
                                      selected: merchant.text == name,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (kind == TransactionKind.income)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: OutlinedButton(
                        onPressed: moreCategories,
                        child: Text(categoryLabel(category)),
                      ),
                    ),
                  if (kind == TransactionKind.expense) ...[
                    FinanceCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: title('Category')),
                              TextButton(
                                onPressed: moreCategories,
                                child: const Text('More categories ›'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final columns = large ? 2 : 3;
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final (item, icon) in categories)
                                    SizedBox(
                                      width:
                                          (constraints.maxWidth -
                                              (columns - 1) * 8) /
                                          columns,
                                      child: Semantics(
                                        selected: category == item,
                                        button: true,
                                        child: Material(
                                          color: category == item
                                              ? c
                                                    .soft(
                                                      c.primary,
                                                      AppColors.primarySoft,
                                                    )
                                                    .withValues(alpha: .3)
                                              : c.surface,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            side: BorderSide(
                                              color: category == item
                                                  ? c.primary
                                                  : c.border,
                                              width: category == item ? 2 : 1,
                                            ),
                                          ),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            onTap: () =>
                                                setState(() => category = item),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 10,
                                                  ),
                                              child: Column(
                                                children: [
                                                  CategoryIcon(
                                                    icon,
                                                    foreground: category == item
                                                        ? c.warning
                                                        : c.secondaryInk,
                                                    background: category == item
                                                        ? c.soft(
                                                            c.warning,
                                                            AppColors
                                                                .warningSoft,
                                                          )
                                                        : c.mutedSurface,
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    item ==
                                                            TransactionCategory
                                                                .bills
                                                        ? 'Bills'
                                                        : categoryLabel(item),
                                                    textAlign: TextAlign.center,
                                                    style: AppTypography
                                                        .labelSmall
                                                        .copyWith(
                                                          color:
                                                              category == item
                                                              ? c.primary
                                                              : c.ink,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          if (budget.$2 > 0)
                            FinanceCard(
                              color: c.canvas,
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Text(
                                        '${categoryLabel(category)} monthly budget',
                                        style: small,
                                      ),
                                      Text(
                                        '${MoneyFormatter.php(spent, decimals: false)} / ${MoneyFormatter.php(budget.$2, decimals: false)}',
                                        style: small.copyWith(
                                          color: c.secondaryInk,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  BudgetProgressBar(
                                    value: spent / budget.$2,
                                    color: spent * 100 >= budget.$2 * 80
                                        ? c.warning
                                        : c.secondary,
                                    label: '${categoryLabel(category)} budget',
                                    height: 8,
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    spacing: 8,
                                    children: [
                                      Text(
                                        '${spent * 100 ~/ budget.$2}% used this cycle',
                                        style: AppTypography.labelSmall
                                            .copyWith(color: c.mutedInk),
                                      ),
                                      Text(
                                        '${MoneyFormatter.php(budget.$2 - spent, decimals: false)} left',
                                        style: AppTypography.labelSmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  FinanceCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: title(
                                kind == TransactionKind.income
                                    ? 'Received Into'
                                    : 'Paid From',
                              ),
                            ),
                            Text(
                              'Manually tracked',
                              style: AppTypography.labelSmall.copyWith(
                                color: c.positive,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FinanceCard(
                          color: c
                              .soft(c.primary, AppColors.primarySoft)
                              .withValues(alpha: .1),
                          borderColor: c.primary.withValues(alpha: .4),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.stitchPrimary,
                                foregroundColor: Colors.white,
                                child: Text(
                                  account.substring(0, 1),
                                  style: AppTypography.headlineSmall,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      account,
                                      style: AppTypography.merchant,
                                    ),
                                    Text(
                                      'Balance: ${MoneyFormatter.php((accounts[accountId]?.$2 ?? 0))} available',
                                      style: small.copyWith(color: c.mutedInk),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: switchAccount,
                                child: const Text('Switch'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final entry in accounts.entries.where(
                                (entry) => entry.key != accountId,
                              ))
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: quickButton(
                                    '${entry.value.$1} (${MoneyFormatter.php(entry.value.$2, decimals: false)})',
                                    () => setState(() => accountId = entry.key),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (kind == TransactionKind.transfer) ...[
                          const SizedBox(height: 12),
                          title('To Account'),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () => switchAccount(receiving: true),
                            icon: const Icon(Icons.swap_horiz),
                            label: Text(destination),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FinanceCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CategoryIcon(
                              Icons.calendar_today_outlined,
                              foreground: c.secondaryInk,
                              background: c.mutedSurface,
                              size: 36,
                              round: false,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Transaction Date',
                                    style: small.copyWith(color: c.mutedInk),
                                  ),
                                  Text(
                                    '${DateUtils.isSameDay(date, ref.read(clockProvider)()) ? 'Today, ' : ''}${DateFormat('MMM d, yyyy · h:mm a').format(date)}',
                                    style: AppTypography.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: pickDate,
                              child: const Text('Change'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(color: c.border),
                        const SizedBox(height: 16),
                        title('Note & Tags'),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: const ValueKey('note-input'),
                          controller: note,
                          maxLength: 500,
                          style: AppTypography.bodyMedium,
                          decoration: field(
                            'Add a note (e.g. Lunch with team, #Lunch)',
                          ).copyWith(counterText: ''),
                        ),
                        const SizedBox(height: 16),
                        title('Receipt'),
                        const SizedBox(height: 8),
                        FinanceCard(
                          color: c.canvas,
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                color: c.secondaryInk,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Scan or upload receipt',
                                      style: small,
                                    ),
                                    Text(
                                      'Receipt scanning is not available yet',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: c.mutedInk,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => context.push('/receipt'),
                                icon: const Icon(
                                  Icons.photo_camera_outlined,
                                  size: 16,
                                ),
                                label: const Text('Scan'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
