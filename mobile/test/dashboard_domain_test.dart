import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/core/formatting/date_formatter.dart';
import 'package:pesoflow/core/formatting/money_formatter.dart';
import 'package:pesoflow/features/dashboard/data/dashboard_fixture.dart';
import 'package:pesoflow/features/dashboard/domain/dashboard.dart';

void main() {
  test('fixture JSON round trip preserves integer money, dates and types', () {
    final fixture = homeFixture();
    expect(
      Dashboard.fromJson(
        jsonDecode(jsonEncode(fixture)) as Map<String, dynamic>,
      ),
      fixture,
    );
    expect(fixture.balance, 3065000);
    expect(fixture.inflow - fixture.outflow, fixture.savings);
  });
  test('PHP formatting preserves cents, signs and separators', () {
    expect(MoneyFormatter.php(3065000), '₱30,650.00');
    expect(MoneyFormatter.php(-32500), '-₱325.00');
    expect(MoneyFormatter.php(4500000, signed: true), '+₱45,000.00');
    expect(MoneyFormatter.php(1), '₱0.01');
    expect(MoneyFormatter.php(-1), '-₱0.01');
    expect(MoneyFormatter.compact(4500000, signed: true), '+₱45k');
    expect(MoneyFormatter.compact(-1680000), '-₱16.8k');
  });
  test(
    'transfers and income do not count as expenses; refunds offset purchases',
    () {
      final transactions = homeFixture().transactions;
      expect(transactions[0].expenseImpact, 32500);
      expect(transactions[2].expenseImpact, 0);
      expect(transactions[3].expenseImpact, 0);
      final purchase = transactions.first.copyWith(amount: 50000);
      final refund = purchase.copyWith(kind: TransactionKind.refund);
      expect(purchase.expenseImpact + refund.expenseImpact, 0);
    },
  );
  test('budget utilization and remaining use integer monetary inputs', () {
    final food = homeFixture().budgets.first;
    expect(food.used, .8625);
    expect(food.remaining, 110000);
    expect(food.approaching, isTrue);
    expect(food.exceeded, isFalse);
    expect(food.copyWith(limit: 0).used, 0);
    expect(food.copyWith(spent: 800000).exceeded, isTrue);
  });
  test('demo dates do not depend on current time or host timezone', () {
    final fixture = homeFixture();
    expect(DateFormatter.header(fixture.asOf), 'Thursday, Oct 24');
    expect(
      DateFormatter.transaction(
        fixture.transactions.first.occurredAt,
        fixture.asOf,
      ),
      'Today, 12:32 PM',
    );
    expect(
      DateFormatter.transaction(
        fixture.transactions[2].occurredAt,
        fixture.asOf,
      ),
      'Yesterday',
    );
  });
}
