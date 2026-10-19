import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/formatting/money_formatter.dart';
import '../../../core/time/clock.dart';
import '../../../core/widgets/finance_card.dart';
import '../../../core/widgets/financial_account_row.dart';
import '../../../core/widgets/task_screen.dart';
import '../../workspace/application/finance_controller.dart';
import '../domain/financial_account.dart';
import 'manual_account_editor.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});
  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  bool showBalance = true;
  @override
  Widget build(BuildContext context) {
    final w = ref.watch(workspaceProvider);
    final now = ref.watch(clockProvider)();
    final ledger = w.ledger.where((t) => !t.occurredAt.isAfter(now));
    int balance(FinancialAccount a) => accountBalance(a, ledger);
    final active = w.accounts.where((a) => !a.archived);
    final liquid = active.where((a) => a.type != AccountType.credit);
    final credit = active.where(
      (a) => a.type == AccountType.credit && a.creditLimit != null,
    );
    final available = credit.fold<int>(
      0,
      (sum, a) => sum + (a.creditLimit! + balance(a)).clamp(0, 999999999999),
    );
    final c = context.colors;
    Widget summary(String label, int amount, String caption) => FinanceCard(
      key: ValueKey('account-summary-$label'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.bodySmall),
          const SizedBox(height: 12),
          Text(
            showBalance ? MoneyFormatter.php(amount) : '••••',
            style: AppTypography.numericMedium,
          ),
          const SizedBox(height: 12),
          Text(
            caption,
            style: AppTypography.labelSmall.copyWith(color: c.mutedInk),
          ),
        ],
      ),
    );
    return TaskScreen(
      title: 'All Accounts',
      backIcon: Icons.arrow_back,
      backTooltip: 'Back',
      fallbackRoute: '/home',
      actions: [
        TextButton.icon(
          onPressed: () => showManualAccountEditor(context),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Account'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Expanded(child: Text('Manually tracked ledger')),
              const Text('Show balance'),
              Switch(
                value: showBalance,
                onChanged: (v) => setState(() => showBalance = v),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, bounds) {
              final cards = [
                summary(
                  'Tracked Balance',
                  liquid.fold<int>(0, (sum, a) => sum + balance(a)),
                  '${liquid.length} cash sources',
                ),
                summary(
                  'Available Credit',
                  available,
                  credit.isEmpty
                      ? 'No credit limit recorded'
                      : 'Separate from cash',
                ),
              ];
              return MediaQuery.textScalerOf(context).scale(14) > 19
                  ? Column(
                      spacing: 12,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: cards,
                    )
                  : IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 12,
                        children: cards.map((v) => Expanded(child: v)).toList(),
                      ),
                    );
            },
          ),
          if (w.accounts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Text('No accounts yet', style: AppTypography.headlineSmall),
                  const SizedBox(height: 8),
                  const Text('Create a cash, wallet or bank account to begin.'),
                  TextButton(
                    onPressed: () => showManualAccountEditor(context),
                    child: const Text('Add Manual Account'),
                  ),
                ],
              ),
            ),
          for (final (title, accounts)
              in <(String, Iterable<FinancialAccount>)>[
                (
                  'Bank Accounts',
                  active.where(
                    (a) =>
                        a.type == AccountType.bank ||
                        a.type == AccountType.savings,
                  ),
                ),
                (
                  'E-Wallets',
                  active.where((a) => a.type == AccountType.wallet),
                ),
                (
                  'Payment Cards',
                  active.where((a) => a.type == AccountType.credit),
                ),
                (
                  'Cash & Offline Holdings',
                  active.where((a) => a.type == AccountType.cash),
                ),
                ('Archived Accounts', w.accounts.where((a) => a.archived)),
              ])
            if (accounts.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 12),
                child: Text(
                  '$title (${accounts.length})',
                  style: AppTypography.headlineSmall,
                ),
              ),
              for (final a in accounts)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FinanceCard(
                    child: Column(
                      children: [
                        FinancialAccountRow(
                          account: a,
                          balance: balance(a),
                          showBalance: showBalance,
                        ),
                        if (a.cardNetwork.isNotEmpty ||
                            a.cardLastFour.isNotEmpty)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${a.cardNetwork} ${a.type == AccountType.credit ? 'Credit' : 'Debit'}${a.cardLastFour.isEmpty ? '' : ' •••• ${a.cardLastFour}'}',
                              style: AppTypography.bodySmall,
                            ),
                          ),
                        if (a.creditLimit != null && showBalance)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Limit: ${MoneyFormatter.php(a.creditLimit!)} · Available: ${MoneyFormatter.php((a.creditLimit! + balance(a)).clamp(0, 999999999999))}',
                              style: AppTypography.bodySmall,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          const SizedBox(height: 16),
          FinanceCard(
            child: const Text(
              'Manual expense tracking. PesoFlow does not access banking credentials or transfer funds.',
            ),
          ),
        ],
      ),
    );
  }
}
