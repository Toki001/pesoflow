import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/app.dart';
import 'package:pesoflow/app/router.dart';
import 'package:pesoflow/features/notifications/application/notifications_provider.dart';
import 'package:pesoflow/features/notifications/data/notification_fixture.dart';
import 'package:pesoflow/features/notifications/domain/demo_notice.dart';
import 'package:pesoflow/features/transactions/application/transactions_provider.dart';

import 'home_test.dart' show viewport;

Future<ProviderContainer> pumpInbox(
  WidgetTester tester, {
  ThemeMode theme = ThemeMode.light,
  String location = '/notifications',
  Future<List<DemoNotice>> Function()? load,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        routerProvider.overrideWith((ref) {
          final router = createRouter(initialLocation: location);
          ref.onDispose(router.dispose);
          return router;
        }),
        if (load != null) notificationLoaderProvider.overrideWithValue(load),
      ],
      child: RepaintBoundary(
        key: const ValueKey('notifications-golden'),
        child: PesoFlowApp(themeMode: theme),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(PesoFlowApp)));
}

void main() {
  test(
    'inbox sorts snapshots, enforces unique IDs, and has immutable data',
    () async {
      final container = ProviderContainer(
        overrides: [
          notificationLoaderProvider.overrideWithValue(
            () async => notificationFixture().reversed.toList(),
          ),
        ],
      );
      addTearDown(container.dispose);
      final notices = await container.read(notificationsProvider.future);
      expect(notices.first.id, 'food-limit');
      expect(notices.last.id, 'spending-review');
      expect(() => notices.clear(), throwsUnsupportedError);
      final duplicate = ProviderContainer(
        overrides: [
          notificationLoaderProvider.overrideWithValue(
            () async => [notices.first, notices.first],
          ),
        ],
      );
      addTearDown(duplicate.dispose);
      await expectLater(
        duplicate.read(notificationsProvider.future),
        throwsStateError,
      );
    },
  );

  test('read state is idempotent, reload-safe, session-only and never edits the ledger', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(notificationsProvider.future);
    final original = container.read(demoLedgerProvider);
    final read = container.read(noticeReadProvider.notifier);
    expect(container.read(unreadNoticeCountProvider), 3);
    read.setRead('missing', true);
    expect(container.read(unreadNoticeCountProvider), 3);
    read.setRead('food-limit', true);
    read.setRead('food-limit', true);
    expect(container.read(unreadNoticeCountProvider), 2);
    container.invalidate(notificationsProvider);
    await container.read(notificationsProvider.future);
    expect(container.read(unreadNoticeCountProvider), 2);
    read.markAllRead();
    read.markAllRead();
    expect(container.read(unreadNoticeCountProvider), 0);
    read.setRead('food-limit', false);
    expect(container.read(unreadNoticeCountProvider), 1);
    expect(container.read(demoLedgerProvider), same(original));
    expect(
      () => container.read(noticeReadProvider).clear(),
      throwsUnsupportedError,
    );
    final fresh = ProviderContainer();
    addTearDown(fresh.dispose);
    await fresh.read(notificationsProvider.future);
    expect(fresh.read(unreadNoticeCountProvider), 3);
  });

  testWidgets(
    'All/Unread filtering, individual and bulk read actions and caught-up state',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpInbox(tester);
      expect(find.text('3 unread · 4 sample alerts'), findsOneWidget);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Unread'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('notice-spending-review')),
        findsNothing,
      );
      await tester.ensureVisible(find.byKey(const ValueKey('read-food-limit')));
      await tester.tap(find.byKey(const ValueKey('read-food-limit')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('notice-food-limit')), findsNothing);
      await tester.ensureVisible(find.text('Mark all read'));
      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();
      expect(find.text('You’re all caught up'), findsOneWidget);
      await tester.tap(find.text('View all alerts'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('read-food-limit')));
      await tester.tap(find.byKey(const ValueKey('read-food-limit')));
      await tester.pumpAndSettle();
      expect(find.text('1 unread · 4 sample alerts'), findsOneWidget);
    },
  );

  for (final entry in {
    'food-limit': '/budgets',
    'netflix-renewal': '/budgets/subscriptions',
    'bpi-attention': '/accounts',
    'spending-review': '/analytics',
  }.entries) {
    testWidgets(
      '${entry.key} opens ${entry.value}, marks read and returns to inbox',
      (tester) async {
        viewport(tester, const Size(390, 844));
        final container = await pumpInbox(tester);
        final ledger = container.read(demoLedgerProvider);
        await tester.ensureVisible(find.byKey(ValueKey('open-${entry.key}')));
        await tester.tap(find.byKey(ValueKey('open-${entry.key}')));
        await tester.pumpAndSettle();
        final router = container.read(routerProvider);
        final title = switch (entry.key) {
          'food-limit' => 'Budgets',
          'netflix-renewal' => 'Subscriptions',
          'bpi-attention' => 'Connected Accounts',
          _ => 'Analytics',
        };
        expect(find.text(title), findsWidgets);
        expect(find.text('Demo alerts'), findsNothing);
        expect(container.read(noticeReadProvider), contains(entry.key));
        expect(container.read(demoLedgerProvider), same(ledger));
        router.pop();
        await tester.pumpAndSettle();
        expect(find.text('Demo alerts'), findsOneWidget);
        expect(
          find.byKey(ValueKey('open-${entry.key}')).hitTestable(),
          findsOneWidget,
        );
      },
    );
  }

  testWidgets(
    'Home badge clears after marking all read and remains clear on reentry',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpInbox(tester, location: '/home');
      expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isTrue);
      await tester.tap(find.byTooltip('Notifications'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isFalse);
      await tester.tap(find.byTooltip('Notifications'));
      await tester.pumpAndSettle();
      expect(find.text('0 unread · 4 sample alerts'), findsOneWidget);
    },
  );

  testWidgets(
    'Budgets bell opens inbox and direct-link Back falls back to Home',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpInbox(tester, location: '/budgets');
      await tester.tap(find.byTooltip('Notifications'));
      await tester.pumpAndSettle();
      expect(find.text('Demo alerts'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Budgets'), findsNWidgets(2));
      await tester.pumpWidget(const SizedBox());
      await pumpInbox(tester);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Good morning, Alex'), findsOneWidget);
    },
  );

  testWidgets('loading, empty and safe recoverable error states', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    final pending = Completer<List<DemoNotice>>();
    await pumpInbox(tester, load: () => pending.future);
    expect(find.bySemanticsLabel('Loading demo alerts'), findsOneWidget);
    pending.complete([]);
    await tester.pumpAndSettle();
    expect(find.text('No demo alerts'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    var calls = 0;
    await pumpInbox(
      tester,
      load: () async {
        if (calls++ == 0) throw Exception('private internal secret');
        return notificationFixture();
      },
    );
    expect(find.text("We couldn't load your sample alerts."), findsOneWidget);
    expect(find.textContaining('private internal'), findsNothing);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.text('3 unread · 4 sample alerts'), findsOneWidget);
  });

  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('Notifications ${theme.name} full-page golden', (tester) async {
      viewport(tester, const Size(390, 1480));
      await pumpInbox(tester, theme: theme);
      await expectLater(
        find.byKey(const ValueKey('notifications-golden')),
        matchesGoldenFile('goldens/notifications_${theme.name}_390x1480.png'),
      );
    });
  }

  for (final size in [
    const Size(320, 640),
    const Size(430, 932),
    const Size(844, 390),
  ]) {
    testWidgets('Notifications scrolls without overflow at $size', (
      tester,
    ) async {
      viewport(tester, size);
      await pumpInbox(tester);
      await tester.ensureVisible(
        find.byKey(const ValueKey('open-spending-review')),
      );
      expect(
        find.byKey(const ValueKey('open-spending-review')).hitTestable(),
        findsOneWidget,
      );
      expect(find.byTooltip('Back').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('200 percent text, safe insets and read controls stay usable', (
    tester,
  ) async {
    viewport(tester, const Size(320, 844));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.view.resetPadding);
    await pumpInbox(tester);
    expect(
      tester.getTopLeft(find.text('Notifications')).dy,
      greaterThanOrEqualTo(44),
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('read-spending-review')),
    );
    await tester.tap(find.byKey(const ValueKey('read-spending-review')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
