import 'package:pesoflow/features/dashboard/domain/dashboard.dart';
import 'package:pesoflow/features/dashboard/domain/dashboard_repository.dart';

/// Stitch's October 2024 snapshot, deliberately independent of the device clock.
Dashboard homeFixture() => Dashboard(
  name: 'Alex',
  asOf: DateTime(2024, 10, 24, 12, 34),
  balance: 3065000,
  monthChange: 243000,
  monthChangePercent: '8.6',
  inflow: 4500000,
  outflow: 1680000,
  savings: 2820000,
  savingsRate: '62.7',
  transactionCount: 38,
  accountCount: 3,
  budgetLimit: 2500000,
  daysLeft: 8,
  projectedExtraSavings: 320000,
  budgets: const [
    BudgetSnapshot(
      name: 'Food & Dining',
      spent: 690000,
      limit: 800000,
      status: 'Slow down slightly',
    ),
    BudgetSnapshot(
      name: 'Shopping',
      spent: 340000,
      limit: 500000,
      status: 'Healthy',
    ),
    BudgetSnapshot(
      name: 'Transport',
      spent: 215000,
      limit: 350000,
      status: 'On budget',
    ),
  ],
  transactions: [
    TransactionRecord(
      id: 'jollibee',
      merchant: 'Jollibee',
      metadata: 'Food & Dining · GCash',
      amount: 32500,
      occurredAt: DateTime(2024, 10, 24, 12, 32),
      kind: TransactionKind.expense,
      category: TransactionCategory.food,
    ),
    TransactionRecord(
      id: 'grab',
      merchant: 'Grab Car',
      metadata: 'Transport · Maya',
      amount: 21000,
      occurredAt: DateTime(2024, 10, 24, 8, 15),
      kind: TransactionKind.expense,
      category: TransactionCategory.transport,
    ),
    TransactionRecord(
      id: 'transfer',
      merchant: 'BDO Savings → GCash',
      metadata: 'Account Transfer',
      amount: 500000,
      occurredAt: DateTime(2024, 10, 23, 16, 10),
      kind: TransactionKind.transfer,
      category: TransactionCategory.transfer,
    ),
    TransactionRecord(
      id: 'salary',
      merchant: 'Monthly Salary (Acme Corp)',
      metadata: 'Income · BDO',
      amount: 4500000,
      occurredAt: DateTime(2024, 10, 20, 9),
      kind: TransactionKind.income,
      category: TransactionCategory.income,
    ),
  ],
  bills: const [
    UpcomingBill(name: 'Spotify Family', amount: 19400, daysUntilDue: 1),
    UpcomingBill(
      name: 'Meralco Electric',
      amount: 342000,
      daysUntilDue: 4,
      estimated: true,
    ),
  ],
);

class FixtureDashboardRepository implements DashboardRepository {
  const FixtureDashboardRepository();
  @override
  Future<Dashboard?> load() async => homeFixture();
}
