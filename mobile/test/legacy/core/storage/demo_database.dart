import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'demo_database.g.dart';

class DemoSnapshots extends Table {
  IntColumn get id => integer()();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [DemoSnapshots])
class DemoDatabase extends _$DemoDatabase {
  DemoDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'pesoflow_demo'));
  @override
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (_, _, _) async =>
        throw const FormatException('Unsupported demo schema.'),
    beforeOpen: (details) async {
      if (details.versionBefore != null &&
          details.versionBefore! > schemaVersion) {
        throw const FormatException('Unsupported demo schema.');
      }
    },
  );
}
