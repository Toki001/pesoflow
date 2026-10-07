import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/core/storage/demo_database.dart';
import 'package:pesoflow/core/storage/demo_workspace_codec.dart';
import 'package:pesoflow/core/storage/sqlite_demo_workspace_repository.dart';
import 'package:pesoflow/features/budgets/application/budgets_provider.dart';
import 'package:pesoflow/features/budgets/data/budget_fixture.dart';
import 'package:pesoflow/features/demo_workspace/application/demo_workspace_providers.dart';
import 'package:pesoflow/features/receipts/application/receipts_provider.dart';
import 'package:pesoflow/features/subscriptions/application/subscriptions_provider.dart';
import 'package:pesoflow/features/subscriptions/domain/subscription_plan.dart';
import 'package:pesoflow/features/transactions/application/transactions_provider.dart';
import 'package:pesoflow/features/transactions/data/transaction_fixture.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';

import 'add_expense_test.dart' show draft;
import 'demo_storage_test.dart'
    show ControlledWorkspaceRepository, persistedContainer, reviewed;

SubscriptionPlan plan(
  String id, {
  int amount = 19999,
  BillingCycle cycle = BillingCycle.quarterly,
}) => SubscriptionPlan(
  id: id,
  name: 'Sample plan',
  amount: amount,
  cycle: cycle,
  nextRenewal: DateTime(2025, 2, 28),
  paymentSource: 'GCash Personal',
  category: 'Productivity',
  confidence: 0.8,
);

Map<String, dynamic> snapshot() =>
    jsonDecode(DemoWorkspaceCodec.encode(initialDemoWorkspace()))
        as Map<String, dynamic>;

