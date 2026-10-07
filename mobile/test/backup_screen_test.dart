import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/theme/app_theme.dart';
import 'package:pesoflow/features/backups/application/backup_actions.dart';
import 'package:pesoflow/features/backups/data/backup_files.dart';
import 'package:pesoflow/features/backups/domain/finance_backup.dart';
import 'package:pesoflow/features/backups/presentation/backup_screen.dart';
import 'package:pesoflow/features/workspace/domain/finance_workspace.dart';

import 'fixtures/finance_workspace_fixture.dart';

class Files implements BackupFiles {
  Uint8List? picked = Uint8List.fromList([1]);
  bool saved = true;
  Uint8List? output;
  Object? pickError, saveError;
  @override
  Future<Uint8List?> pick() async {
    if (pickError != null) throw pickError!;
    return picked;
  }

  @override
  Future<bool> save(String name, Uint8List bytes, {bool csv = false}) async {
    if (saveError != null) throw saveError!;
    output = bytes;
    return saved;
  }
}

void main() {
  late Files files;
  late FinanceBackup backup;
  late int writes;
  late bool fail;
  late bool restored;
  late bool conflict;
  Completer<void>? restoreGate;
  setUp(() {
    files = Files();
    backup = FinanceBackup(financeFixture(), {}, DateTime.utc(2024, 10, 24));
    writes = 0;
    fail = false;
    restored = false;
    conflict = false;
    restoreGate = null;
  });
  Future<void> pump(
    WidgetTester tester, {
    ThemeMode mode = ThemeMode.light,
    bool recovery = false,
    Size size = const Size(390, 1600),
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('backup-golden'),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          home: BackupScreen(
            recovery: recovery,
            currentDescription: '8 accounts and 9 transactions on this device',
            actions: BackupActions(
              files: files,
              capture: () async => backup,
              transactions: () async => backup.workspace,
              revision: () async => 4,
              seal: (_, _) async => Uint8List.fromList([10, 20]),
              open: (_, _) async => backup,
              restore: (_, revision) async {
                expect(revision, 4);
                if (conflict) throw const WorkspaceConflict();
                if (fail) throw StateError('safe test failure');
                await restoreGate?.future;
                writes++;
              },
            ),
            onRestored: () => restored = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text));
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('backup ${mode.name} golden uses shared settings design', (
      tester,
    ) async {
      await pump(tester, mode: mode, size: const Size(390, 1000));
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const ValueKey('backup-golden')),
        matchesGoldenFile('goldens/backup_${mode.name}.png'),
      );
    });
  }
  testWidgets(
    'restore requires preview and final confirmation; cancel and retry preserve data',
    (tester) async {
      await pump(tester);
      await tap(tester, 'Choose backup file');
      expect(writes, 0);
      await tap(tester, 'Unlock and review');
      expect(find.textContaining('Backup from'), findsOneWidget);
      expect(writes, 0);
      await tap(tester, 'Review replacement');
      await tap(tester, 'Cancel');
      expect(writes, 0);
      fail = true;
      await tap(tester, 'Review replacement');
      await tap(tester, 'Replace and restore');
      expect(writes, 0);
      expect(restored, false);
      expect(
        find.textContaining('previously saved data is intact'),
        findsOneWidget,
      );
      fail = false;
      await tap(tester, 'Review replacement');
      await tap(tester, 'Replace and restore');
      expect(writes, 1);
      expect(restored, true);
    },
  );
  testWidgets(
    'password mismatch and native save cancellation never claim a backup was saved',
    (tester) async {
      await pump(tester);
      await tester.enterText(find.byType(TextField).first, 'backup passphrase');
      await tap(tester, 'Save encrypted backup');
      expect(find.text('The passwords do not match.'), findsOneWidget);
      expect(files.output, isNull);
      await tester.enterText(find.byType(TextField).at(1), 'backup passphrase');
      files.saved = false;
      await tap(tester, 'Save encrypted backup');
      expect(find.text('Save canceled. No backup was saved.'), findsOneWidget);
      expect(writes, 0);
    },
  );
  testWidgets(
    'readable CSV export requires disclosure; selection cancellation is harmless',
    (tester) async {
      await pump(tester);
      await tap(tester, 'Export transaction CSV');
      expect(files.output, isNull);
      await tap(tester, 'Cancel');
      expect(files.output, isNull);
      await tap(tester, 'Export transaction CSV');
      await tap(tester, 'Choose location');
      expect(files.output, isNotNull);
      expect(writes, 0);
      files.picked = null;
      await tap(tester, 'Choose backup file');
      expect(
        find.text('Selection canceled. Your data is unchanged.'),
        findsOneWidget,
      );
    },
  );
  testWidgets(
    'recovery offers restore without exporting unreadable data, at large text',
    (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pump(tester, recovery: true, size: const Size(320, 760));
      expect(find.text('Save encrypted backup'), findsNothing);
      expect(find.text('Export transaction CSV'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('file provider read/write errors remain safe and retryable', (
    tester,
  ) async {
    await pump(tester);
    files.pickError = PlatformException(
      code: 'download_failed',
      message: 'private-provider-path',
    );
    await tap(tester, 'Choose backup file');
    expect(
      find.textContaining('previously saved data is intact'),
      findsOneWidget,
    );
    expect(find.textContaining('private-provider-path'), findsNothing);
    expect(find.text('Unlock and review'), findsNothing);
    expect(writes, 0);
    files.pickError = null;
    await tap(tester, 'Choose backup file');
    expect(find.text('Unlock and review'), findsOneWidget);
    for (final field in find.byType(TextField).evaluate().toList()) {
      await tester.enterText(
        find.byWidget(field.widget),
        'test backup password',
      );
    }
    files.saveError = PlatformException(
      code: 'disk_full',
      message: 'private-export-path',
    );
    await tap(tester, 'Save encrypted backup');
    expect(find.textContaining('Backup saved.'), findsNothing);
    expect(find.textContaining('private-export-path'), findsNothing);
    expect(files.output, isNull);
    files.saveError = null;
    await tap(tester, 'Save encrypted backup');
    expect(find.textContaining('Backup saved.'), findsOneWidget);
    expect(writes, 0);
  });
  testWidgets('background/resume while restoring cannot submit twice', (
    tester,
  ) async {
    await pump(tester);
    await tap(tester, 'Choose backup file');
    await tap(tester, 'Unlock and review');
    restoreGate = Completer<void>();
    await tap(tester, 'Review replacement');
    await tap(tester, 'Replace and restore');
    expect(writes, 0);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    final restoreButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Review replacement'),
    );
    expect(restoreButton.onPressed, isNull);
    await tap(tester, 'Review replacement');
    expect(find.text('Replace and restore'), findsNothing);
    restoreGate!.complete();
    await tester.pumpAndSettle();
    expect(writes, 1);
    expect(restored, isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets('stale preview is discarded and must be opened again', (
    tester,
  ) async {
    await pump(tester);
    await tap(tester, 'Choose backup file');
    await tap(tester, 'Unlock and review');
    conflict = true;
    await tap(tester, 'Review replacement');
    await tap(tester, 'Replace and restore');
    expect(writes, 0);
    expect(
      find.textContaining('Your data changed while reviewing'),
      findsOneWidget,
    );
    expect(find.text('Review replacement'), findsNothing);
    expect(find.text('Unlock and review'), findsNothing);
    conflict = false;
    await tap(tester, 'Choose backup file');
    await tap(tester, 'Unlock and review');
    await tap(tester, 'Review replacement');
    await tap(tester, 'Replace and restore');
    expect(writes, 1);
  });
}
