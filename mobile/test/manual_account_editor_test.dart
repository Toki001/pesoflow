import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/theme/app_theme.dart';
import 'package:pesoflow/features/accounts/presentation/manual_account_editor.dart';
import 'package:pesoflow/features/dashboard/domain/financial_dashboard.dart';
import 'package:pesoflow/features/transactions/domain/manual_transaction_draft.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/features/workspace/domain/finance_workspace.dart';

import 'support/finance_fakes.dart';

Future<void> openEditor(
  WidgetTester tester,
  FakeFinanceRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        financeRepositoryProvider.overrideWithValue(repository),
        initialWorkspaceProvider.overrideWithValue(repository.workspace),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => showManualAccountEditor(context),
              child: const Text('Open editor'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open editor'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'account form saves a real opening balance through the repository',
    (tester) async {
      final repository = FakeFinanceRepository();
      await openEditor(tester, repository);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Account name'),
        'My cash',
      );
      final opening = find.widgetWithText(
        TextFormField,
        'Starting balance (PHP)',
      );
      await tester.ensureVisible(opening);
      await tester.enterText(opening, '1250.75');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save Account'));
      await tester.pumpAndSettle();
      expect(repository.workspace.accounts.single.name, 'My cash');
      expect(repository.workspace.accounts.single.startingBalance, 125075);
      expect(find.text('Open editor'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('save failure keeps the form inputs available for retry', (
    tester,
  ) async {
    final repository = FakeFinanceRepository()..failSave = true;
    await openEditor(tester, repository);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Account name'),
      'Travel cash',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Account'));
    await tester.pumpAndSettle();
    expect(repository.workspace.accounts, isEmpty);
    expect(find.text('Travel cash'), findsOneWidget);
    repository.failSave = false;
    await tester.tap(find.text('Save Account'));
    await tester.pumpAndSettle();
    expect(repository.workspace.accounts.single.name, 'Travel cash');
  });

  test('opening balances allow exact zero and signed liabilities, never fractions of cents', () {
    expect(parseStartingBalance('0'), 0);
    expect(parseStartingBalance('-325.05'), -32505);
    expect(parseStartingBalance('1.001'), isNull);
    expect(parseStartingBalance('1e5'), isNull);
  });

  test(
    'fresh Home projection contains no financial activity or sample accounts',
    () {
      final dashboard = financialDashboard(
        FinanceWorkspace(),
        DateTime(2026, 10, 7),
      );
      expect(dashboard.balance, 0);
      expect(dashboard.inflow, 0);
      expect(dashboard.outflow, 0);
      expect(dashboard.transactions, isEmpty);
      expect(dashboard.budgets, isEmpty);
      expect(dashboard.bills, isEmpty);
      expect(dashboard.accountCount, 0);
    },
  );
}
