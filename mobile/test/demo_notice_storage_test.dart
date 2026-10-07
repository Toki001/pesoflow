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
import 'package:pesoflow/features/notifications/application/notifications_provider.dart';
import 'package:pesoflow/features/notifications/data/notification_fixture.dart';
import 'package:pesoflow/features/notifications/domain/demo_notice.dart';
import 'package:pesoflow/features/settings/application/settings_provider.dart';
import 'package:pesoflow/features/settings/domain/appearance.dart';

import 'demo_storage_test.dart'
    show ControlledWorkspaceRepository, persistedContainer;
import 'demo_storage_widget_test.dart' show pumpLocalSettings;
import 'home_test.dart' show viewport;

void main() {
  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('stored inbox ${theme.name} golden', (tester) async {
      viewport(tester, const Size(390, 1480));
      await pumpLocalSettings(
        tester,
        ControlledWorkspaceRepository(),
        theme: theme,
        location: '/notifications',
      );
      expect(find.text('3 unread · 4 sample alerts'), findsOneWidget);
      await expectLater(
        find.byKey(const ValueKey('local-settings-golden')),
        matchesGoldenFile(
          'goldens/notifications_local_${theme.name}_390x1480.png',
        ),
      );
    });
  }
  testWidgets(
    'stored inbox supports compact 200 percent text and safe insets',
    (tester) async {
      viewport(tester, const Size(320, 844));
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(tester.view.resetPadding);
      await pumpLocalSettings(
        tester,
        ControlledWorkspaceRepository(),
        location: '/notifications',
      );
      await tester.ensureVisible(find.text('View analytics'));
      expect(find.text('View analytics').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  test('file reopen preserves individual, all-read and empty read markers; content and filters remain independent', () async {
    final dir = await Directory.systemTemp.createTemp('pesoflow-notices-');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/demo.sqlite');
    final states = <Set<String>>[
      {'food-limit', 'spending-review'},
      notificationFixture().map((n) => n.id).toSet(),
      {},
    ];
    for (final expected in states) {
      final repository = SqliteDemoWorkspaceRepository(
        DemoDatabase(NativeDatabase(file)),
      );
      final container = persistedContainer(repository, await repository.load());
      await container.read(notificationsProvider.future);
      final read = container.read(noticeReadProvider.notifier);
      if (expected.length == 4) {
        read.markAllRead();
      } else {
        for (final notice in notificationFixture()) {
          read.setRead(notice.id, expected.contains(notice.id));
        }
      }
      container.read(noticeFilterProvider.notifier).select(NoticeFilter.unread);
      await container.read(demoPersistenceProvider.notifier).flush();
      container.dispose();
      await repository.close();
      final reopened = SqliteDemoWorkspaceRepository(
        DemoDatabase(NativeDatabase(file)),
      );
      final stored = await reopened.load();
      expect(stored.noticeReadIds, expected);
      final fresh = persistedContainer(reopened, stored);
      final notices = await fresh.read(notificationsProvider.future);
      expect(fresh.read(unreadNoticeCountProvider), 4 - expected.length);
      expect(fresh.read(noticeFilterProvider), NoticeFilter.all);
      expect(
        notices.map((n) => n.message),
        notificationFixture().map((n) => n.message),
      );
      fresh.invalidate(notificationsProvider);
      await fresh.read(notificationsProvider.future);
      expect(fresh.read(noticeReadProvider), expected);
      expect(
        () => fresh.read(noticeReadProvider).clear(),
        throwsUnsupportedError,
      );
      fresh.dispose();
      await reopened.close();
    }
  });

  test('v1 v2 v3 migrate with original markers while preserving all existing collections', () async {
    for (final version in [1, 2, 3]) {
      final database = DemoDatabase(NativeDatabase.memory());
      final repository = SqliteDemoWorkspaceRepository(database);
      final seed = await repository.load();
      final json =
          jsonDecode(DemoWorkspaceCodec.encode(seed)) as Map<String, dynamic>;
      json['formatVersion'] = version;
      json.remove('noticeReadState');
      json['ledger'][0]['note'] = 'Preserved sample note';
      if (version == 1) {
        json.remove('budgets');
        json.remove('subscriptions');
      } else {
        json['budgets']['plans']['2024-10']['monthlyLimit'] = 3000000;
        json['subscriptions']['plans'][0]['active'] = false;
      }
      if (version < 3) {
        json.remove('preferences');
      } else {
        json['preferences']['appearance'] = 'dark';
        json['preferences']['introductionCompleted'] = true;
      }
      final payload = jsonEncode(json);
      await database
          .into(database.demoSnapshots)
          .insertOnConflictUpdate(
            DemoSnapshotsCompanion.insert(id: const Value(1), payload: payload),
          );
      await database.customStatement(
        "CREATE TRIGGER reject_alert_migration BEFORE UPDATE ON demo_snapshots BEGIN SELECT RAISE(ABORT, 'test failure'); END;",
      );
      await expectLater(repository.load(), throwsA(anything));
      expect(
        (await database.select(database.demoSnapshots).getSingle()).payload,
        payload,
      );
      await database.customStatement('DROP TRIGGER reject_alert_migration');
      final migrated = await repository.load();
      expect(migrated.noticeReadIds, initialNoticeReadIds);
      expect(migrated.ledger.first.note, 'Preserved sample note');
      expect(
        migrated.budgets['2024-10']!.monthlyLimit,
        version == 1 ? 2500000 : 3000000,
      );
      expect(migrated.subscriptions.first.active, version == 1);
      expect(
        migrated.preferences.appearance,
        version == 3 ? Appearance.dark : Appearance.system,
      );
      expect(migrated.preferences.introductionCompleted, version == 3);
      expect(
        jsonDecode(
          (await database.select(database.demoSnapshots).getSingle()).payload,
        )['formatVersion'],
        4,
      );
      await repository.close();
    }
  });

  test(
    'invalid or unknown catalog markers are refused without reseeding',
    () async {
      final database = DemoDatabase(NativeDatabase.memory());
      final repository = SqliteDemoWorkspaceRepository(database);
      addTearDown(repository.close);
      final seed = await repository.load();
      for (final state in [
        null,
        {},
        {'version': 2, 'catalogVersion': 1, 'readIds': []},
        {'version': 1.0, 'catalogVersion': 1, 'readIds': []},
        {'version': 1, 'catalogVersion': 2, 'readIds': []},
        {'version': 1, 'catalogVersion': 1.0, 'readIds': []},
        {
          'version': 1,
          'catalogVersion': 1,
          'readIds': ['unknown'],
        },
        {
          'version': 1,
          'catalogVersion': 1,
          'readIds': ['food-limit', 'food-limit'],
        },
        {
          'version': 1,
          'catalogVersion': 1,
          'readIds': [1],
        },
        {
          'version': 1,
          'catalogVersion': 1,
          'readIds': [''],
        },
      ]) {
        final json =
            jsonDecode(DemoWorkspaceCodec.encode(seed)) as Map<String, dynamic>;
        json['noticeReadState'] = state;
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

  test(
    'failed saves retry latest markers and other resets preserve them',
    () async {
      final repository = ControlledWorkspaceRepository();
      final container = persistedContainer(repository, repository.workspace);
      addTearDown(container.dispose);
      await container.read(notificationsProvider.future);
      final read = container.read(noticeReadProvider.notifier);
      final gate = Completer<void>();
      repository.onSave = (_) => gate.future;
      read.setRead('food-limit', true);
      final persistence = container.read(demoPersistenceProvider.notifier);
      final flushing = persistence.flush();
      read.markAllRead();
      read.setRead('spending-review', false);
      container.read(settingsProvider.notifier).setAppearance(Appearance.dark);
      await Future<void>.delayed(Duration.zero);
      gate.completeError(Exception('private path'));
      await flushing;
      expect(container.read(demoPersistenceProvider), DemoSaveStatus.error);
      expect(repository.workspace.noticeReadIds, initialNoticeReadIds);
      repository.onSave = null;
      await persistence.flush();
      final expected = container.read(noticeReadProvider);
      expect(repository.workspace.noticeReadIds, expected);
      expect(repository.workspace.preferences.appearance, Appearance.dark);
      expect(await persistence.resetActivity(), true);
      expect(await persistence.resetPlans(), true);
      expect(repository.workspace.noticeReadIds, expected);
      final financial = repository.workspace;
      repository.onSave = (_) async => throw Exception('reset failed');
      expect(await persistence.resetAlerts(), false);
      expect(container.read(noticeReadProvider), expected);
      expect(repository.workspace, financial);
      repository.onSave = null;
      expect(await persistence.resetAlerts(), true);
      expect(container.read(noticeReadProvider), initialNoticeReadIds);
      expect(container.read(unreadNoticeCountProvider), 3);
      expect(repository.workspace.ledger, financial.ledger);
      expect(repository.workspace.receipts, financial.receipts);
      expect(repository.workspace.budgets, financial.budgets);
      expect(repository.workspace.subscriptions, financial.subscriptions);
      expect(repository.workspace.preferences.appearance, Appearance.dark);
    },
  );

  testWidgets(
    'opening a sample alert restores the unread badge after restart without changing content',
    (tester) async {
      viewport(tester, const Size(390, 844));
      final repository = ControlledWorkspaceRepository();
      final container = await pumpLocalSettings(
        tester,
        repository,
        location: '/notifications',
      );
      expect(
        find.textContaining('Read markers stay on this device after restart'),
        findsOneWidget,
      );
      await tester.tap(find.text('View budgets'));
      await tester.pumpAndSettle();
      await container.read(demoPersistenceProvider.notifier).flush();
      expect(repository.workspace.noticeReadIds.contains('food-limit'), true);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(DemoBootstrap(repository: repository));
      await tester.pumpAndSettle();
      final fresh = ProviderScope.containerOf(
        tester.element(find.byType(PesoFlowApp)),
      );
      fresh.read(routerProvider).go('/notifications');
      await tester.pumpAndSettle();
      expect(find.text('2 unread · 4 sample alerts'), findsOneWidget);
      expect(find.text('Food budget is approaching its limit'), findsOneWidget);
      expect(fresh.read(noticeReadProvider).contains('food-limit'), true);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Settings alert reset needs confirmation and preserves financial data',
    (tester) async {
      viewport(tester, const Size(390, 844));
      final repository = ControlledWorkspaceRepository();
      final container = await pumpLocalSettings(tester, repository);
      await container.read(notificationsProvider.future);
      container.read(noticeReadProvider.notifier).markAllRead();
      await container.read(demoPersistenceProvider.notifier).flush();
      await tester.pumpAndSettle();
      final original = repository.workspace;
      await tester.ensureVisible(find.text('Reset demo alerts'));
      await tester.tap(find.text('Reset demo alerts'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('three alerts unread and one read'),
        findsOneWidget,
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repository.workspace, original);
      await tester.tap(find.text('Reset demo alerts'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset alerts'));
      await tester.pumpAndSettle();
      expect(repository.workspace.noticeReadIds, initialNoticeReadIds);
      expect(repository.workspace.ledger, original.ledger);
      expect(repository.workspace.budgets, original.budgets);
      expect(
        find.text('Original demo alert read markers restored on this device.'),
        findsOneWidget,
      );
    },
  );
}
