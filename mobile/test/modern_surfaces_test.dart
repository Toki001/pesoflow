import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/core/widgets/finance_card.dart';
import 'package:pesoflow/app/theme/app_theme.dart';
import 'package:pesoflow/app/theme/app_colors.dart';
import 'package:pesoflow/core/widgets/frosted_panel.dart';
import 'package:pesoflow/features/dashboard/presentation/widgets/balance_summary.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';

import 'fixtures/finance_workspace_fixture.dart';
import 'fixtures/stitch_v7_fixture.dart';
import 'production_app_test.dart' as app;

double contrast(Color a, Color b) {
  final x = a.computeLuminance();
  final y = b.computeLuminance();
  return ((x > y ? x : y) + .05) / ((x > y ? y : x) + .05);
}

void main() {
  test('header icon wells preserve readable brand blue in both themes', () {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      final background = theme.iconButtonTheme.style!.backgroundColor!.resolve(
        {},
      )!;
      expect(contrast(AppColors.primary, background), greaterThanOrEqualTo(3));
    }
  });
  testWidgets(
    'gradient balance text remains readable for positive and negative cashflow',
    (tester) async {
      final negative = financeFixture();
      for (final workspace in [
        stitchV7Fixture(),
        negative.copyWith(
          ledger: negative.ledger.where(
            (t) => t.kind == TransactionKind.expense,
          ),
        ),
      ]) {
        await app.pumpApp(tester, workspace: workspace);
        final hero = find.byType(BalanceHero);
        final card = tester.widget<FinanceCard>(
          find.descendant(of: hero, matching: find.byType(FinanceCard)),
        );
        final gradient = card.gradient! as LinearGradient;
        final texts = tester.widgetList<Text>(
          find.descendant(of: hero, matching: find.byType(Text)),
        );
        for (final text in texts) {
          final foreground = text.style!.color!;
          for (final stop in gradient.colors) {
            expect(contrast(foreground, stop), greaterThanOrEqualTo(4.5));
          }
        }
      }
    },
  );
  testWidgets('floating panel becomes opaque without blur in high contrast', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(highContrast: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await app.pumpApp(tester);
    final filter = tester.widget<BackdropFilter>(
      find.descendant(
        of: find.byType(FrostedPanel),
        matching: find.byType(BackdropFilter),
      ),
    );
    expect(filter.enabled, isFalse);
    final surfaces = tester.widgetList<DecoratedBox>(
      find.descendant(
        of: find.byType(FrostedPanel),
        matching: find.byType(DecoratedBox),
      ),
    );
    final fill = surfaces
        .map((w) => w.decoration)
        .whereType<BoxDecoration>()
        .where((d) => d.gradient != null)
        .first;
    expect(fill.gradient!.colors.every((c) => c.a == 1), isTrue);
  });
}
