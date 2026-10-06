import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/app.dart';
import 'package:pesoflow/app/router.dart';
import 'package:pesoflow/features/subscriptions/application/subscriptions_provider.dart';
import 'package:pesoflow/features/subscriptions/data/subscription_fixture.dart';
import 'package:pesoflow/features/subscriptions/domain/subscription_plan.dart';
import 'package:pesoflow/features/transactions/application/transactions_provider.dart';

import 'home_test.dart' show viewport, pumpHome;

Future<void> pumpSubscriptions(
  WidgetTester tester, {
  ThemeMode theme = ThemeMode.light,
  Future<SubscriptionOverview> Function()? load,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        routerProvider.overrideWith((ref) {
          final router = createRouter(initialLocation: '/subscriptions');
          ref.onDispose(router.dispose);
          return router;
        }),
        if (load != null) subscriptionsProvider.overrideWith((ref) => load()),
      ],
      child: RepaintBoundary(
        key: const ValueKey('subscriptions-golden'),
        child: PesoFlowApp(themeMode: theme),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

ProviderContainer containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(PesoFlowApp)));
Future<void> openPlan(WidgetTester tester, String id) async {
  final card = find.byKey(ValueKey('subscription-$id'));
  await tester.ensureVisible(card);
  await tester.tap(card);
  await tester.pumpAndSettle();
}

