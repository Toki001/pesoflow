import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/shell/app_shell.dart';

import 'fixtures/stitch_v7_fixture.dart';
import 'production_app_test.dart' as app;

void main() {
  for (final width in [320.0, 390.0]) {
    for (final populated in [false, true]) {
      testWidgets('Home metrics match at $width, populated=$populated', (
        tester,
      ) async {
        app.viewport(tester, Size(width, 844));
        await app.pumpApp(
          tester,
          workspace: populated ? stitchV7Fixture() : null,
        );
        final spending = tester.getRect(
          find.byKey(const ValueKey('flow-spending')),
        );
        final income = tester.getRect(
          find.byKey(const ValueKey('flow-income')),
        );
        expect(spending.size, income.size);
        expect(spending.top, income.top);
        expect(tester.takeException(), isNull);
      });
      testWidgets('Account summaries match at $width, populated=$populated', (
        tester,
      ) async {
        app.viewport(tester, Size(width, 844));
        await app.pumpApp(
          tester,
          route: '/accounts',
          workspace: populated ? stitchV7Fixture() : null,
        );
        expect(
          tester.getSize(
            find.byKey(const ValueKey('account-summary-Tracked Balance')),
          ),
          tester.getSize(
            find.byKey(const ValueKey('account-summary-Available Credit')),
          ),
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets(
    'each selected tab uses its filled icon and others stay outlined',
    (tester) async {
      const filled = [
        Icons.home,
        Icons.receipt_long,
        Icons.add,
        Icons.analytics,
        Icons.account_balance_wallet,
      ];
      for (final selected in [0, 1, 3, 4]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: AppBottomNavigation(
                selectedIndex: selected,
                onSelected: (_) {},
              ),
            ),
          ),
        );
        for (final index in [0, 1, 3, 4]) {
          final icon = tester.widget<Icon>(
            find.descendant(
              of: find.byKey(
                ValueKey('nav-${AppBottomNavigation.destinations[index]}'),
              ),
              matching: find.byType(Icon),
            ),
          );
          expect(
            icon.icon,
            selected == index
                ? filled[index]
                : AppBottomNavigation.icons[index],
          );
        }
      }
    },
  );
}
