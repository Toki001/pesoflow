import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/app.dart';
import 'package:pesoflow/app/router.dart';
import 'package:pesoflow/features/onboarding/application/onboarding_provider.dart';

import 'home_test.dart' show viewport;

Future<void> pumpIntro(
  WidgetTester tester, {
  ThemeMode theme = ThemeMode.light,
  String? location,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (location != null)
          routerProvider.overrideWith((ref) {
            final router = createRouter(initialLocation: location);
            ref.onDispose(router.dispose);
            return router;
          }),
      ],
      child: RepaintBoundary(
        key: const ValueKey('intro-golden'),
        child: PesoFlowApp(themeMode: theme),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('progression is bounded, skip reaches disclosure and a fresh session resets', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(onboardingProvider.notifier);
    controller.back();
    expect(container.read(onboardingProvider), OnboardingStep.overview);
    controller.next();
    expect(container.read(onboardingProvider), OnboardingStep.plans);
    controller.back();
    controller.skipToDemo();
    controller.next();
    expect(container.read(onboardingProvider), OnboardingStep.demo);
    final fresh = ProviderContainer();
    addTearDown(fresh.dispose);
    expect(fresh.read(onboardingProvider), OnboardingStep.overview);
  });

  testWidgets(
    'startup, progression, back and explicit entry replace introduction',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpIntro(tester);
      expect(find.text('Understand your money'), findsOneWidget);
      expect(find.byKey(const ValueKey('nav-Home')), findsNothing);
      expect(find.text('Explore demo'), findsNothing);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Make room for your plans'), findsOneWidget);
      expect(find.text('Step 2 of 3'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Understand your money'), findsOneWidget);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(find.text('No account connection'), findsOneWidget);
      expect(find.text('Changes last for this session'), findsOneWidget);
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Make room for your plans'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Explore demo'));
      await tester.pumpAndSettle();
      expect(find.text('Good morning, Alex'), findsOneWidget);
      final context = tester.element(find.text('Good morning, Alex'));
      final container = ProviderScope.containerOf(context);
      expect(container.read(routerProvider).canPop(), isFalse);
    },
  );

  testWidgets(
    'root opens introduction while explicit Home deep link remains usable',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpIntro(tester, location: '/');
      expect(find.text('Understand your money'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await pumpIntro(tester, location: '/home');
      expect(find.text('Good morning, Alex'), findsOneWidget);
      expect(find.text('Understand your money'), findsNothing);
    },
  );

  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    for (final step in OnboardingStep.values) {
      testWidgets('introduction ${step.name} ${theme.name} golden', (
        tester,
      ) async {
        viewport(tester, const Size(390, 844));
        await pumpIntro(tester, theme: theme);
        final container = ProviderScope.containerOf(
          tester.element(find.text('PesoFlow')),
        );
        for (var i = 0; i < step.index; i++) {
          container.read(onboardingProvider.notifier).next();
        }
        await tester.pumpAndSettle();
        await expectLater(
          find.byKey(const ValueKey('intro-golden')),
          matchesGoldenFile(
            'goldens/onboarding_${step.name}_${theme.name}_390x844.png',
          ),
        );
      });
    }
  }

  for (final size in [
    const Size(320, 640),
    const Size(430, 932),
    const Size(844, 390),
  ]) {
    testWidgets('all stages scroll and actions remain usable at $size', (
      tester,
    ) async {
      viewport(tester, size);
      await pumpIntro(tester);
      for (var i = 0; i < 3; i++) {
        expect(tester.takeException(), isNull);
        final button = find.text(i == 2 ? 'Explore demo' : 'Next');
        expect(button.hitTestable(), findsOneWidget);
        if (i < 2) {
          await tester.tap(button);
          await tester.pumpAndSettle();
        } else {
          await tester.ensureVisible(
            find.text('Receipt review uses a fixture'),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      }
    });
  }

  testWidgets(
    '200 percent text and safe insets preserve disclosures and controls',
    (tester) async {
      viewport(tester, const Size(320, 844));
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(tester.view.resetPadding);
      await pumpIntro(tester);
      expect(
        tester.getTopLeft(find.text('PesoFlow')).dy,
        greaterThanOrEqualTo(44),
      );
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      await tester.ensureVisible(find.text('Receipt review uses a fixture'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Explore demo').hitTestable(), findsOneWidget);
      expect(
        tester.getBottomRight(find.text('Explore demo')).dy,
        lessThan(810),
      );
    },
  );
}
