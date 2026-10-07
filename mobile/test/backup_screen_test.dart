import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/theme/app_theme.dart';
import 'package:pesoflow/features/backups/application/backup_actions.dart';
import 'package:pesoflow/features/backups/data/backup_files.dart';
import 'package:pesoflow/features/backups/domain/finance_backup.dart';
import 'package:pesoflow/features/backups/presentation/backup_screen.dart';

import 'fixtures/finance_workspace_fixture.dart';

class Files implements BackupFiles {
  Uint8List? picked = Uint8List.fromList([1]);
  bool saved = true;
  Uint8List? output;
  @override
  Future<Uint8List?> pick() async => picked;
  @override
  Future<bool> save(String name, Uint8List bytes, {bool csv = false}) async {
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
  setUp(() {
    files = Files();
    backup = FinanceBackup(financeFixture(), {}, DateTime.utc(2024, 10, 24));
    writes = 0;
    fail = false;
    restored = false;
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
                if (fail) throw StateError('safe test failure');
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
}
