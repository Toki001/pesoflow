import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/app.dart';
import 'package:pesoflow/app/router.dart';
import 'package:pesoflow/features/dashboard/application/dashboard_provider.dart';
import 'package:pesoflow/features/dashboard/data/dashboard_fixture.dart';
import 'package:pesoflow/features/dashboard/domain/dashboard.dart';
import 'package:pesoflow/features/dashboard/domain/dashboard_repository.dart';

class TestRepository implements DashboardRepository {
  TestRepository(this.callback);
  final Future<Dashboard?> Function() callback;
  @override
  Future<Dashboard?> load() => callback();
}

void viewport(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> pumpHome(
  WidgetTester tester, {
  ThemeMode theme = ThemeMode.light,
  DashboardRepository? repository,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (repository != null)
          dashboardRepositoryProvider.overrideWithValue(repository),
      ],
      child: RepaintBoundary(
        key: const ValueKey('app-golden'),
        child: PesoFlowApp(themeMode: theme),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Home shows approved financial hierarchy and all lower sections',
    (tester) async {
      viewport(tester, const Size(390, 1447));
      await pumpHome(tester);
      expect(find.text('Good morning, Alex'), findsOneWidget);
      expect(
        find.textContaining('30,650.00', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('+₱45k'), findsOneWidget);
      expect(find.text('-₱16.8k'), findsOneWidget);
      expect(find.text('62.7% rate'), findsOneWidget);
      expect(find.text('Demo · Active'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
      expect(find.text('₱5,000.00'), findsOneWidget);
      expect(find.text('+₱45,000.00'), findsOneWidget);
      await tester.ensureVisible(find.text('Meralco Electric'));
      expect(tester.takeException(), isNull);
    },
  );

  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('Home ${theme.name} full-page golden', (tester) async {
      viewport(tester, const Size(390, 1447));
      await pumpHome(tester, theme: theme);
      await expectLater(
        find.byKey(const ValueKey('app-golden')),
        matchesGoldenFile('goldens/home_${theme.name}_390x1447.png'),
      );
    });
  }

  testWidgets('Home light phone golden', (tester) async {
    viewport(tester, const Size(390, 844));
    await pumpHome(tester);
    await expectLater(
      find.byKey(const ValueKey('app-golden')),
      matchesGoldenFile('goldens/home_light_390x844.png'),
    );
  });

  for (final size in [
    const Size(320, 640),
    const Size(390, 844),
    const Size(430, 932),
    const Size(844, 390),
  ]) {
    testWidgets('Home scrolls without overflow at $size', (tester) async {
      viewport(tester, size);
      await pumpHome(tester);
      await tester.ensureVisible(find.text('Meralco Electric'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const ValueKey('nav-Add')).hitTestable(),
        findsOneWidget,
      );
    });
  }

  testWidgets('large text and device safe insets remain usable', (
    tester,
  ) async {
    viewport(tester, const Size(320, 844));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.view.resetPadding);
    await pumpHome(tester);
    await tester.ensureVisible(find.text('Meralco Electric'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      tester.getTopLeft(find.text('PesoFlow')).dy,
      greaterThanOrEqualTo(44),
    );
  });

  testWidgets('tabs and section links route and preserve Home scroll', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await pumpHome(tester);
    await tester.ensureVisible(find.text('See all'));
    final scrollY = tester.getTopLeft(find.text('Recent Transactions')).dy;
    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();
    expect(find.text('October 2024'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('nav-Home')));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Recent Transactions')).dy, scrollY);
    await tester.tap(find.byKey(const ValueKey('nav-Add')));
    await tester.pumpAndSettle();
    expect(find.text('Add Expense'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav-Analytics')));
    await tester.pumpAndSettle();
    expect(find.text('Spending Trajectory'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('nav-Home')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('View all'));
    await tester.tap(find.text('View all'));
    await tester.pumpAndSettle();
    expect(find.text('Budgets'), findsNWidgets(2));
  });

  testWidgets('deep link selects corresponding branch', (tester) async {
    viewport(tester, const Size(390, 844));
    final router = createRouter(initialLocation: '/budgets');
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [routerProvider.overrideWithValue(router)],
        child: const PesoFlowApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Budgets'), findsNWidgets(2));
    await tester.tap(find.byKey(const ValueKey('nav-Home')));
    await tester.pumpAndSettle();
    expect(find.text('Good morning, Alex'), findsOneWidget);
  });

  testWidgets('loading, empty, and recoverable error states', (tester) async {
    viewport(tester, const Size(390, 844));
    final completer = Completer<Dashboard?>();
    await pumpHome(tester, repository: TestRepository(() => completer.future));
    expect(find.bySemanticsLabel('Loading financial overview'), findsOneWidget);
    completer.complete(null);
    await tester.pumpAndSettle();
    expect(find.text('No financial overview yet'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    var calls = 0;
    await pumpHome(
      tester,
      repository: TestRepository(() async {
        if (calls++ == 0) throw Exception('private internal failure');
        return homeFixture();
      }),
    );
    expect(find.text("We couldn't load your overview."), findsOneWidget);
    expect(find.textContaining('private internal'), findsNothing);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.text('Good morning, Alex'), findsOneWidget);
  });

  testWidgets('notification control explains demo data', (tester) async {
    viewport(tester, const Size(390, 844));
    await pumpHome(tester);
    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();
    expect(find.text('Demo notifications'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Demo notifications'), findsNothing);
  });
}
