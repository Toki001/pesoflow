import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/core/platform/app_version.dart';
import 'package:pesoflow/features/settings/domain/local_preferences.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';

import 'fixtures/stitch_v7_fixture.dart';
import 'production_app_test.dart' as app;
import 'support/finance_fakes.dart';

void main() {
  test(
    'optional local preferences decode old records and roundtrip new settings',
    () {
      final old = const LocalPreferences().toJson()
        ..remove('defaultAccountId')
        ..remove('hiddenCategories');
      final decoded = LocalPreferences.fromJson(old);
      expect(decoded.defaultAccountId, '');
      expect(decoded.hiddenCategories, isEmpty);
      final newPrefs = decoded.copyWith(
        defaultAccountId: 'maya',
        hiddenCategories: [TransactionCategory.shopping],
      );
      final restored = LocalPreferences.fromJson(newPrefs.toJson());
      expect(restored.defaultAccountId, 'maya');
      expect(restored.hiddenCategories, [TransactionCategory.shopping]);
    },
  );
  testWidgets('installed version is read from native metadata', (tester) async {
    const channel = MethodChannel('com.pesoflow/app_info');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      expect(call.method, 'version');
      return {'version': '3.2.1', 'build': '42'};
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(await c.read(appVersionProvider.future), '3.2.1 (Build 42)');
  });
  testWidgets(
    'settings persist appearance, category choices and default account without identity options',
    (tester) async {
      app.viewport(tester, const Size(390, 1600));
      final repo = FakeFinanceRepository(stitchV7Fixture());
      await app.pumpApp(tester, route: '/settings', repository: repo);
      for (final text in [
        'Profile',
        'Login',
        'Backup',
        'Restore',
        'Cloud sync',
      ]) {
        expect(find.textContaining(text), findsNothing);
      }
      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('appearance-dark')));
      await tester.pumpAndSettle();
      expect(repo.workspace.preferences.appearance.name, 'dark');
      await tester.tap(find.text('Default Payment Account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Maya'));
      await tester.pumpAndSettle();
      expect(repo.workspace.preferences.defaultAccountId, 'maya');
      await tester.tap(find.text('Categories Management'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Food & Dining'));
      await tester.pumpAndSettle();
      expect(
        repo.workspace.preferences.hiddenCategories,
        contains(TransactionCategory.food),
      );
      expect(repo.workspace.ledger, stitchV7Fixture().ledger);
    },
  );
  testWidgets(
    'default account and hidden choices apply to real transaction commands',
    (tester) async {
      app.viewport(tester, const Size(390, 1600));
      final w = stitchV7Fixture();
      final repo = FakeFinanceRepository(
        w.copyWith(
          ledger: [],
          preferences: w.preferences.copyWith(
            defaultAccountId: 'maya',
            hiddenCategories: [TransactionCategory.food],
          ),
        ),
      );
      await app.pumpApp(tester, route: '/add', repository: repo);
      expect(find.text('Food & Dining'), findsNothing);
      await tester.enterText(find.byKey(const ValueKey('amount-input')), '100');
      await tester.enterText(
        find.byKey(const ValueKey('merchant-input')),
        'Actual merchant',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save Expense'));
      await tester.pumpAndSettle();
      expect(repo.workspace.ledger.single.accountId, 'maya');
      expect(
        repo.workspace.ledger.single.category,
        isNot(TransactionCategory.food),
      );
    },
  );
  testWidgets(
    'notice filters and read state save through the production command',
    (tester) async {
      app.viewport(tester, const Size(390, 1200));
      final repo = FakeFinanceRepository(stitchV7Fixture());
      final c = await app.pumpApp(
        tester,
        route: '/notifications',
        repository: repo,
      );
      await tester.tap(find.text('Budget Alerts'));
      await tester.pumpAndSettle();
      expect(find.text('Netflix Standard renewal'), findsNothing);
      expect(find.text('Food & Dining budget update'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('read-budget-v7')));
      await tester.pumpAndSettle();
      expect(c.read(workspaceProvider).noticeReadIds, contains('budget-v7'));
      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();
      expect(
        repo.workspace.noticeReadIds,
        containsAll(['budget-v7', 'renewal-v7']),
      );
    },
  );
  for (final route in [
    '/settings/backup',
    '/onboarding',
    '/login',
    '/profile',
  ]) {
    testWidgets('$route is not a product destination', (tester) async {
      await app.pumpApp(tester, route: route);
      expect(find.text('Page not found'), findsOneWidget);
    });
  }
}
