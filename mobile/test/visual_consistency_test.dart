import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/shell/app_shell.dart';
import 'package:pesoflow/app/theme/app_colors.dart';
import 'package:pesoflow/core/widgets/compact_segments.dart';
import 'package:pesoflow/features/analytics/application/analytics_provider.dart';
import 'package:pesoflow/features/analytics/domain/analytics_report.dart';

import 'fixtures/stitch_v7_fixture.dart';
import 'production_app_test.dart' as app;

void main() {
  testWidgets('compact segments keep 48px targets around a slim selection', (
    tester,
  ) async {
    int? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CompactSegments<int>(
            options: const {0: 'Daily', 1: 'Weekly'},
            selected: 0,
            onSelected: (value) => selected = value,
          ),
        ),
      ),
    );
    final tap = find
        .ancestor(of: find.text('Weekly'), matching: find.byType(InkWell))
        .first;
    expect(tester.getSize(tap).height, greaterThanOrEqualTo(48));
    final pill = find
        .ancestor(of: find.text('Daily'), matching: find.byType(DecoratedBox))
        .first;
    expect(tester.getSize(pill).height, lessThan(40));
    await tester.tap(tap);
    expect(selected, 1);
  });
  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('analytics date remains usable at large text in $theme', (
      tester,
    ) async {
      app.viewport(tester, const Size(320, 844));
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final container = await app.pumpApp(
        tester,
        route: '/analytics',
        theme: theme,
      );
      final periods = tester.getRect(
        find.byKey(const ValueKey('analytics-periods')),
      );
      final date = tester.getRect(find.byKey(const ValueKey('analytics-date')));
      expect(date.top - periods.bottom, greaterThanOrEqualTo(12));
      await tester.tap(find.byKey(const ValueKey('analytics-date')));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text('23'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(container.read(analyticsSelectionProvider).date.day, 23);
      await tester.tap(find.text('Week'));
      await tester.pumpAndSettle();
      expect(
        container.read(analyticsSelectionProvider).period,
        AnalyticsPeriod.week,
      );
      expect(tester.takeException(), isNull);
    });
    testWidgets('budget filter selection remains functional in $theme', (
      tester,
    ) async {
      app.viewport(tester, const Size(390, 844));
      await app.pumpApp(
        tester,
        route: '/budgets',
        theme: theme,
        workspace: stitchV7Fixture(),
      );
      final risk = find.byKey(const ValueKey('budget-filter-atRisk'));
      await tester.ensureVisible(risk);
      await tester.tap(risk);
      await tester.pumpAndSettle();
      expect(find.text('No budgets in this filter'), findsOneWidget);
      final track = find.byKey(const ValueKey('budget-filter-onTrack'));
      await tester.ensureVisible(track);
      await tester.tap(track);
      await tester.pumpAndSettle();
      expect(find.text('No budgets in this filter'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'category tiles share a size with wrapped labels at scale $scale',
      (tester) async {
        app.viewport(tester, const Size(390, 844));
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await app.pumpApp(tester, route: '/add', workspace: stitchV7Fixture());
        final tiles = find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith('category-choice-'),
        );
        expect(tiles, findsNWidgets(6));
        final size = tester.getSize(tiles.first);
        for (var i = 0; i < 6; i++) {
          expect(tester.getSize(tiles.at(i)), size);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

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
            icon.color,
            selected == index ? Colors.white : const FinancePalette(false).icon,
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
