import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/theme/app_materials.dart';
import 'package:pesoflow/app/theme/app_theme.dart';
import 'package:pesoflow/core/widgets/account_badge.dart';
import 'package:pesoflow/features/accounts/domain/financial_account.dart';

import 'modern_surfaces_test.dart' show contrast;

FinancialAccount account(
  String name, {
  String institution = '',
  bool cash = false,
}) => FinancialAccount(
  id: 'test',
  name: name,
  institution: institution,
  type: cash ? AccountType.cash : AccountType.wallet,
  startingBalance: 0,
  currency: 'PHP',
  createdAt: DateTime(2024, 10),
);

void main() {
  test('Dark uses the same ambient composition as Light', () {
    final light = AppMaterials.backdropGlows(false);
    final dark = AppMaterials.backdropGlows(true);
    expect(dark.length, light.length);
    for (var i = 0; i < light.length; i++) {
      expect(dark[i].center, light[i].center);
      expect(dark[i].radius, light[i].radius);
      expect(dark[i].stops, light[i].stops);
    }
  });

  for (final dark in [false, true]) {
    testWidgets('account badges retain identity and contrast, dark=$dark', (
      tester,
    ) async {
      for (final (a, letters) in [
        (account('BDO Savings'), 'BDO'),
        (account('Personal', institution: 'GCash'), 'G'),
        (account('GoTyme Bank'), 'GT'),
        (account('Maya wallet'), 'M'),
        (account('PayMaya'), 'M'),
        (account('BPI savings'), 'BPI'),
        (account('BDO nickname', institution: 'Independent Bank'), 'IB'),
        (account('BDOodle'), 'B'),
        (account('Cash', cash: true), null),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            home: Scaffold(body: AccountBadge(account: a)),
          ),
        );
        final badge = find.byType(AccountBadge);
        expect(tester.getSize(badge), const Size(40, 40));
        if (letters == null) {
          expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
        } else {
          expect(find.text(letters), findsOneWidget);
        }
        final decoration =
            tester
                    .widget<DecoratedBox>(
                      find.descendant(
                        of: badge,
                        matching: find.byType(DecoratedBox),
                      ),
                    )
                    .decoration
                as BoxDecoration;
        expect(
          contrast(Colors.white, decoration.color!),
          greaterThanOrEqualTo(letters == null ? 3 : 4.5),
        );
        expect(tester.takeException(), isNull);
      }
    });
  }
}
