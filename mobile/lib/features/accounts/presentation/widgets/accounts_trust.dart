import 'package:flutter/material.dart';
import 'package:pesoflow/app/theme/app_typography.dart';
import 'package:pesoflow/core/widgets/finance_card.dart';

class AccountsReassurance extends StatelessWidget {
  const AccountsReassurance({super.key});
  @override
  Widget build(BuildContext context) => FinanceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Manual financial tracking', style: AppTypography.merchant),
        const SizedBox(height: 8),
        const Text(
          'Balances are calculated from your starting balances and saved transactions. These are not live institution balances.',
        ),
      ],
    ),
  );
}

class AccountsTrust extends StatelessWidget {
  const AccountsTrust({super.key});
  @override
  Widget build(BuildContext context) => FinanceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('No connected institutions yet', style: AppTypography.merchant),
        const SizedBox(height: 8),
        const Text(
          'Bank and wallet connections are not configured. You can track accounts manually without providing bank passwords, wallet PINs or card details.',
        ),
      ],
    ),
  );
}

class AccountsInsight extends StatelessWidget {
  const AccountsInsight({super.key});
  @override
  Widget build(BuildContext context) => const FinanceCard(
    child: Text(
      'Your records are saved on this device. PesoFlow cannot move money or make payments.',
    ),
  );
}
