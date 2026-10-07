import 'package:drift/drift.dart';

import '../../features/budgets/data/budget_fixture.dart';
import '../../features/subscriptions/data/subscription_fixture.dart';
import '../../features/demo_workspace/domain/demo_workspace.dart';
import '../../features/transactions/data/transaction_fixture.dart';
import 'demo_database.dart';
import 'demo_workspace_codec.dart';

DemoWorkspace initialDemoWorkspace() => DemoWorkspace(
  ledger: transactionFixture(),
  budgets: {budgetFixture().key: budgetFixture()},
  subscriptions: subscriptionFixture(),
);

class SqliteDemoWorkspaceRepository implements DemoWorkspaceRepository {
  SqliteDemoWorkspaceRepository(this.database);
  final DemoDatabase database;
  @override
  Future<DemoWorkspace> load() => database.transaction(() async {
    final row = await (database.select(
      database.demoSnapshots,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    if (row != null) {
      final workspace = DemoWorkspaceCodec.decode(row.payload);
      if (DemoWorkspaceCodec.needsMigration(row.payload)) await save(workspace);
      return workspace;
    }
    final seed = initialDemoWorkspace();
    await save(seed);
    return seed;
  });
  @override
  Future<void> save(DemoWorkspace workspace) async {
    final payload = DemoWorkspaceCodec.encode(workspace);
    await database.transaction(() async {
      await database
          .into(database.demoSnapshots)
          .insertOnConflictUpdate(
            DemoSnapshotsCompanion.insert(id: const Value(1), payload: payload),
          );
    });
  }

  @override
  Future<void> close() => database.close();
}
