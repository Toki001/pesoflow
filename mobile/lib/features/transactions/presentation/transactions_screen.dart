import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/formatting/money_formatter.dart';
import '../../../core/widgets/finance_card.dart';
import '../application/transactions_provider.dart';
import '../data/transaction_fixture.dart';
import '../domain/transaction.dart';
import '../domain/month_snapshot.dart';
import '../domain/transaction_query.dart';
import 'transaction_list_row.dart';

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
    final records = ref.read(demoLedgerProvider);
    final query = ref.read(transactionQueryProvider);
    final options = account
        ? records.map((t) => t.account).toSet().toList()
        : records.map((t) => categoryLabel(t.category)).toSet().toList();
    final selected = await showModalBottomSheet<String>(
      context: context,
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
                  title: Text(option),
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
          ? query.copyWith(account: selected, clearAccount: selected == 'All')
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
          Container(
            color: c.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Transactions',
                    style: AppTypography.headlineMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Filter date range',
                  onPressed: pickMonth,
                  icon: const Icon(Icons.calendar_month_outlined),
                ),
                IconButton(
                  tooltip: 'Export options',
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Demo transactions'),
                      content: const Text(
                        'Export will be available when local transaction storage is implemented.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                  icon: const Icon(Icons.ios_share_outlined),
                ),
              ],
            ),
          ),
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
                      records,
                      query.year,
                      query.month,
                      baseline: transactionFixture(),
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
                                    icon: const Icon(Icons.chevron_left),
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
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Next month',
                                    onPressed: () => changeMonth(1),
                                    icon: const Icon(Icons.chevron_right),
                                  ),
                                ],
                              ),
                              Divider(color: c.border),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  for (final (label, amount, color, signed) in [
                                    ('Spent', spent, c.ink, false),
                                    ('Income', income, c.positive, false),
                                    (
                                      'Net Flow',
                                      income - spent,
                                      c.primary,
                                      true,
                                    ),
                                  ])
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: label == 'Net Flow'
                                              ? null
                                              : Border(
                                                  right: BorderSide(
                                                    color: c.border,
                                                  ),
                                                ),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              label,
                                              style: AppTypography.labelSmall
                                                  .copyWith(color: c.mutedInk),
                                            ),
                                            const SizedBox(height: 4),
                                            FittedBox(
                                              child: Text(
                                                MoneyFormatter.php(
                                                  amount,
                                                  decimals: false,
                                                  signed: signed,
                                                ),
                                                style: AppTypography
                                                    .numericMedium
                                                    .copyWith(color: color),
                                              ),
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
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              tooltip: 'Clear search',
                              onPressed: () {
                                search.clear();
                                setQuery(query.copyWith(search: ''));
                              },
                              icon: const Icon(Icons.close, size: 18),
                            ),
                            filled: true,
                            fillColor: c.surface,
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
                                    query.account ??
                                    'Accounts (GCash, BDO, Maya)',
                                selected: query.account != null,
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
                                  color: c.mutedInk,
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
                                    setQuery(const TransactionQuery());
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
                                if (entry.key.day >= 23)
                                  Text(
                                    'Total: ${MoneyFormatter.php(entry.value.fold(0, (sum, t) => sum + t.cashFlowImpact), signed: true)}',
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
    final day = DateTime(demoClock.year, demoClock.month, demoClock.day);
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
