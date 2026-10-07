import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/app.dart';
import 'package:pesoflow/app/router.dart';
import 'package:pesoflow/features/settings/application/settings_provider.dart';
import 'package:pesoflow/features/settings/domain/appearance.dart';
import 'package:pesoflow/features/transactions/application/transactions_provider.dart';
import 'package:pesoflow/features/transactions/domain/transaction_query.dart';

import 'home_test.dart' show viewport;

Future<ProviderContainer> pumpSettings(
  WidgetTester tester, {
  String location = '/settings',
  Appearance appearance = Appearance.system,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        routerProvider.overrideWith((ref) {
          final router = createRouter(initialLocation: location);
          ref.onDispose(router.dispose);
          return router;
        }),
      ],
      child: const RepaintBoundary(
        key: ValueKey('settings-golden'),
        child: PesoFlowApp(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(PesoFlowApp)),
  );
  container.read(settingsProvider.notifier).setAppearance(appearance);
  await tester.pumpAndSettle();
  return container;
}

Brightness brightness(WidgetTester tester) =>
    Theme.of(tester.element(find.text('Settings').last)).brightness;

void main() {
  test('appearance is session-only and restores the system default', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(settingsProvider), Appearance.system);
    container.read(settingsProvider.notifier).setAppearance(Appearance.dark);
    expect(container.read(settingsProvider), Appearance.dark);
    container.read(settingsProvider.notifier).restoreAppearance();
    expect(container.read(settingsProvider), Appearance.system);
    container.read(settingsProvider.notifier).setAppearance(Appearance.light);
    final fresh = ProviderContainer();
    addTearDown(fresh.dispose);
    expect(fresh.read(settingsProvider), Appearance.system);
  });

  testWidgets(
    'Home avatar opens Settings and appearance changes preserve route and demo state',
    (tester) async {
      viewport(tester, const Size(390, 844));
      final container = await pumpSettings(tester, location: '/home');
      final original = container.read(demoLedgerProvider);
      container
          .read(demoLedgerProvider.notifier)
          .update(original.first.copyWith(note: 'Edited in this session'));
      container
          .read(transactionQueryProvider.notifier)
          .set(const TransactionQuery(search: 'Jollibee'));
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Make PesoFlow comfortable'), findsOneWidget);
      final router = container.read(routerProvider);
      await tester.tap(find.byKey(const ValueKey('appearance-dark')));
      await tester.pumpAndSettle();
      expect(brightness(tester), Brightness.dark);
      expect(container.read(routerProvider), same(router));
      expect(
        container.read(demoLedgerProvider).first.note,
        'Edited in this session',
      );
      expect(container.read(transactionQueryProvider).search, 'Jollibee');
      await tester.tap(find.byKey(const ValueKey('appearance-light')));
      await tester.pumpAndSettle();
      expect(brightness(tester), Brightness.light);
      await tester.ensureVisible(find.text('Restore device appearance'));
      await tester.tap(find.text('Restore device appearance'));
      await tester.pumpAndSettle();
      expect(container.read(settingsProvider), Appearance.system);
      expect(
        container.read(demoLedgerProvider).first.note,
        'Edited in this session',
      );
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Good morning, Alex'), findsOneWidget);
    },
  );

  testWidgets(
    'System follows device brightness and a manual choice stays fixed',
    (tester) async {
      viewport(tester, const Size(390, 844));
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await pumpSettings(tester);
      expect(brightness(tester), Brightness.light);
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pumpAndSettle();
      expect(brightness(tester), Brightness.dark);
      await tester.tap(find.byKey(const ValueKey('appearance-light')));
      await tester.pumpAndSettle();
      expect(brightness(tester), Brightness.light);
      await tester.tap(find.byKey(const ValueKey('appearance-system')));
      await tester.pumpAndSettle();
      expect(brightness(tester), Brightness.dark);
    },
  );

  testWidgets(
    'sample accounts and introduction links retain the Settings back stack',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpSettings(tester);
      await tester.ensureVisible(find.text('Sample accounts'));
      await tester.tap(find.text('Sample accounts'));
      await tester.pumpAndSettle();
      expect(find.text('Connected Accounts'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('View introduction'));
      await tester.tap(find.text('View introduction'));
      await tester.pumpAndSettle();
      expect(find.text('Understand your money'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Make PesoFlow comfortable'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Good morning, Alex'), findsOneWidget);
    },
  );

  for (final appearance in [Appearance.light, Appearance.dark]) {
    testWidgets('Settings ${appearance.name} full-page golden', (tester) async {
      viewport(tester, const Size(390, 1100));
      await pumpSettings(tester, appearance: appearance);
      await expectLater(
        find.byKey(const ValueKey('settings-golden')),
        matchesGoldenFile('goldens/settings_${appearance.name}_390x1100.png'),
      );
    });
  }

  for (final size in [
    const Size(320, 640),
    const Size(430, 932),
    const Size(844, 390),
  ]) {
    testWidgets('Settings scrolls and controls remain usable at $size', (
      tester,
    ) async {
      viewport(tester, size);
      await pumpSettings(tester);
      await tester.ensureVisible(find.byKey(const ValueKey('appearance-dark')));
      await tester.tap(find.byKey(const ValueKey('appearance-dark')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Restore device appearance'));
      await tester.tap(find.text('Restore device appearance'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byTooltip('Back').hitTestable(), findsOneWidget);
    });
  }

  testWidgets(
    'large text and safe insets preserve scrollable choices and data copy',
    (tester) async {
      viewport(tester, const Size(320, 844));
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(tester.view.resetPadding);
      await pumpSettings(tester);
      expect(
        tester.getTopLeft(find.text('Settings')).dy,
        greaterThanOrEqualTo(44),
      );
      await tester.ensureVisible(find.byKey(const ValueKey('appearance-dark')));
      await tester.tap(find.byKey(const ValueKey('appearance-dark')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Restore device appearance'));
      expect(
        find.text('Restore device appearance').hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'appearance choices expose selected state and a screen reader action',
    (tester) async {
      viewport(tester, const Size(390, 844));
      final semantics = tester.ensureSemantics();
      try {
        await pumpSettings(tester);
        expect(
          tester.getSemantics(find.bySemanticsLabel('System appearance')),
          matchesSemantics(
            label: 'System appearance',
            hint: Appearance.system.description,
            isButton: true,
            hasCheckedState: true,
            isChecked: true,
            isInMutuallyExclusiveGroup: true,
            hasTapAction: true,
          ),
        );
        await tester.tap(find.byKey(const ValueKey('appearance-dark')));
        await tester.pumpAndSettle();
        expect(
          tester.getSemantics(find.bySemanticsLabel('Dark appearance')),
          matchesSemantics(
            label: 'Dark appearance',
            hint: Appearance.dark.description,
            isButton: true,
            hasCheckedState: true,
            isChecked: true,
            isInMutuallyExclusiveGroup: true,
            hasTapAction: true,
          ),
        );
      } finally {
        semantics.dispose();
      }
    },
  );
}