void main() {
  test('file reopen preserves base plans across periods without doubling ledger projections', () async {
    final dir = await Directory.systemTemp.createTemp('pesoflow-plans-');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/demo.sqlite');
    final repository = SqliteDemoWorkspaceRepository(
      DemoDatabase(NativeDatabase(file)),
    );
    final container = persistedContainer(repository, await repository.load());
    final budgets = container.read(demoBudgetPlansProvider.notifier);
    budgets.setLimit(2024, 10, null, 3000000);
    budgets.reallocate(
      2024,
      10,
      TransactionCategory.entertainment,
      TransactionCategory.food,
      50000,
    );
    budgets.setLimit(2024, 11, TransactionCategory.food, 1000000);
    budgets.setLimit(2024, 10, TransactionCategory.coffee, 50000);
    final ledger = container.read(demoLedgerProvider.notifier);
    ledger.createManual(draft(amount: 32501));
    ledger.add(
      draft()
          .toRecord('demo-refund')
          .copyWith(kind: TransactionKind.refund, amount: 12500),
    );
    ledger.createManual(
      draft(kind: TransactionKind.transfer, destination: 'Maya', amount: 99900),
    );
    ledger.createManual(draft(kind: TransactionKind.income, amount: 12300));
    final expected = budgets.viewFor(2024, 10);
    expect(expected.spent, budgetFixture().spent + 20001);
    final base = container.read(demoBudgetPlansProvider);
    await container.read(demoPersistenceProvider.notifier).flush();
    container.dispose();
    await repository.close();
    final reopened = SqliteDemoWorkspaceRepository(
      DemoDatabase(NativeDatabase(file)),
    );
    final stored = await reopened.load();
    expect(stored.budgets, base);
    expect(stored.budgets['2024-10']!.spent, budgetFixture().spent);
    final fresh = persistedContainer(reopened, stored);
    expect(
      fresh.read(demoBudgetPlansProvider.notifier).viewFor(2024, 10),
      expected,
    );
    expect(
      fresh
          .read(demoBudgetPlansProvider.notifier)
          .baseFor(2024, 11)
          .monthlyLimit,
      1000000,
    );
    fresh.dispose();
    await reopened.close();
  });

  test('subscription create edit pause remove and all billing cycles survive loading without charges', () async {
    final repository = SqliteDemoWorkspaceRepository(
      DemoDatabase(NativeDatabase.memory()),
    );
    addTearDown(repository.close);
    final container = persistedContainer(repository, await repository.load());
    final subscriptions = container.read(demoSubscriptionsProvider.notifier);
    for (final cycle in BillingCycle.values) {
      subscriptions.save(plan(subscriptions.nextId(), cycle: cycle));
    }
    subscriptions.save(
      plan('subscription-demo-1', amount: 12345, cycle: BillingCycle.weekly),
    );
    subscriptions.setActive('spotify', false);
    subscriptions.remove('google');
    final overview = SubscriptionOverview(
      container.read(demoSubscriptionsProvider),
    );
    await container.read(demoPersistenceProvider.notifier).flush();
    container.dispose();
    final stored = await repository.load();
    final fresh = persistedContainer(repository, stored);
    final restored = fresh.read(demoSubscriptionsProvider);
    expect(SubscriptionOverview(restored).annualized, overview.annualized);
    expect(restored.singleWhere((p) => p.id == 'spotify').active, false);
    expect(restored.any((p) => p.id == 'google'), false);
    expect(
      restored.singleWhere((p) => p.id == 'subscription-demo-1').amount,
      12345,
    );
    expect(
      restored.singleWhere((p) => p.id == 'subscription-demo-1').confidence,
      0.8,
    );
    expect(
      restored.singleWhere((p) => p.id == 'subscription-demo-1').origin,
      SubscriptionOrigin.manual,
    );
    expect(
      restored.singleWhere((p) => p.id == 'subscription-demo-1').nextRenewal,
      DateTime(2025, 2, 28),
    );
    expect(
      restored
          .where((p) => p.id.startsWith('subscription-demo-'))
          .map((p) => p.cycle),
      BillingCycle.values,
    );
    expect(
      fresh.read(demoSubscriptionsProvider.notifier).nextId(),
      'subscription-demo-5',
    );
    expect(fresh.read(demoLedgerProvider), transactionFixture());
    fresh.dispose();
  });

  test('an intentionally empty tracking list is never reseeded', () async {
    final repository = ControlledWorkspaceRepository();
    final container = persistedContainer(repository, repository.workspace);
    for (final p in container.read(demoSubscriptionsProvider)) {
      container.read(demoSubscriptionsProvider.notifier).remove(p.id);
    }
    await container.read(demoPersistenceProvider.notifier).flush();
    container.dispose();
    final restored = DemoWorkspaceCodec.decode(
      DemoWorkspaceCodec.encode(repository.workspace),
    );
    final fresh = persistedContainer(repository, restored);
    expect(fresh.read(demoSubscriptionsProvider), isEmpty);
    expect(fresh.read(demoLedgerProvider), transactionFixture());
    fresh.dispose();
  });

  test('v1 migration preserves edited ledger and saved receipts and rewrites atomically', () async {
    final database = DemoDatabase(NativeDatabase.memory());
    final repository = SqliteDemoWorkspaceRepository(database);
    addTearDown(repository.close);
    final container = persistedContainer(repository, await repository.load());
    await container.read(receiptReviewProvider.future);
    final review = container.read(receiptReviewProvider.notifier);
    review.saveItem(
      reviewed(container.read(receiptReviewProvider).value!.items.last),
    );
    final id = review.save();
    container.read(demoLedgerProvider.notifier).createManual(draft());
    await container.read(demoPersistenceProvider.notifier).flush();
    container.dispose();
    final original = await repository.load();
    final legacy =
        jsonDecode(DemoWorkspaceCodec.encode(original)) as Map<String, dynamic>;
    legacy['formatVersion'] = 1;
    legacy.remove('budgets');
    legacy.remove('subscriptions');
    final payload = jsonEncode(legacy);
    await database
        .into(database.demoSnapshots)
        .insertOnConflictUpdate(
          DemoSnapshotsCompanion.insert(id: const Value(1), payload: payload),
        );
    await database.customStatement(
      "CREATE TRIGGER reject_migration BEFORE UPDATE ON demo_snapshots BEGIN SELECT RAISE(ABORT, 'test failure'); END;",
    );
    await expectLater(repository.load(), throwsA(anything));
    expect(
      (await database.select(database.demoSnapshots).getSingle()).payload,
      payload,
    );
    await database.customStatement('DROP TRIGGER reject_migration');
    final migrated = await repository.load();
    expect(migrated.ledger, original.ledger);
    expect(migrated.receipts[id]!.total, original.receipts[id]!.total);
    expect(migrated.budgets['2024-10'], budgetFixture());
    expect(migrated.subscriptions, hasLength(5));
    expect(
      jsonDecode(
        (await database.select(database.demoSnapshots).getSingle()).payload,
      )['formatVersion'],
      3,
    );
  });

  test(
    'invalid plans fail loading without replacing any stored data',
    () async {
      final database = DemoDatabase(NativeDatabase.memory());
      final repository = SqliteDemoWorkspaceRepository(database);
      addTearDown(repository.close);
      await repository.load();
      final mutations = <void Function(Map<String, dynamic>)>[
        (s) => s['budgets']['version'] = 2,
        (s) => s['subscriptions']['version'] = 2,
        (s) => s.remove('budgets'),
        (s) => s['budgets']['plans']['2024-10']['monthlyLimit'] = 2500000.5,
        (s) => s['budgets']['plans']['2024-10']['spent'] = 1680000.5,
        (s) => s['budgets']['plans']['2024-10']['month'] = 13,
        (s) => s['budgets']['plans']['2024-10']['monthlyLimit'] = 100,
        (s) => s['budgets']['plans']['2024-10']['allowances'][0]['limit'] =
            800000.5,
        (s) => s['budgets']['plans']['2024-10']['allowances'][0]['category'] =
            'income',
        (s) => s['budgets']['plans']['2024-10']['allowances'].add(
          s['budgets']['plans']['2024-10']['allowances'][0],
        ),
        (s) =>
            s['budgets']['plans']['2024-10']['editedCategories'] = ['refund'],
        (s) => s['subscriptions']['plans'][0]['amount'] = 54900.5,
        (s) => s['subscriptions']['plans'][0]['amount'] = -1,
        (s) => s['subscriptions']['plans'][0]['cycle'] = 'daily',
        (s) => s['subscriptions']['plans'][0]['nextRenewal'] =
            '2025-02-31T00:00:00.000',
        (s) => s['subscriptions']['plans'][0]['confidence'] = 2,
        (s) => s['subscriptions']['plans'].add(s['subscriptions']['plans'][0]),
      ];
      for (final mutate in mutations) {
        final s = snapshot();
        mutate(s);
        final payload = jsonEncode(s);
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
    'latest plans and activity retry together after a failed queued write',
    () async {
      final repository = ControlledWorkspaceRepository();
      final gate = Completer<void>();
      repository.onSave = (_) => gate.future;
      final container = persistedContainer(repository, repository.workspace);
      addTearDown(container.dispose);
      container
          .read(demoBudgetPlansProvider.notifier)
          .setLimit(2024, 10, null, 3000000);
      final flushing = container.read(demoPersistenceProvider.notifier).flush();
      container
          .read(demoSubscriptionsProvider.notifier)
          .setActive('netflix', false);
      container.read(demoLedgerProvider.notifier).createManual(draft());
      await Future<void>.delayed(Duration.zero);
      gate.completeError(Exception('private storage path'));
      await flushing;
      expect(container.read(demoPersistenceProvider), DemoSaveStatus.error);
      expect(repository.workspace.budgets['2024-10']!.monthlyLimit, 2500000);
      repository.onSave = null;
      await container.read(demoPersistenceProvider.notifier).flush();
      expect(repository.workspace.budgets['2024-10']!.monthlyLimit, 3000000);
      expect(repository.workspace.subscriptions.first.active, false);
      expect(repository.workspace.ledger, hasLength(10));
    },
  );

  test('scoped resets publish only after success and preserve the other stored domain', () async {
    final repository = ControlledWorkspaceRepository();
    final container = persistedContainer(repository, repository.workspace);
    addTearDown(container.dispose);
    container
        .read(demoBudgetPlansProvider.notifier)
        .setLimit(2024, 10, null, 3000000);
    container
        .read(demoSubscriptionsProvider.notifier)
        .setActive('netflix', false);
    container.read(demoLedgerProvider.notifier).createManual(draft());
    await container.read(demoPersistenceProvider.notifier).flush();
    final persistence = container.read(demoPersistenceProvider.notifier);
    expect(await persistence.resetActivity(), true);
    expect(repository.workspace.budgets['2024-10']!.monthlyLimit, 3000000);
    expect(repository.workspace.subscriptions.first.active, false);
    container.read(demoLedgerProvider.notifier).createManual(draft());
    await container.read(receiptReviewProvider.future);
    final review = container.read(receiptReviewProvider.notifier);
    review.saveItem(
      reviewed(container.read(receiptReviewProvider).value!.items.last),
    );
    review.save();
    await persistence.flush();
    final activity = repository.workspace;
    repository.onSave = (_) async => throw Exception('reset failed');
    expect(await persistence.resetPlans(), false);
    expect(
      container.read(demoBudgetPlansProvider)['2024-10']!.monthlyLimit,
      3000000,
    );
    expect(repository.workspace, activity);
    repository.onSave = null;
    expect(await persistence.resetPlans(), true);
    expect(repository.workspace.budgets['2024-10'], budgetFixture());
    expect(repository.workspace.subscriptions.first.active, true);
    expect(repository.workspace.ledger, activity.ledger);
    expect(repository.workspace.receipts, activity.receipts);
    expect(
      container.read(demoBudgetPlansProvider.notifier).viewFor(2024, 10).spent,
      budgetFixture().spent + 32500 + 52550,
    );
  });
}
