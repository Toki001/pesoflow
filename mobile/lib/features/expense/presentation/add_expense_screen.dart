import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../demo_workspace/application/demo_workspace_providers.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/formatting/money_formatter.dart';
import '../../../core/widgets/budget_progress_bar.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../core/widgets/finance_card.dart';
import '../../../core/widgets/task_screen.dart';
import '../../accounts/data/ledger_account_fixture.dart';
import '../../transactions/application/transactions_provider.dart';
import '../../budgets/application/budgets_provider.dart';
import '../../transactions/data/transaction_fixture.dart';
import '../../transactions/domain/transaction.dart';
import '../../transactions/domain/transaction_query.dart';
import '../../transactions/domain/manual_transaction_draft.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});
  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final amount = TextEditingController(text: '325.00');
  final merchant = TextEditingController(text: 'Jollibee');
  final note = TextEditingController();
  final amountFocus = FocusNode();
  final formKey = GlobalKey<FormState>();
  TransactionKind kind = TransactionKind.expense;
  TransactionCategory category = TransactionCategory.food;
  String accountId = DemoLedgerAccounts.gcash.id;
  String get account => DemoLedgerAccounts.byId(accountId)!.label;
  String destinationId = DemoLedgerAccounts.maya.id;
  String get destination => DemoLedgerAccounts.byId(destinationId)!.label;
  DateTime date = demoClock;
  bool saving = false;
  static final Map<String, (String, int)> accounts = Map.unmodifiable({
    DemoLedgerAccounts.gcash.id: ('GCash Personal', 425000),
    DemoLedgerAccounts.bdo.id: ('BDO Checking', 2840000),
    DemoLedgerAccounts.maya.id: ('Maya Wallet', 185000),
    DemoLedgerAccounts.cash.id: ('Cash', 0),
  });
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
    accountId = DemoLedgerAccounts.gcash.id;
    destinationId = DemoLedgerAccounts.maya.id;
    date = demoClock;
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
                  entry.key == DemoLedgerAccounts.cash.id
                      ? 'Manual cash ledger'
                      : 'Demo balance: ${MoneyFormatter.php(entry.value.$2)}',
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
              (c) => ![
                TransactionCategory.transfer,
                TransactionCategory.income,
                TransactionCategory.refund,
              ].contains(c),
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

  void save() {
    if (saving) return;
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
    ref.read(demoLedgerProvider.notifier).createManual(draft);
    ref
        .read(transactionQueryProvider.notifier)
        .set(TransactionQuery(year: date.year, month: date.month));
    context.go('/transactions');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ref.read(demoPersistenceEnabledProvider)
              ? '$typeLabel added to your demo. Local save is queued.'
              : '$typeLabel saved in this demo session.',
        ),
      ),
    );
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
    ref.watch(demoLedgerProvider);
    ref.watch(demoBudgetPlansProvider);
    final plan = ref
        .read(demoBudgetPlansProvider.notifier)
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
      title: 'Add $typeLabel',
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
      child: Form(
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
                          onPressed: () => setState(() => kind = type),
                          style: TextButton.styleFrom(
                            backgroundColor: kind == type
                                ? c.surface
                                : Colors.transparent,
                            foregroundColor: kind == type ? c.ink : c.mutedInk,
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
                            keyboardType: const TextInputType.numberWithOptions(
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
                      quickButton('Exact', () => amountFocus.requestFocus()),
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
                      validator: (text) => text == null || text.trim().isEmpty
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
                          for (final name in [
                            'Jollibee',
                            'Grab',
                            'SM Store',
                            '7-Eleven',
                          ])
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: quickButton(
                                name,
                                () => setState(() => merchant.text = name),
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
                                    (constraints.maxWidth - (columns - 1) * 8) /
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
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: category == item
                                            ? c.primary
                                            : c.border,
                                        width: category == item ? 2 : 1,
                                      ),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () =>
                                          setState(() => category = item),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
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
                                                      AppColors.warningSoft,
                                                    )
                                                  : c.mutedSurface,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              item == TransactionCategory.bills
                                                  ? 'Bills'
                                                  : categoryLabel(item),
                                              textAlign: TextAlign.center,
                                              style: AppTypography.labelSmall
                                                  .copyWith(
                                                    color: category == item
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
                                  style: small.copyWith(color: c.secondaryInk),
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
                                  style: AppTypography.labelSmall.copyWith(
                                    color: c.mutedInk,
                                  ),
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
                        'Demo account',
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
                                accounts[accountId]!.$1,
                                style: AppTypography.merchant,
                              ),
                              Text(
                                accountId == DemoLedgerAccounts.cash.id
                                    ? 'Manual cash ledger'
                                    : 'Balance: ${MoneyFormatter.php(accounts[accountId]!.$2)} available',
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
                              entry.key == DemoLedgerAccounts.cash.id
                                  ? 'Cash'
                                  : '${entry.value.$1} (${MoneyFormatter.php(entry.value.$2, decimals: false)})',
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
                      label: Text(accounts[destinationId]!.$1),
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
                              '${date.year == 2024 && date.month == 10 && date.day == 24 ? 'Today, ' : ''}${DateFormat('MMM d, yyyy · h:mm a').format(date)}',
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
                              Text('Scan or upload receipt', style: small),
                              Text(
                                'Demo review · no live OCR',
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
