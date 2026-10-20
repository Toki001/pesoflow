import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/core/widgets/category_icon.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';

import 'fixtures/finance_workspace_fixture.dart';
import 'production_app_test.dart' as app;

void main() {
  for (final route in ['/home', '/transactions', '/transactions/test-health']) {
    testWidgets('$route uses specific healthcare and entertainment glyphs', (
      tester,
    ) async {
      app.viewport(tester, const Size(390, 1700));
      final seed = financeFixture();
      final template = seed.ledger.first;
      final workspace = seed.copyWith(
        ledger: [
          template.copyWith(
            id: 'test-health',
            merchant: 'Test clinic',
            category: TransactionCategory.healthcare,
            kind: TransactionKind.expense,
          ),
          template.copyWith(
            id: 'test-play',
            merchant: 'Test entertainment',
            category: TransactionCategory.entertainment,
            kind: TransactionKind.expense,
          ),
        ],
      );
      await app.pumpApp(tester, route: route, workspace: workspace);
      expect(find.byIcon(Icons.medical_services_outlined), findsOneWidget);
      if (route != '/transactions/test-health') {
        expect(find.byIcon(Icons.sports_esports_outlined), findsOneWidget);
      }
      final badge = tester.widget<CategoryIcon>(
        find
            .ancestor(
              of: find.byIcon(Icons.medical_services_outlined),
              matching: find.byType(CategoryIcon),
            )
            .first,
      );
      expect(badge.round, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
}
