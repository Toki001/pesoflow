import '../../transactions/domain/transaction.dart';
import '../domain/budget_plan.dart';

BudgetPlan budgetFixture() => const BudgetPlan(
  year: 2024,
  month: 10,
  monthlyLimit: 2500000,
  spent: 1680000,
  projectedAdditional: 560000,
  allowances: [
    BudgetAllowance(
      category: TransactionCategory.food,
      description: 'Groceries, delivery, cafes',
      limit: 800000,
      spent: 690000,
      projectedAdditional: 145000,
    ),
    BudgetAllowance(
      category: TransactionCategory.shopping,
      description: 'Personal, gadgets & clothing',
      limit: 500000,
      spent: 340000,
    ),
    BudgetAllowance(
      category: TransactionCategory.transport,
      description: 'Ride hailing, fuel, tolls',
      limit: 250000,
      spent: 215000,
    ),
    BudgetAllowance(
      category: TransactionCategory.bills,
      description: 'Electricity, water, fiber internet',
      limit: 250000,
      spent: 200000,
      settled: true,
      projectedAdditional: 0,
    ),
    BudgetAllowance(
      category: TransactionCategory.subscriptions,
      description: 'Netflix, Spotify, Cloud storage',
      limit: 160000,
      spent: 155000,
      fixed: true,
      projectedAdditional: 0,
    ),
    BudgetAllowance(
      category: TransactionCategory.entertainment,
      description: 'Movies, outings & games',
      limit: 200000,
      spent: 80000,
    ),
  ],
);
