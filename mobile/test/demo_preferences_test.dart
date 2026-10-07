import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/app.dart';
import 'package:pesoflow/app/demo_bootstrap.dart';
import 'package:pesoflow/app/router.dart';
import 'package:pesoflow/core/storage/demo_database.dart';
import 'package:pesoflow/core/storage/demo_workspace_codec.dart';
import 'package:pesoflow/core/storage/sqlite_demo_workspace_repository.dart';
import 'package:pesoflow/features/demo_workspace/application/demo_workspace_providers.dart';
import 'package:pesoflow/features/onboarding/application/onboarding_provider.dart';
import 'package:pesoflow/features/settings/application/settings_provider.dart';
import 'package:pesoflow/features/settings/domain/appearance.dart';

import 'demo_storage_test.dart'
    show ControlledWorkspaceRepository, persistedContainer;
import 'home_test.dart' show viewport;

void main() {
  test(
    'appearance and explicit demo completion reopen from a real SQLite file',
    () async {
      final dir = await Directory.systemTemp.createTemp(
        'pesoflow-preferences-',
      );
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/demo.sqlite');
      for (final appearance in Appearance.values) {
        final repository = SqliteDemoWorkspaceRepository(
          DemoDatabase(NativeDatabase(file)),
        );
        final container = persistedContainer(
          repository,
          await repository.load(),
        );
        container.read(settingsProvider.notifier).setAppearance(appearance);
        container.read(demoIntroductionCompletedProvider.notifier).complete();
        await container.read(demoPersistenceProvider.notifier).flush();
        container.dispose();
        await repository.close();
        final reopened = SqliteDemoWorkspaceRepository(
          DemoDatabase(NativeDatabase(file)),
        );
        final stored = await reopened.load();
        final fresh = persistedContainer(reopened, stored);
        expect(fresh.read(settingsProvider), appearance);
        expect(fresh.read(demoIntroductionCompletedProvider), true);
        expect(fresh.read(onboardingProvider), OnboardingStep.overview);
        fresh.dispose();
        await reopened.close();
      }
    },
  );

  test('v1 and v2 migrate with default preferences without replacing activity or plans', () async {
    for (final version in [1, 2]) {
      final database = DemoDatabase(NativeDatabase.memory());
      final repository = SqliteDemoWorkspaceRepository(database);
      final seed = await repository.load();
      final json =
          jsonDecode(DemoWorkspaceCodec.encode(seed)) as Map<String, dynamic>;
      json['formatVersion'] = version;
      json.remove('preferences');
      json['ledger'][0]['note'] = 'Preserved sample note';
      if (version == 1) {
        json.remove('budgets');
        json.remove('subscriptions');
      } else {
        json['budgets']['plans']['2024-10']['monthlyLimit'] = 3000000;
        json['subscriptions']['plans'][0]['active'] = false;
      }
      final payload = jsonEncode(json);
      await database
          .into(database.demoSnapshots)
          .insertOnConflictUpdate(
            DemoSnapshotsCompanion.insert(id: const Value(1), payload: payload),
          );
      await database.customStatement(
        "CREATE TRIGGER reject_preference_migration BEFORE UPDATE ON demo_snapshots BEGIN SELECT RAISE(ABORT, 'test failure'); END;",
      );
      await expectLater(repository.load(), throwsA(anything));
      expect(
        (await database.select(database.demoSnapshots).getSingle()).payload,
        payload,
      );
      await database.customStatement(
        'DROP TRIGGER reject_preference_migration',
      );
      final migrated = await repository.load();
      expect(migrated.preferences.appearance, Appearance.system);
      expect(migrated.preferences.introductionCompleted, false);
      expect(migrated.ledger.first.note, 'Preserved sample note');
      expect(
        migrated.budgets['2024-10']!.monthlyLimit,
        version == 1 ? 2500000 : 3000000,
      );
      expect(migrated.subscriptions.first.active, version == 1);
      expect(
        jsonDecode(
          (await database.select(database.demoSnapshots).getSingle()).payload,
        )['formatVersion'],
        3,
      );
      await repository.close();
    }
  });

  test(
    'invalid or future preferences are refused without replacement',
    () async {
      final database = DemoDatabase(NativeDatabase.memory());
      final repository = SqliteDemoWorkspaceRepository(database);
      addTearDown(repository.close);
      final seed = await repository.load();
      for (final preferences in [
        null,
        {},
        {'version': 2},
        {'version': 1.0},
        {'version': 1, 'appearance': 'unknown', 'introductionCompleted': false},
        {'version': 1, 'appearance': 'system', 'introductionCompleted': 1},
        {'version': 1, 'appearance': 'system'},
      ]) {
        final json =
            jsonDecode(DemoWorkspaceCodec.encode(seed)) as Map<String, dynamic>;
        json['preferences'] = preferences;
        final payload = jsonEncode(json);
        await database
            .into(database.demoSnapshots)
            .insertOnConflictUpdate(
              DemoSnapshotsCompanion.insert(
                id: const Value(1),
                payload: payload,
              ),
            );
        await expectLater(repository.load(), throwsA(anything));
        expect(
          (await database.select(database.demoSnapshots).getSingle()).payload,
          payload,
        );
      }
    },
  );

  test('failed appearance saves retry newest preference and resets preserve preferences', () async {
    final repository = ControlledWorkspaceRepository();
    final container = persistedContainer(repository, repository.workspace);
    addTearDown(container.dispose);
    final gate = Completer<void>();
    repository.onSave = (_) => gate.future;
    container.read(settingsProvider.notifier).setAppearance(Appearance.dark);
    final flushing = container.read(demoPersistenceProvider.notifier).flush();
    container.read(settingsProvider.notifier).setAppearance(Appearance.light);
    container.read(demoIntroductionCompletedProvider.notifier).complete();
    await Future<void>.delayed(Duration.zero);
    gate.completeError(Exception('private path'));
    await flushing;
    expect(container.read(demoPersistenceProvider), DemoSaveStatus.error);
    expect(repository.workspace.preferences.appearance, Appearance.system);
    repository.onSave = null;
    final persistence = container.read(demoPersistenceProvider.notifier);
    await persistence.flush();
    expect(repository.workspace.preferences.appearance, Appearance.light);
    expect(repository.workspace.preferences.introductionCompleted, true);
    expect(await persistence.resetActivity(), true);
    expect(await persistence.resetPlans(), true);
    expect(repository.workspace.preferences.appearance, Appearance.light);
    expect(repository.workspace.preferences.introductionCompleted, true);
    final financial = repository.workspace;
    container.read(settingsProvider.notifier).restoreAppearance();
    await persistence.flush();
    expect(repository.workspace.preferences.appearance, Appearance.system);
    expect(repository.workspace.preferences.introductionCompleted, true);
    expect(repository.workspace.ledger, financial.ledger);
    expect(repository.workspace.receipts, financial.receipts);
    expect(repository.workspace.budgets, financial.budgets);
    expect(repository.workspace.subscriptions, financial.subscriptions);
  });

  testWidgets(
    'startup recovery confirms preference reset and restores first-run defaults',
    (tester) async {
      viewport(tester, const Size(390, 844));
      final repository = ControlledWorkspaceRepository();
      final json = jsonDecode(
        DemoWorkspaceCodec.encode(repository.workspace),
      ) as Map<String, dynamic>;
      json['preferences']['appearance'] = 'dark';
      json['preferences']['introductionCompleted'] = true;
      repository.workspace = DemoWorkspaceCodec.decode(jsonEncode(json));
      repository.onLoad = () async =>
          throw const FormatException('private payload');
      await tester.pumpWidget(DemoBootstrap(repository: repository));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset stored demo data'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining(
          'restore System appearance and show the introduction again',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Reset demo data'));
      await tester.pumpAndSettle();
      expect(find.text('Understand your money'), findsOneWidget);
      expect(repository.workspace.preferences.appearance, Appearance.system);
      expect(repository.workspace.preferences.introductionCompleted, false);
    },
  );

  testWidgets(
    'only Explore demo completes introduction; restart restores dark Home and review remains available',
    (tester) async {
      viewport(tester, const Size(390, 844));
      final repository = ControlledWorkspaceRepository();
      await tester.pumpWidget(DemoBootstrap(repository: repository));
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(PesoFlowApp)),
      );
      container.read(settingsProvider.notifier).setAppearance(Appearance.dark);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(container.read(demoIntroductionCompletedProvider), false);
      await tester.tap(find.text('Explore demo'));
      await tester.pumpAndSettle();
      await container.read(demoPersistenceProvider.notifier).flush();
      expect(find.text('Good morning, Alex'), findsOneWidget);
      expect(
        container.read(routerProvider).routeInformationProvider.value.uri.path,
        '/home',
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(DemoBootstrap(repository: repository));
      await tester.pumpAndSettle();
      final fresh = ProviderScope.containerOf(
        tester.element(find.byType(PesoFlowApp)),
      );
      expect(find.text('Good morning, Alex'), findsOneWidget);
      expect(
        Theme.of(tester.element(find.text('Good morning, Alex'))).brightness,
        Brightness.dark,
      );
      fresh.read(routerProvider).go('/settings');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('View introduction'));
      await tester.tap(find.text('View introduction'));
      await tester.pumpAndSettle();
      expect(find.text('Understand your money'), findsOneWidget);
      expect(fresh.read(onboardingProvider), OnboardingStep.overview);
      expect(fresh.read(demoIntroductionCompletedProvider), true);
      expect(repository.workspace.preferences.introductionCompleted, true);
      expect(tester.takeException(), isNull);
    },
  );
}
