// Test executable for an isolated simulator with an empty workspace.
// Never imported by production code; refuses to change existing user data.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pesoflow/core/storage/finance_database.dart';
import 'package:pesoflow/core/storage/financial_cipher.dart';
import 'package:pesoflow/features/accounts/domain/financial_account.dart';
import 'package:pesoflow/features/analytics/domain/analytics_report.dart';
import 'package:pesoflow/features/budgets/domain/spending_budget.dart';
import 'package:pesoflow/features/settings/domain/appearance.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/features/workspace/data/sqlite_finance_repository.dart';
import 'package:pesoflow/main.dart' as app;

Future<void> main() async {
  if (!const bool.fromEnvironment('PESOFLOW_STORAGE_SMOKE')) {
    throw StateError(
      'Use an isolated simulator and explicitly enable this test.',
    );
  }
  WidgetsFlutterBinding.ensureInitialized();
  final repository = SqliteFinanceRepository(
    FinanceDatabase(),
    FinancialCipher(SecureEncryptionKeyStore()),
  );
  final initial = await repository.load();
  if (initial.accounts.isNotEmpty ||
      initial.ledger.isNotEmpty ||
      initial.budgets.isNotEmpty ||
      initial.subscriptions.isNotEmpty ||
      initial.receipts.isNotEmpty ||
      initial.preferences.onboardingCompleted) {
    await repository.close();
    throw StateError(
      'Refusing to seed a nonempty workspace. Nothing was changed.',
    );
  }
  final container = ProviderContainer(
    overrides: [
      financeRepositoryProvider.overrideWithValue(repository),
      initialWorkspaceProvider.overrideWithValue(initial),
    ],
  );
  final commands = container.read(financeControllerProvider.notifier);
  final now = DateTime.now();
  await commands.saveAccount(
    FinancialAccount(
      id: 'native-smoke-cash',
      name: 'Persistence test cash',
      type: AccountType.cash,
      startingBalance: 100000,
      currency: 'PHP',
      createdAt: now,
    ),
  );
  await commands.saveTransaction(
    TransactionRecord(
      id: 'native-smoke-expense',
      merchant: 'Persistence test lunch',
      metadata: 'Food & Dining · Persistence test cash',
      amount: 32525,
      occurredAt: now,
      kind: TransactionKind.expense,
      category: TransactionCategory.food,
      account: 'Persistence test cash',
      accountId: 'native-smoke-cash',
    ),
  );
  await commands.saveBudget(
    SpendingBudget(
      id: 'native-smoke-budget',
      name: 'Monthly budget',
      limit: 500000,
      period: AnalyticsPeriod.month,
      startDate: DateTime(now.year, now.month),
    ),
  );
  await commands.savePreferences(
    initial.preferences.copyWith(
      onboardingCompleted: true,
      appearance: Appearance.dark,
    ),
  );
  await commands.flush();
  container.dispose();
  await repository.close();
  await app.main();
}
