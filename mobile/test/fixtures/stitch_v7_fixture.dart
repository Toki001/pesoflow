import 'package:pesoflow/features/workspace/domain/finance_workspace.dart';
import 'package:pesoflow/features/notifications/domain/financial_notice.dart';
import 'package:pesoflow/features/notifications/domain/notice_view.dart';
import 'package:pesoflow/features/accounts/domain/financial_account.dart';

import 'finance_workspace_fixture.dart';
import 'features/subscriptions/data/subscription_fixture.dart';

FinanceWorkspace stitchV7Fixture() {
  final w = financeFixture();
  return w.copyWith(
    accounts: [
      for (final a in w.accounts)
        a.name == 'BDO Credit Card'
            ? a.copyWith(
                type: AccountType.credit,
                creditLimit: 5000000,
                cardNetwork: 'Mastercard',
                cardLastFour: '4821',
              )
            : a,
    ],
    subscriptions: subscriptionFixture(),
    notices: [
      FinancialNotice(
        id: 'budget-v7',
        title: 'Food & Dining budget update',
        message: 'Your recorded food spending is ₱325 of an ₱8,000 monthly allowance.',
        createdAt: DateTime(2024, 10, 24),
        kind: NoticeKind.budget,
        destination: NoticeDestination.budgets,
        conditionKey: 'test-budget',
      ),
      FinancialNotice(
        id: 'renewal-v7',
        title: 'Netflix Standard renewal',
        message: 'Your tracked ₱549 renewal is due on October 28. No payment is scheduled by PesoFlow.',
        createdAt: DateTime(2024, 10, 24),
        kind: NoticeKind.renewal,
        destination: NoticeDestination.subscriptions,
        conditionKey: 'test-renewal',
      ),
    ],
  );
}
