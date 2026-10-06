import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/formatting/money_formatter.dart';
import '../../../core/widgets/budget_progress_bar.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../core/widgets/finance_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/task_screen.dart';
import '../application/transactions_provider.dart';
import '../../budgets/application/budgets_provider.dart';
import '../domain/transaction.dart';

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({required this.id, super.key});
  final String id;
  Future<String?> _textInput(
    BuildContext context,
    String title,
    String value, {
    bool multiline = false,
  }) => showDialog<String>(
    context: context,
    builder: (_) =>
        _AnnotationDialog(title: title, value: value, multiline: multiline),
  );
  Future<void> _editNotes(
    BuildContext context,
    WidgetRef ref,
    TransactionRecord t,
  ) async {
    final note = await _textInput(
      context,
      'Edit notes',
      t.note,
      multiline: true,
    );
    if (note != null) {
      ref.read(demoLedgerProvider.notifier).update(t.copyWith(note: note));
    }
  }

  Future<void> _category(
    BuildContext context,
    WidgetRef ref,
    TransactionRecord t,
  ) async {
    final options = t.kind == TransactionKind.expense
        ? TransactionCategory.values
              .where(
                (c) => ![
                  TransactionCategory.transfer,
                  TransactionCategory.income,
                  TransactionCategory.refund,
                ].contains(c),
              )
              .toList()
        : [t.category];
    final selected = await showModalBottomSheet<TransactionCategory>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              'Category',
              textAlign: TextAlign.center,
              style: AppTypography.headlineMedium,
            ),
            for (final category in options)
              ListTile(
                title: Text(categoryLabel(category)),
                trailing: t.category == category
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.pop(context, category),
              ),
          ],
        ),
      ),
    );
    if (selected != null) {
      ref
          .read(demoLedgerProvider.notifier)
          .update(
            t.copyWith(
              category: selected,
              metadata: '${categoryLabel(selected)} · ${t.account}',
            ),
          );
    }
  }

  Future<void> _demoInfo(BuildContext context, String title, String text) =>
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledger = ref.watch(demoLedgerProvider);
    final matches = ledger.where((t) => t.id == id);
    if (matches.isEmpty) {
      return const TaskScreen(
        title: 'Transaction Detail',
        child: Center(child: Text('Transaction not found')),
      );
    }
    final t = matches.first;
    final c = context.colors;
    final synced =
        t.source == TransactionSource.bankSync ||
        t.source == TransactionSource.walletSync;
    final jollibee = id == 'jollibee';
    ref.watch(demoBudgetPlansProvider);
    final plan = ref
        .read(demoBudgetPlansProvider.notifier)
        .viewFor(t.occurredAt.year, t.occurredAt.month);
    final allowances = plan.allowances.where((a) => a.category == t.category);
    final allowance = allowances.isEmpty ? null : allowances.first;
    final categorySpent = allowance?.spent ?? 0;
    final categoryLimit = allowance?.limit ?? 1;
    final budgetColor = categorySpent >= categoryLimit
        ? c.danger
        : categorySpent * 100 >= categoryLimit * 80
        ? c.warning
        : c.primary;
    Widget heading(String text) => Text(
      text.toUpperCase(),
      style: AppTypography.labelMedium.copyWith(
        color: c.mutedInk,
        letterSpacing: .7,
      ),
    );
    Widget pair(String label, Widget value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 12,
          runSpacing: 6,
          children: [
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
            ),
            value,
          ],
        ),
      ),
    );
    final small = AppTypography.bodySmall;
    return TaskScreen(
      title: 'Transaction Detail',
      actions: [
        IconButton(
          tooltip: 'Share receipt',
          onPressed: () => _demoInfo(
            context,
            'Demo receipt',
            'Receipt sharing will be available when local receipt files are stored.',
          ),
          icon: const Icon(Icons.ios_share_outlined),
        ),
        IconButton(
          tooltip: 'More options',
          onPressed: () => _demoInfo(
            context,
            'Demo transaction',
            'Notes, category, tags and budget exclusion are saved only for this app session. Synced amounts and provenance remain read-only.',
          ),
          icon: const Icon(Icons.more_vert),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FinanceCard(
            hero: true,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Stack(
                  children: [
                    CategoryIcon(
                      jollibee
                          ? Icons.fastfood_outlined
                          : t.kind == TransactionKind.transfer
                          ? Icons.swap_horiz
                          : Icons.receipt_long_outlined,
                      foreground: Colors.white,
                      iconSize: 32,
                      background: t.kind == TransactionKind.expense
                          ? AppColors.danger
                          : AppColors.secondary,
                      size: 64,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: t.status == TransactionStatus.pending
                            ? c.warning
                            : c.positive,
                        child: Icon(
                          t.status == TransactionStatus.pending
                              ? Icons.schedule
                              : Icons.check,
                          size: 13,
                          color: c.surface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  MoneyFormatter.php(
                    t.kind == TransactionKind.transfer
                        ? t.amount
                        : t.displayAmount,
                    signed:
                        t.kind == TransactionKind.income ||
                        t.kind == TransactionKind.refund,
                  ),
                  style: AppTypography.numericXL,
                ),
                const SizedBox(height: 4),
                Text(
                  jollibee ? 'Jollibee Megamall Branch' : t.merchant,
                  style: AppTypography.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${categoryLabel(t.category)}${jollibee ? ' • Fast Food' : ''}',
                  style: small.copyWith(color: c.mutedInk),
                ),
                const SizedBox(height: 12),
                StatusBadge(
                  '${t.status == TransactionStatus.pending ? 'Pending' : 'Completed'} • ${synced
                      ? 'Read-only synced'
                      : t.source == TransactionSource.receipt
                      ? 'Receipt entry'
                      : 'Manual entry'}',
                  foreground: c.secondaryInk,
                  background: c.mutedSurface,
                  icon: Icons.circle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FinanceCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading('Provenance & Info'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CategoryIcon(
                      t.account == 'GCash'
                          ? Icons.account_balance_wallet_outlined
                          : Icons.account_balance_outlined,
                      foreground: c.primary,
                      background: c.soft(c.primary, AppColors.primarySoft),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.account == 'GCash' ? 'GCash Personal' : t.account,
                            style: AppTypography.bodyMedium,
                          ),
                          if (t.account == 'GCash')
                            Text(
                              '0917 •••• 892',
                              style: small.copyWith(color: c.mutedInk),
                            ),
                        ],
                      ),
                    ),
                    StatusBadge(
                      synced
                          ? 'Synced'
                          : t.source == TransactionSource.receipt
                          ? 'Receipt'
                          : 'Manual',
                      foreground: c.primary,
                      background: c.soft(c.primary, AppColors.primarySoft),
                      pill: false,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: c.border),
                pair(
                  'Date & Time',
                  Text(
                    DateFormat('EEE, MMM d, yyyy • h:mm a')
                        .format(t.occurredAt),
                    style: small,
                  ),
                ),
                pair(
                  'Category',
                  TextButton(
                    onPressed: () => _category(context, ref, t),
                    child: Text(
                      '${categoryLabel(t.category)} ⌄',
                      style: small.copyWith(color: c.ink),
                    ),
                  ),
                ),
                if (allowance != null)
                  FinanceCard(
                    color: c.canvas,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          spacing: 8,
                          children: [
                            Text('Monthly Budget Impact', style: small),
                            Text(
                              t.excludedFromBudget
                                  ? 'Excluded'
                                  : '${(categorySpent * 100 ~/ categoryLimit)}% Used',
                              style: small.copyWith(color: c.warning),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        BudgetProgressBar(
                          value: categorySpent / categoryLimit,
                          color: budgetColor,
                          label: '${categoryLabel(t.category)} budget',
                          height: 8,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          spacing: 8,
                          children: [
                            Text(
                              '${MoneyFormatter.php(categorySpent, decimals: false)} / ${MoneyFormatter.php(categoryLimit, decimals: false)} limit',
                              style: small,
                            ),
                            Text(
                              '${MoneyFormatter.php(categoryLimit - categorySpent, decimals: false)} remaining',
                              style: small,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                pair(
                  'Reference No.',
                  Text(
                    jollibee ? '#TXN-902847291' : '#DEMO-${t.id.toUpperCase()}',
                    style: small.copyWith(color: c.mutedInk),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Notes', style: small.copyWith(color: c.mutedInk)),
                    TextButton(
                      onPressed: () => _editNotes(context, ref, t),
                      child: const Text('Edit'),
                    ),
                  ],
                ),
                FinanceCard(
                  color: c.canvas,
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    t.note.isEmpty ? 'No notes added' : '“${t.note}”',
                    style: small.copyWith(
                      color: c.secondaryInk,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (t.hasReceipt) ...[
            FinanceCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        color: c.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: heading('Receipt & Items')),
                      StatusBadge(
                        'Demo receipt',
                        foreground: c.positive,
                        background: c.soft(c.positive, AppColors.positiveSoft),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FinanceCard(
                    color: c.canvas,
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 56,
                          color: c.mutedSurface,
                          child: Icon(
                            Icons.receipt_long,
                            color: c.mutedInk,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('1 receipt attached', style: small),
                              Text(
                                'Fixture preview • ${jollibee ? '3 items' : 'Total only'}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: c.mutedInk,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          MoneyFormatter.php(t.amount),
                          style: AppTypography.numericMedium,
                        ),
                      ],
                    ),
                  ),
                  if (jollibee) ...[
                    const SizedBox(height: 12),
                    Divider(color: c.border),
                    for (final (name, amount) in [
                      ('1x 1pc Spicy Chickenjoy w/ Rice', 11500),
                      ('1x Jolly Spaghetti w/ Drink', 15000),
                      ('1x Large Peach Mango Pie', 6000),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Expanded(child: Text(name, style: small)),
                            Text(MoneyFormatter.php(amount), style: small),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          FinanceCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        heading('Expense Sharing'),
                        Text(
                          'Split total or assign specific line items',
                          style: small,
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () => _demoInfo(
                        context,
                        'Split preview',
                        '${MoneyFormatter.php(t.amount)} shared equally among 3 people:\n${MoneyFormatter.php(t.amount ~/ 3 + t.amount % 3)} for you and ${MoneyFormatter.php(t.amount ~/ 3)} each for two companions.\n\nThis preview creates no payment or debt.',
                      ),
                      icon: const Icon(Icons.call_split, size: 16),
                      label: const Text('Split Bill'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Quick add:', style: AppTypography.labelSmall),
                    for (final name in ['Mark', 'Camille', 'JR'])
                      StatusBadge(
                        name,
                        foreground: c.secondaryInk,
                        background: c.mutedSurface,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: c.border),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    heading('Tags'),
                    TextButton(
                      onPressed: () async {
                        final tag = await _textInput(context, 'New tag', '');
                        if (tag != null &&
                            tag.isNotEmpty &&
                            !t.tags.contains(tag)) {
                          ref
                              .read(demoLedgerProvider.notifier)
                              .update(t.copyWith(tags: [...t.tags, tag]));
                        }
                      },
                      child: const Text('+ New Tag'),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final (index, tag) in t.tags.indexed)
                      StatusBadge(
                        '#$tag',
                        foreground: index == 0
                            ? c.accent
                            : index == 1
                            ? c.secondary
                            : c.secondaryInk,
                        background: index == 0
                            ? c.soft(c.accent, AppColors.accentSoft)
                            : index == 1
                            ? c.soft(c.secondary, AppColors.secondarySoft)
                            : c.mutedSurface,
                        pill: false,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _editNotes(context, ref, t),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(synced ? 'Edit Details' : 'Edit Notes'),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => ref
                    .read(demoLedgerProvider.notifier)
                    .update(
                      t.copyWith(excludedFromBudget: !t.excludedFromBudget),
                    ),
                icon: Icon(
                  t.excludedFromBudget
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 16,
                ),
                label: Text(
                  t.excludedFromBudget
                      ? 'Include in Budget'
                      : 'Exclude from Budget',
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _demoInfo(
                  context,
                  'Report Issue',
                  'This is fixture data. No report is sent. For now, use category and note edits to review the demo record.',
                ),
                icon: Icon(Icons.flag_outlined, size: 16, color: c.danger),
                label: Text('Report Issue', style: TextStyle(color: c.danger)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Demo data • changes last for this session',
            style: AppTypography.labelSmall.copyWith(color: c.mutedInk),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _AnnotationDialog extends StatefulWidget {
  const _AnnotationDialog({
    required this.title,
    required this.value,
    required this.multiline,
  });
  final String title;
  final String value;
  final bool multiline;
  @override
  State<_AnnotationDialog> createState() => _AnnotationDialogState();
}

class _AnnotationDialogState extends State<_AnnotationDialog> {
  late final controller = TextEditingController(text: widget.value);
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      key: const ValueKey('detail-input'),
      controller: controller,
      autofocus: true,
      maxLines: widget.multiline ? 4 : 1,
      maxLength: widget.multiline ? 500 : 40,
      decoration: InputDecoration(labelText: widget.title),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, controller.text.trim()),
        child: const Text('Save'),
      ),
    ],
  );
}