void main() {
  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('Subscriptions ${theme.name} golden', (tester) async {
      viewport(tester, const Size(390, 1420));
      await pumpSubscriptions(tester, theme: theme);
      expect(find.text('₱1,561.83'), findsOneWidget);
      expect(find.text('5 active services'), findsOneWidget);
      expect(find.byKey(const ValueKey('nav-Budgets')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const ValueKey('subscriptions-golden')),
        matchesGoldenFile('goldens/subscriptions_${theme.name}_390x1420.png'),
      );
    });
  }
  testWidgets(
    'Home opens subscriptions in Budgets shell and tabs preserve tracking',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpHome(tester);
      await tester.ensureVisible(
        find.byKey(const ValueKey('open-subscriptions')),
      );
      await tester.tap(find.byKey(const ValueKey('open-subscriptions')));
      await tester.pumpAndSettle();
      expect(find.text('Subscriptions'), findsOneWidget);
      await openPlan(tester, 'netflix');
      await tester.tap(find.text('Pause tracking'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('nav-Analytics')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('nav-Budgets')));
      await tester.pumpAndSettle();
      expect(find.text('Subscriptions'), findsOneWidget);
      expect(
        containerOf(tester).read(demoSubscriptionsProvider).first.active,
        false,
      );
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('MONTHLY BUDGET'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('nav-Home')));
      await tester.pumpAndSettle();
      expect(find.text('Good morning, Alex'), findsOneWidget);
    },
  );
  testWidgets('Subscriptions at Stitch reference viewport', (tester) async {
    viewport(tester, const Size(390, 1205));
    await pumpSubscriptions(tester);
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(const ValueKey('subscriptions-golden')),
      matchesGoldenFile('goldens/subscriptions_light_390x1205.png'),
    );
  });
  testWidgets('cancel is inert; yearly cadence and chosen renewal persist', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await pumpSubscriptions(tester);
    final c = containerOf(tester);
    final before = c.read(demoSubscriptionsProvider);
    await tester.tap(find.byKey(const ValueKey('add-subscription')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('subscription-name')),
      'Discarded',
    );
    await tester.ensureVisible(find.text('Cancel'));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(c.read(demoSubscriptionsProvider), same(before));
    await openPlan(tester, 'netflix');
    await tester.tap(find.text('Edit plan'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('subscription-cycle')),
    );
    await tester.tap(find.byKey(const ValueKey('subscription-cycle')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('yearly').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('subscription-renewal')),
    );
    await tester.tap(find.byKey(const ValueKey('subscription-renewal')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Switch to input'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(DatePickerDialog),
        matching: find.byType(TextField),
      ),
      '11/30/2024',
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save subscription'));
    await tester.tap(find.text('Save subscription'));
    await tester.pumpAndSettle();
    final edited = c.read(demoSubscriptionsProvider).first;
    expect(edited.cycle, BillingCycle.yearly);
    expect(edited.nextRenewal, DateTime(2024, 11, 30));
    expect(edited.annualized, 54900);
    expect(edited.monthlyEquivalent, 4575);
  });
  testWidgets('direct link Back opens parent Budgets', (tester) async {
    await pumpSubscriptions(tester);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('MONTHLY BUDGET'), findsOneWidget);
  });
  testWidgets(
    'form validates exact money; creates and edits without posting expenses',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpSubscriptions(tester);
      final container = containerOf(tester);
      final ledger = container.read(demoLedgerProvider);
      await tester.tap(find.byKey(const ValueKey('add-subscription')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Save subscription'));
      await tester.tap(find.text('Save subscription'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a service name.'), findsOneWidget);
      expect(
        find.text('Enter a positive amount with up to 2 decimals.'),
        findsOneWidget,
      );
      await tester.enterText(
        find.byKey(const ValueKey('subscription-name')),
        '😀' * 80,
      );
      await tester.ensureVisible(find.text('Save subscription'));
      await tester.tap(find.text('Save subscription'));
      await tester.pumpAndSettle();
      expect(find.text('Use a shorter service name.'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('subscription-name')),
        'Local Plan',
      );
      await tester.enterText(
        find.byKey(const ValueKey('subscription-amount')),
        '12.345',
      );
      await tester.ensureVisible(find.text('Save subscription'));
      await tester.tap(find.text('Save subscription'));
      await tester.pumpAndSettle();
      expect(container.read(demoSubscriptionsProvider).length, 5);
      await tester.enterText(
        find.byKey(const ValueKey('subscription-amount')),
        '12.34',
      );
      await tester.ensureVisible(find.text('Save subscription'));
      await tester.tap(find.text('Save subscription'));
      await tester.pumpAndSettle();
      final added = container.read(demoSubscriptionsProvider).last;
      expect(added.amount, 1234);
      expect(added.origin, SubscriptionOrigin.manual);
      await openPlan(tester, added.id);
      await tester.tap(find.text('Edit plan'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('subscription-amount')),
        '20.01',
      );
      await tester.ensureVisible(find.text('Save subscription'));
      await tester.tap(find.text('Save subscription'));
      await tester.pumpAndSettle();
      expect(container.read(demoSubscriptionsProvider).last.amount, 2001);
      expect(container.read(demoLedgerProvider), same(ledger));
    },
  );
  testWidgets(
    'pause/resume updates totals and tip; removal requires confirmation',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpSubscriptions(tester);
      await openPlan(tester, 'icloud');
      await tester.tap(find.text('Pause tracking'));
      await tester.pumpAndSettle();
      expect(find.text('Intelligence Tip'), findsNothing);
      expect(
        containerOf(tester).read(demoSubscriptionsProvider)[3].active,
        false,
      );
      await openPlan(tester, 'icloud');
      await tester.tap(find.text('Resume tracking'));
      await tester.pumpAndSettle();
      expect(find.text('Intelligence Tip'), findsOneWidget);
      await openPlan(tester, 'icloud');
      await tester.tap(find.text('Remove plan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep plan'));
      await tester.pumpAndSettle();
      expect(containerOf(tester).read(demoSubscriptionsProvider).length, 5);
      await tester.tap(find.text('Remove plan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove tracking'));
      await tester.pumpAndSettle();
      expect(containerOf(tester).read(demoSubscriptionsProvider).length, 4);
    },
  );
  testWidgets('sort by name persists across tabs', (tester) async {
    viewport(tester, const Size(390, 844));
    await pumpSubscriptions(tester);
    await tester.ensureVisible(find.text('Sort by Date'));
    await tester.tap(find.text('Sort by Date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sort by name'));
    await tester.pumpAndSettle();
    expect(
      containerOf(tester).read(subscriptionSortProvider),
      SubscriptionSort.name,
    );
    await tester.tap(find.byKey(const ValueKey('nav-Home')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav-Budgets')));
    await tester.pumpAndSettle();
    expect(find.text('Sort by Name'), findsOneWidget);
  });
  testWidgets(
    'history contains observed charge; opens detail; empty after unflagging',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpSubscriptions(tester);
      await tester.ensureVisible(
        find.byKey(const ValueKey('subscription-history')),
      );
      await tester.tap(find.byKey(const ValueKey('subscription-history')));
      await tester.pumpAndSettle();
      expect(find.text('Netflix Subscription'), findsOneWidget);
      await tester.tap(find.text('Netflix Subscription'));
      await tester.pumpAndSettle();
      expect(find.text('Transaction Detail'), findsOneWidget);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      final c = containerOf(tester);
      final record = c
          .read(demoLedgerProvider)
          .firstWhere((t) => t.id == 'netflix');
      c
          .read(demoLedgerProvider.notifier)
          .update(record.copyWith(recurring: false));
      await tester.ensureVisible(
        find.byKey(const ValueKey('subscription-history')),
      );
      await tester.tap(find.byKey(const ValueKey('subscription-history')));
      await tester.pumpAndSettle();
      expect(find.text('No recorded recurring charges'), findsOneWidget);
    },
  );
  testWidgets('loading, safe error retry and empty state', (tester) async {
    final gate = Completer<SubscriptionOverview>();
    await pumpSubscriptions(tester, load: () => gate.future);
    expect(find.bySemanticsLabel('Loading subscriptions'), findsOneWidget);
    gate.complete(SubscriptionOverview(subscriptionFixture()));
    await tester.pumpAndSettle();
    expect(find.text('Netflix Standard'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    var calls = 0;
    await pumpSubscriptions(
      tester,
      load: () async {
        if (calls++ == 0) throw Exception('private data');
        return SubscriptionOverview([]);
      },
    );
    expect(find.text("We couldn't load your subscriptions."), findsOneWidget);
    expect(find.textContaining('private data'), findsNothing);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.text('No subscriptions tracked'), findsOneWidget);
  });
  for (final size in [
    const Size(320, 844),
    const Size(430, 932),
    const Size(844, 390),
  ]) {
    testWidgets('subscription screen and details scroll at $size', (
      tester,
    ) async {
      viewport(tester, size);
      await pumpSubscriptions(tester);
      await openPlan(tester, 'disney');
      await tester.ensureVisible(find.text('Close'));
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    '200 percent text, safe insets, keyboard and form remain usable',
    (tester) async {
      viewport(tester, const Size(320, 844));
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(tester.view.resetPadding);
      await pumpSubscriptions(tester);
      await openPlan(tester, 'netflix');
      await tester.ensureVisible(find.text('Close'));
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('add-subscription')));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Cancel').hitTestable(), findsOneWidget);
    },
  );
}
