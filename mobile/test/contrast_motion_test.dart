import 'dart:async';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/theme/app_colors.dart';
import 'package:pesoflow/app/theme/app_theme.dart';
import 'package:pesoflow/app/shell/app_shell.dart';
import 'package:pesoflow/app/router.dart';
import 'package:pesoflow/core/widgets/category_icon.dart';

import 'production_app_test.dart' as app;

double contrast(Color a, Color b) {
  final x = a.computeLuminance();
  final y = b.computeLuminance();
  return ((x > y ? x : y) + .05) / ((x > y ? y : x) + .05);
}

void main() {
  for (final dark in [false, true]) {
    test('semantic foregrounds contrast on surfaces and badges dark=$dark', () {
      final c = FinancePalette(dark);
      for (final (fg, soft) in [
        (c.positive, AppColors.positiveSoft),
        (c.warning, AppColors.warningSoft),
        (c.danger, AppColors.dangerSoft),
        (c.primary, AppColors.primarySoft),
      ]) {
        for (final bg in [
          c.surface,
          c.canvas,
          c.mutedSurface,
          Color.alphaBlend(c.soft(fg, soft), c.surface),
        ]) {
          expect(
            contrast(fg, bg),
            greaterThanOrEqualTo(4.5),
            reason: '$fg on $bg',
          );
        }
      }
      for (final bg in [
        c.surface,
        c.mutedSurface,
        AppColors.primarySoft,
        c.soft(c.primary, AppColors.primarySoft),
      ]) {
        expect(
          contrast(c.iconOn(bg), Color.alphaBlend(bg, c.surface)),
          greaterThanOrEqualTo(3),
        );
      }
    });
  }
  testWidgets(
    'dark badges use readable blue while pale badges retain brand blue',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: Row(
              children: [
                CategoryIcon(
                  Icons.home,
                  foreground: AppColors.primary,
                  background: AppColors.darkSurfaceMuted,
                ),
                CategoryIcon(
                  Icons.home,
                  foreground: AppColors.primary,
                  background: AppColors.primarySoft,
                ),
              ],
            ),
          ),
        ),
      );
      final icons = tester.widgetList<Icon>(find.byIcon(Icons.home)).toList();
      expect(icons[0].color, AppColors.darkIcon);
      expect(icons[1].color, AppColors.primary);
    },
  );
  testWidgets(
    'navigation announces one label, selected state and actionable tap',
    (tester) async {
      final handle = tester.ensureSemantics();
      try {
        int? tapped;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: AppBottomNavigation(
                selectedIndex: 0,
                onSelected: (i) => tapped = i,
              ),
            ),
          ),
        );
        for (final label in AppBottomNavigation.destinations) {
          final finder = find.bySemanticsLabel(label);
          expect(finder, findsOneWidget);
          final data = tester.getSemantics(finder).getSemanticsData();
          expect(data.hasAction(SemanticsAction.tap), isTrue);
          expect(data.flagsCollection.isButton, isTrue);
          expect(
            data.flagsCollection.isSelected == Tristate.isTrue,
            label == 'Home',
          );
        }
        tester.binding.renderViews.single.owner!.semanticsOwner!.performAction(
          tester.getSemantics(find.bySemanticsLabel('Budgets')).id,
          SemanticsAction.tap,
        );
        expect(tapped, 4);
      } finally {
        handle.dispose();
      }
    },
  );
  testWidgets('main and task titles expose heading semantics', (tester) async {
    final handle = tester.ensureSemantics();
    try {
      final container = await app.pumpApp(tester);
      expect(
        tester
            .getSemantics(find.text('PesoFlow'))
            .getSemanticsData()
            .flagsCollection
            .isHeader,
        isTrue,
      );
      unawaited(container.read(routerProvider).push('/settings'));
      await tester.pumpAndSettle();
      expect(
        tester
            .getSemantics(find.text('Settings'))
            .getSemanticsData()
            .flagsCollection
            .isHeader,
        isTrue,
      );
    } finally {
      handle.dispose();
    }
  });
  for (final reduce in [false, true]) {
    testWidgets('system reduced motion=$reduce controls route and sheet', (
      tester,
    ) async {
      app.viewport(tester, const Size(390, 844));
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          FakeAccessibilityFeatures(disableAnimations: reduce);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final container = await app.pumpApp(tester);
      final context = tester.element(find.byType(AppBottomNavigation));
      final builder = Theme.of(context)
          .pageTransitionsTheme
          .builders[TargetPlatform.android]!;
      expect(builder.transitionDuration == Duration.zero, reduce);
      unawaited(container.read(routerProvider).push('/settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();
      final sheetContext = tester.element(
        find.byKey(const ValueKey('appearance-light')),
      );
      final route = ModalRoute.of(sheetContext)! as ModalBottomSheetRoute;
      expect(route.transitionDuration == Duration.zero, reduce);
      Navigator.of(sheetContext).pop();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('appearance-light')), findsNothing);
      container.read(routerProvider).pop();
      await tester.pumpAndSettle();
      expect(find.byType(AppBottomNavigation), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
