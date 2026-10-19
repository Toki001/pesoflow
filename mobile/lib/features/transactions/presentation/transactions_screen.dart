import 'package:pesoflow/core/widgets/main_app_bar.dart';

import 'export_transactions.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:pesoflow/app/theme/app_colors.dart';
import 'package:pesoflow/app/theme/app_typography.dart';
import 'package:pesoflow/core/formatting/money_formatter.dart';
import 'package:pesoflow/core/widgets/finance_card.dart';
import 'package:pesoflow/features/transactions/application/transactions_provider.dart';
import 'package:pesoflow/core/time/clock.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/transactions/domain/month_snapshot.dart';
import 'package:pesoflow/features/transactions/domain/transaction_query.dart';
import 'package:pesoflow/features/transactions/presentation/transaction_list_row.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});
  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void setQuery(TransactionQuery query) =>
      ref.read(transactionQueryProvider.notifier).set(query);
  void changeMonth(int delta) {
    final query = ref.read(transactionQueryProvider);
    final date = DateTime(query.year, query.month + delta);
    if (date.isBefore(DateTime(2020)) || date.isAfter(DateTime(2030, 12))) {
      return;
    }
    setQuery(query.copyWith(year: date.year, month: date.month));
  }

  Future<void> pickMonth() async {
    final query = ref.read(transactionQueryProvider);
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(query.year, query.month),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030, 12, 31),
      helpText: 'Choose a date in the month',
    );
    if (date != null && mounted) {
      setQuery(query.copyWith(year: date.year, month: date.month));
    }
  }

  Future<void> chooseFilter({required bool account}) async {
    final records = ref.read(ledgerProvider);
    final query = ref.read(transactionQueryProvider);
    final accountOptions = <String, String>{};
    for (final t in records) {
      if (t.accountId != null && t.accountId!.trim().isNotEmpty) {
        accountOptions.putIfAbsent(t.accountId!, () => t.account);
      }
      if (t.kind == TransactionKind.transfer &&
          t.destinationAccountId != null &&
          t.destinationAccountId!.trim().isNotEmpty) {
        accountOptions.putIfAbsent(
          t.destinationAccountId!,
          () => t.destinationAccount ?? 'Transfer account',
        );
      }
    }
    final options = account
        ? accountOptions.keys.toList()
        : records.map((t) => categoryLabel(t.category)).toSet().toList();
    final selected = await showModalBottomSheet<String>(
      context: context,
      sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
          ? AnimationStyle.noAnimation
          : null,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                account ? 'Accounts' : 'Categories',
                style: AppTypography.headlineMedium,
              ),
              ListTile(
                title: const Text('All'),
                onTap: () => Navigator.pop(context, 'All'),
              ),
              for (final option in options)
                ListTile(
                  title: Text(account ? accountOptions[option]! : option),
                  onTap: () => Navigator.pop(context, option),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setQuery(
      account
          ? query.copyWith(accountId: selected, clearAccount: selected == 'All')
          : query.copyWith(
              category: selected == 'All'
                  ? null
                  : records
                        .firstWhere(
                          (t) => categoryLabel(t.category) == selected,
                        )
                        .category,
              clearCategory: selected == 'All',
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final query = ref.watch(transactionQueryProvider);
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const MainAppBar('Transactions'),
          Expanded(
            child: ref
                .watch(transactionsProvider)
                .when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => Center(
                    child: TextButton(
                      onPressed: () => ref.invalidate(transactionsProvider),
                      child: const Text('Retry transactions'),
                    ),
                  ),
                  data: (records) {
                    final filtered = filterTransactions(records, query);
                    final groups = groupTransactions(filtered);
                    final snapshot = MonthSnapshot.fromLedger(
                      records
                          .where(
                            (t) => !t.occurredAt.isAfter(
                              ref.read(clockProvider)(),
                            ),
                          )
                          .toList(),
                      query.year,
                      query.month,
                    );
                    final spent = snapshot.spent;
                    final income = snapshot.income;
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      children: [
                        FinanceCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    tooltip: 'Previous month',
                                    onPressed: () => changeMonth(-1),
                                    icon: const Icon(
                                      Icons.chevron_left,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: pickMonth,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              DateFormat('MMMM yyyy').format(
                                                DateTime(
                                                  query.year,
                                                  query.month,
                                                ),
                                              ),
                                              style: AppTypography.headlineSmall
                                                  .copyWith(color: c.ink),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.expand_more,
                                            size: 16,
                                            color: AppColors.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Next month',
                                    onPressed: () => changeMonth(1),
                                    icon: const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Net Cash Flow',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: c.mutedInk,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  MoneyFormatter.php(
                                    income - spent,
                                    signed: true,
                                  ),
                                  style: AppTypography.numericXL,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                spacing: 12,
                                children: [
                                  for (final (label, amount, color) in [
                                    ('Inflow', income, c.positive),
                                    ('Outflow', -spent, c.ink),
                                  ])
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: c.primary.withValues(
                                            alpha: .06,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              label,
                                              style: AppTypography.bodySmall
                                                  .copyWith(color: c.mutedInk),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              MoneyFormatter.php(
                                                amount,
                                                signed: true,
                                              ),
                                              style: AppTypography.merchant
                                                  .copyWith(color: color),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: search,
                          onChanged: (text) =>
                              setQuery(query.copyWith(search: text)),
                          style: AppTypography.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'Search merchant, note, or amount...',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.primary,
                            ),
                            suffixIcon: IconButton(
                              tooltip: 'Clear search',
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                side: BorderSide.none,
                              ),
                              onPressed: () {
                                search.clear();
                                setQuery(query.copyWith(search: ''));
                              },
                              icon: const Icon(
                                Icons.close,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: c.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: c.border),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final filter in TransactionFilter.values)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _FilterPill(
                                    label: switch (filter) {
                                      TransactionFilter.all => 'All',
                                      TransactionFilter.expenses => 'Expenses',
                                      TransactionFilter.income => 'Income',
                                      TransactionFilter.transfers =>
                                        'Transfers',
                                      TransactionFilter.pending => 'Pending',
                                    },
                                    selected: query.filter == filter,
                                    onTap: () => setQuery(
                                      query.copyWith(filter: filter),
                                    ),
                                  ),
                                ),
                              _FilterPill(
                                label:
                                    accountLabel(
                                      query.accountId,
                                      ref.watch(ledgerProvider),
                                    ) ??
                                    'Accounts',
                                selected: query.accountId != null,
                                onTap: () => chooseFilter(account: true),
                              ),
                              const SizedBox(width: 8),
                              _FilterPill(
                                label: query.category == null
                                    ? 'Categories'
                                    : categoryLabel(query.category!),
                                selected: query.category != null,
                                onTap: () => chooseFilter(account: false),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (filtered.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off,
                                  color: AppColors.primary,
                                  size: 32,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No transactions found',
                                  style: AppTypography.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Try another month, search, or filter.',
                                ),
                                TextButton(
                                  onPressed: () {
                                    search.clear();
                                    setQuery(
                                      TransactionQuery(
                                        year: query.year,
                                        month: query.month,
                                      ),
                                    );
                                  },
                                  child: const Text('Reset filters'),
                                ),
                              ],
                            ),
                          ),
                        for (final entry in groups.entries) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text(
                                  _dateLabel(entry.key),
                                  style: AppTypography.labelMedium.copyWith(
                                    color: c.secondaryInk,
                                  ),
                                ),
                                if (entry.value.isNotEmpty)
                                  Text(
                                    '${entry.value.length} records',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: c.mutedInk,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          FinanceCard(
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: [
                                for (final (index, t)
                                    in entry.value.indexed) ...[
                                  if (index > 0)
                                    Divider(height: 1, color: c.border),
                                  TransactionListRow(transaction: t),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        FinanceCard(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.description_outlined,
                              color: AppColors.primary,
                            ),
                            title: const Text('Transaction report'),
                            subtitle: const Text(
                              'Export all saved records as CSV',
                            ),
                            onTap: () => exportTransactions(context, ref),
                            trailing: const Icon(
                              Icons.file_download_outlined,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime date) {
    final day = DateUtils.dateOnly(ref.read(clockProvider)());
    final prefix = date == day
        ? 'Today — '
        : date == day.subtract(const Duration(days: 1))
        ? 'Yesterday — '
        : '';
    return '$prefix${DateFormat('EEEE, MMM d').format(date)}';
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: Material(
      color: selected ? context.colors.primary : context.colors.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? context.colors.primary : context.colors.border,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: selected
                  ? (context.colors.isDark
                        ? AppColors.darkSurface
                        : Colors.white)
                  : context.colors.secondaryInk,
            ),
          ),
        ),
      ),
    ),
  );
}

/// Resolve a display snapshot without using it as account identity.
String? accountLabel(String? id, List<TransactionRecord> records) {
  if (id == null) return null;
  for (final t in records) {
    if (t.accountId == id) return t.account;
    if (t.kind == TransactionKind.transfer && t.destinationAccountId == id) {
      return t.destinationAccount ?? 'Transfer account';
    }
  }
  return 'Selected account';
}
