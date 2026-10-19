import '../../transactions/presentation/category_color.dart';
import 'widgets/transaction_type_selector.dart';

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
import 'package:pesoflow/core/widgets/financial_account_row.dart';
import 'package:pesoflow/core/widgets/category_icon.dart';
import 'package:pesoflow/core/widgets/finance_card.dart';
import 'package:pesoflow/core/widgets/task_screen.dart';

import 'package:pesoflow/features/transactions/application/transactions_provider.dart';
import 'package:pesoflow/features/budgets/application/budgets_provider.dart';

import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/transactions/domain/transaction_query.dart';
import 'package:pesoflow/features/transactions/domain/manual_transaction_draft.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({
    this.transaction,
    this.initialKind = TransactionKind.expense,
    super.key,
  });
  final TransactionKind initialKind;
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
    kind = widget.initialKind;
    category = kind == TransactionKind.income
        ? TransactionCategory.income
        : kind == TransactionKind.transfer
        ? TransactionCategory.transfer
        : TransactionCategory.food;
    if (accounts.isNotEmpty) accountId = accounts.keys.first;
    final preferences = ref.read(workspaceProvider).preferences;
    if (accounts.containsKey(preferences.defaultAccountId)) {
      accountId = preferences.defaultAccountId;
    }
    if (preferences.hiddenCategories.contains(category)) {
      category = TransactionCategory.values.firstWhere(
        (v) =>
            (kind == TransactionKind.income
                ? isIncomeCategory(v)
                : isExpenseCategory(v)) &&
            !preferences.hiddenCategories.contains(v),
      );
    }
    destinationId =
        accounts.keys.where((id) => id != accountId).firstOrNull ?? '';
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
    setState(
      () => date = DateTime(
        selected.year,
        selected.month,
        selected.day,
        date.hour,
        date.minute,
      ),
    );
  }

  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(date),
    );
    if (time != null && mounted) {
      setState(
        () => date = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        ),
      );
    }
  }

  Future<void> switchAccount({bool receiving = false}) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
          ? AnimationStyle.noAnimation
          : null,
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
      sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
          ? AnimationStyle.noAnimation
          : null,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final c in TransactionCategory.values.where(
              (c) =>
                  (kind == TransactionKind.income
                      ? isIncomeCategory(c)
                      : isExpenseCategory(c)) &&
                  (!ref
                          .read(workspaceProvider)
                          .preferences
                          .hiddenCategories
                          .contains(c) ||
                      c == category),
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

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final w = ref.watch(workspaceProvider);
    final value = parsePhpAmount(amount.text) ?? 0;
    final choices = kind == TransactionKind.income
        ? TransactionCategory.values.where(isIncomeCategory).toList()
        : [
            TransactionCategory.food,
            TransactionCategory.transport,
            TransactionCategory.groceries,
            TransactionCategory.bills,
            TransactionCategory.shopping,
            TransactionCategory.entertainment,
          ];
    final plan = ref.watch(budgetPlansProvider);
    final view = plan.isNotEmpty
        ? ref.read(budgetPlansProvider.notifier).viewFor(date.year, date.month)
        : null;
    final budget = view?.allowances
        .where((a) => a.category == category)
        .firstOrNull;
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      child: Text(text, style: AppTypography.headlineSmall),
    );
    Widget fieldLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(color: c.secondaryInk),
      ),
    );
    Widget accountPicker(bool receiving) {
      final id = receiving ? destinationId : accountId;
      final a = w.accounts.where((a) => a.id == id).firstOrNull;
      return FinanceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (a != null)
              FinancialAccountRow(
                account: a,
                balance: accounts[id]?.$2 ?? 0,
                onTap: () => switchAccount(receiving: receiving),
              )
            else
              TextButton(
                onPressed: () => switchAccount(receiving: receiving),
                child: const Text('Choose account'),
              ),
            TextButton(
              onPressed: () => switchAccount(receiving: receiving),
              child: Text(receiving ? 'Change destination' : 'Change account'),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 8,
                children: [
                  for (final entry in accounts.entries)
                    ChoiceChip(
                      label: Text(entry.value.$1),
                      selected: id == entry.key,
                      onSelected: (_) => setState(() {
                        if (receiving) {
                          destinationId = entry.key;
                        } else {
                          accountId = entry.key;
                        }
                      }),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final typeSelector = TransactionTypeSelector(
      selected: kind,
      enabled: !saving,
      onSelected: (type) => setState(() {
        kind = type;
        category = type == TransactionKind.income
            ? TransactionCategory.income
            : type == TransactionKind.transfer
            ? TransactionCategory.transfer
            : TransactionCategory.food;
      }),
    );

    return TaskScreen(
      title: widget.transaction == null
          ? 'Record Transaction'
          : 'Edit $typeLabel',
      centerTitle: true,
      actions: [
        IconButton(
          tooltip: 'Scan receipt',
          onPressed: saving ? null : () => context.push('/receipt'),
          icon: const Icon(Icons.receipt_long_outlined),
        ),
      ],
      footer: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: saving || accounts.isEmpty ? null : save,
            icon: const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white,
              child: Icon(Icons.check, size: 18, color: AppColors.primary),
            ),
            label: Text(
              saving ? 'Saving…' : 'Save $typeLabel',
              style: AppTypography.headlineSmall,
            ),
          ),
        ),
      ),
      child: accounts.isEmpty
          ? Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.transaction == null) ...[
                      typeSelector,
                      const SizedBox(height: 24),
                    ],
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
                  if (widget.transaction == null) ...[
                    typeSelector,
                    const SizedBox(height: 16),
                  ],
                  FinanceCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                kind == TransactionKind.expense
                                    ? 'Amount spent'
                                    : kind == TransactionKind.income
                                    ? 'Income amount'
                                    : 'Transfer amount',
                                style: AppTypography.bodySmall,
                              ),
                            ),
                            Text(
                              w.preferences.currency,
                              style: AppTypography.labelSmall.copyWith(
                                color: c.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          key: const ValueKey('amount-input'),
                          controller: amount,
                          focusNode: amountFocus,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.center,
                          style: AppTypography.numericXL,
                          decoration: const InputDecoration(
                            prefixText: '₱',
                            hintText: '0.00',
                            filled: false,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none,
                          ),
                          validator: (v) => parsePhpAmount(v ?? '') == null
                              ? 'Enter a positive amount'
                              : null,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final pesos
                                in kind == TransactionKind.income
                                    ? [1000, 5000, 10000, 50000]
                                    : [50, 100, 500, 1000])
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: c.primary.withValues(
                                    alpha: .06,
                                  ),
                                  foregroundColor: c.ink,
                                ),
                                onPressed: () => increment(pesos * 100),
                                child: Text(
                                  '+${MoneyFormatter.php(pesos * 100, decimals: false)}',
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (kind != TransactionKind.transfer) ...[
                    Row(
                      children: [
                        Expanded(
                          child: heading(
                            kind == TransactionKind.income
                                ? 'Income category'
                                : 'Category',
                          ),
                        ),
                        TextButton(
                          onPressed: moreCategories,
                          child: const Text('More ›'),
                        ),
                      ],
                    ),
                    if (budget != null && kind == TransactionKind.expense)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Budget: ${MoneyFormatter.php(budget.remaining)} left',
                          style: AppTypography.bodySmall,
                        ),
                      ),
                    LayoutBuilder(
                      builder: (context, bounds) {
                        final columns =
                            MediaQuery.textScalerOf(context).scale(14) > 19
                            ? 2
                            : 3;
                        final visible = choices
                            .where(
                              (v) =>
                                  !w.preferences.hiddenCategories.contains(v) ||
                                  v == category,
                            )
                            .toList();
                        final tileWidth =
                            (bounds.maxWidth - (columns - 1) * 10) / columns;
                        var labelHeight = 0.0;
                        for (final item in visible) {
                          final painter = TextPainter(
                            text: TextSpan(
                              text: categoryLabel(item),
                              style: AppTypography.bodySmall,
                            ),
                            textDirection: Directionality.of(context),
                            textScaler: MediaQuery.textScalerOf(context),
                          )..layout(maxWidth: tileWidth - 16);
                          if (painter.height > labelHeight) {
                            labelHeight = painter.height;
                          }
                          painter.dispose();
                        }
                        return Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final item in visible)
                              SizedBox(
                                key: ValueKey('category-choice-${item.name}'),
                                width: tileWidth,
                                child: Semantics(
                                  selected: category == item,
                                  button: true,
                                  child: InkWell(
                                    onTap: () =>
                                        setState(() => category = item),
                                    borderRadius: BorderRadius.circular(16),
                                    child: FinanceCard(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 14,
                                      ),
                                      borderColor: category == item
                                          ? c.primary
                                          : c.surface,
                                      child: Column(
                                        children: [
                                          CategoryIcon(
                                            categoryIcon(item),
                                            foreground: categoryColor(item, c),
                                            background: categoryColor(
                                              item,
                                              c,
                                            ).withValues(alpha: .08),
                                          ),
                                          const SizedBox(height: 10),
                                          SizedBox(
                                            height: labelHeight,
                                            child: Center(
                                              child: Text(
                                                categoryLabel(item),
                                                textAlign: TextAlign.center,
                                                style: AppTypography.bodySmall
                                                    .copyWith(
                                                      color: category == item
                                                          ? c.primary
                                                          : c.ink,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                  heading(
                    kind == TransactionKind.income
                        ? 'Destination account'
                        : kind == TransactionKind.transfer
                        ? 'From account'
                        : 'Paid from',
                  ),
                  accountPicker(false),
                  const SizedBox(height: 16),
                  if (kind == TransactionKind.transfer) ...[
                    heading('To account'),
                    accountPicker(true),
                    const SizedBox(height: 16),
                  ],
                  heading('Details'),
                  FinanceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (kind != TransactionKind.transfer) ...[
                          fieldLabel(
                            kind == TransactionKind.income
                                ? 'Income Source / Client'
                                : 'Merchant / Payee',
                          ),
                          TextFormField(
                            key: const ValueKey('merchant-input'),
                            controller: merchant,
                            maxLength: 100,
                            decoration: const InputDecoration(
                              hintText: 'Name',
                              prefixIcon: Icon(Icons.storefront_outlined),
                              counterText: '',
                            ),
                            validator: (v) => (v ?? '').trim().isEmpty
                                ? 'Enter a name'
                                : null,
                          ),
                          const SizedBox(height: 16),
                        ],
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            OutlinedButton.icon(
                              onPressed: pickDate,
                              icon: const Icon(Icons.calendar_today_outlined),
                              label: Text(
                                DateFormat('MMM d, yyyy').format(date),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: pickTime,
                              icon: const Icon(Icons.schedule_outlined),
                              label: Text(DateFormat('h:mm a').format(date)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        fieldLabel('Notes & Tags'),
                        TextFormField(
                          key: const ValueKey('note-input'),
                          controller: note,
                          maxLength: 2000,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Add a note',
                            counterText: '',
                          ),
                        ),
                        if (kind == TransactionKind.expense &&
                            widget.transaction == null) ...[
                          const SizedBox(height: 16),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.add_photo_alternate_outlined),
                            title: const Text('Scan a receipt'),
                            subtitle: const Text(
                              'Review a photo and save its expense',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push('/receipt'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (kind == TransactionKind.transfer)
                    const Text(
                      'Records movement between your tracked accounts. This does not send money or count as income or spending.',
                    ),
                  if (value > 0) const SizedBox(height: 8),
                ],
              ),
            ),
    );
  }
}

IconData categoryIcon(TransactionCategory category) => switch (category) {
  TransactionCategory.food => Icons.restaurant,
  TransactionCategory.transport => Icons.directions_car_outlined,
  TransactionCategory.groceries => Icons.shopping_cart_outlined,
  TransactionCategory.bills => Icons.bolt,
  TransactionCategory.shopping => Icons.shopping_bag_outlined,
  TransactionCategory.entertainment => Icons.sports_esports_outlined,
  TransactionCategory.income => Icons.work_outline,
  _ => Icons.category_outlined,
};
