import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'finance_database.g.dart';

class EncryptedWorkspaces extends Table {
  IntColumn get id => integer()();
  IntColumn get revision => integer()();
  BlobColumn get payload => blob()();
  @override
  Set<Column> get primaryKey => {id};
}

class EncryptedReceipts extends Table {
  TextColumn get id => text()();
  BlobColumn get payload => blob()();
  @override
  Set<Column> get primaryKey => {id};
}

/// The legacy pesoflow_demo database is deliberately left untouched.
@DriftDatabase(tables: [EncryptedWorkspaces, EncryptedReceipts])
class FinanceDatabase extends _$FinanceDatabase {
  FinanceDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'pesoflow'));
  @override
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (_, _, _) async =>
        throw const FormatException('Unsupported financial schema.'),
    beforeOpen: (details) async {
      if (details.versionBefore != null &&
          details.versionBefore! > schemaVersion) {
        throw const FormatException(
          'This data requires a newer PesoFlow version.',
        );
      }
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA secure_delete = ON');
    },
  );
}
