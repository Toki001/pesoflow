import 'package:pesoflow/features/accounts/domain/financial_account.dart';
import 'package:pesoflow/features/analytics/domain/analytics_report.dart';
import 'package:pesoflow/features/budgets/domain/spending_budget.dart';
import 'package:pesoflow/features/settings/domain/user_preferences.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/workspace/domain/finance_workspace.dart';

import 'features/accounts/data/ledger_account_fixture.dart';
import 'features/transactions/data/transaction_fixture.dart';

FinanceWorkspace financeFixture() => FinanceWorkspace(
  accounts: [
    for (final a in DemoLedgerAccounts.all)
      FinancialAccount(
        id: a.id,
        name: a.label,
        type: a.id == 'cash'
            ? AccountType.cash
            : a.id == 'gcash' || a.id == 'maya'
            ? AccountType.wallet
            : AccountType.bank,
        startingBalance: a.id == 'gcash' ? 500000 : 0,
        currency: 'PHP',
        createdAt: DateTime(2024, 10, 1),
      ),
  ],
  ledger: [
    for (final t in transactionFixture())
      t.copyWith(
        source: TransactionSource.manual,
        account: DemoLedgerAccounts.all
            .firstWhere((a) => a.id == t.accountId)
            .label,
        hasReceipt: false,
      ),
  ],
  budgets: [
    SpendingBudget(
      id: 'monthly',
      name: 'Monthly budget',
      limit: 2500000,
      period: AnalyticsPeriod.month,
      startDate: DateTime(2024, 10),
    ),
    SpendingBudget(
      id: 'food',
      name: 'Food & Dining',
      limit: 800000,
      period: AnalyticsPeriod.month,
      startDate: DateTime(2024, 10),
      category: TransactionCategory.food,
    ),
  ],
  preferences: const UserPreferences(onboardingCompleted: true, name: 'Alex'),
);
