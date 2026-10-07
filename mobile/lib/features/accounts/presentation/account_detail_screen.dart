import 'package:pesoflow/core/time/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pesoflow/app/theme/app_typography.dart';
import 'package:pesoflow/core/formatting/money_formatter.dart';
import 'package:pesoflow/core/widgets/finance_card.dart';
import 'package:pesoflow/core/widgets/task_screen.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/features/transactions/presentation/transaction_list_row.dart';
import 'package:pesoflow/features/accounts/domain/financial_account.dart';
import 'package:pesoflow/features/accounts/presentation/manual_account_editor.dart';

class AccountDetailScreen extends ConsumerWidget {
  const AccountDetailScreen({required this.id, super.key});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = ref.watch(workspaceProvider);
    final a = w.accounts.where((a) => a.id == id).firstOrNull;
    if (a == null) {
      return const TaskScreen(
        title: 'Account Detail',
        fallbackRoute: '/accounts',
        child: Center(child: Text('Account not found.')),
      );
    }
    final records = w.ledger.where((t) => t.involvesAccount(id)).toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return TaskScreen(
      title: 'Account Detail',
      fallbackRoute: '/accounts',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FinanceCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.name, style: AppTypography.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  a.archived
                      ? 'Archived • history preserved'
                      : 'Manually tracked balance',
                ),
                const SizedBox(height: 8),
                Text(
                  MoneyFormatter.php(
                    accountBalance(
                      a,
                      w.ledger.where(
                        (t) => !t.occurredAt.isAfter(ref.read(clockProvider)()),
                      ),
                    ),
                  ),
                  style: AppTypography.numericXL,
                ),
                const SizedBox(height: 12),
                Text('${a.institution} ${a.maskedIdentifier}'.trim()),
                const SizedBox(height: 8),
                const Text(
                  'Calculated from your opening balance and recorded transactions. Not a provider-reported balance.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FinanceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Starting balance', style: AppTypography.merchant),
                const SizedBox(height: 8),
                Text(MoneyFormatter.php(a.startingBalance)),
                if (a.notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(a.notes),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => showManualAccountEditor(context, account: a),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Account'),
          ),
          const SizedBox(height: 24),
          Text('Account activity', style: AppTypography.headlineSmall),
          const SizedBox(height: 12),
          FinanceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                if (records.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No transactions yet.'),
                  ),
                for (final t in records)
                  TransactionListRow(transaction: t, wrapText: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
