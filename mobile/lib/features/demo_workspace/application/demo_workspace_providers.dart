import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/sqlite_demo_workspace_repository.dart';
import '../../settings/application/settings_provider.dart';
import '../../settings/domain/demo_preferences.dart';
import '../../onboarding/application/onboarding_provider.dart';
import '../../budgets/application/budgets_provider.dart';
import '../../subscriptions/application/subscriptions_provider.dart';
import '../../receipts/application/receipts_provider.dart';
import '../../transactions/application/transactions_provider.dart';
import '../domain/demo_workspace.dart';

/// Disk storage is injected at bootstrap; tests/previews default to memory.
final demoWorkspaceRepositoryProvider = Provider<DemoWorkspaceRepository?>(
  (ref) => null,
);
final initialDemoWorkspaceProvider = Provider<DemoWorkspace?>((ref) => null);
final demoPersistenceEnabledProvider = Provider<bool>(
  (ref) => ref.watch(demoWorkspaceRepositoryProvider) != null,
);

enum DemoSaveStatus { memory, saved, saving, error, resetting }

class DemoPersistence extends Notifier<DemoSaveStatus> {
  DemoWorkspace? _pending;
  Future<void>? _draining;
  bool _scheduled = false;
  bool _resetting = false;

  @override
  DemoSaveStatus build() {
    if (ref.watch(demoWorkspaceRepositoryProvider) == null) {
      return DemoSaveStatus.memory;
    }
    ref.listen(demoLedgerProvider, (_, _) => _schedule());
    ref.listen(savedDemoReceiptsProvider, (_, _) => _schedule());
    ref.listen(demoBudgetPlansProvider, (_, _) => _schedule());
    ref.listen(demoSubscriptionsProvider, (_, _) => _schedule());
    ref.listen(settingsProvider, (_, _) => _schedule());
    ref.listen(demoIntroductionCompletedProvider, (_, _) => _schedule());
    return DemoSaveStatus.saved;
  }

  void _schedule() {
    if (_resetting || _scheduled) return;
    _scheduled = true;
    scheduleMicrotask(() {
      if (!_scheduled) return;
      _scheduled = false;
      if (!ref.mounted || _resetting) return;
      if (!_capture()) return;
      unawaited(flush());
    });
  }

  DemoPreferences _preferences() => DemoPreferences(
    appearance: ref.read(settingsProvider),
    introductionCompleted: ref.read(demoIntroductionCompletedProvider),
  );

  bool _capture() {
    try {
      _pending = DemoWorkspace(
        preferences: _preferences(),
        ledger: ref.read(demoLedgerProvider),
        receipts: ref.read(savedDemoReceiptsProvider),
        budgets: ref.read(demoBudgetPlansProvider),
        subscriptions: ref.read(demoSubscriptionsProvider),
      );
      return true;
    } catch (_) {
      state = DemoSaveStatus.error;
      return false;
    }
  }

  /// Serializes writes and retains the newest snapshot after failure for retry.
  Future<void> flush() async {
    if (!ref.read(demoPersistenceEnabledProvider)) return;
    if (state == DemoSaveStatus.error && !_resetting && !_capture()) return;
    if (_scheduled) {
      _scheduled = false;
      if (!_capture()) return;
    }
    if (_draining != null) {
      await _draining;
      if (_pending != null && state != DemoSaveStatus.error) await flush();
      return;
    }
    final work = _drain();
    _draining = work;
    await work;
    _draining = null;
  }

  Future<void> _drain() async {
    final repository = ref.read(demoWorkspaceRepositoryProvider)!;
    while (_pending != null) {
      final snapshot = _pending!;
      _pending = null;
      if (!_resetting) state = DemoSaveStatus.saving;
      try {
        await repository.save(snapshot);
      } catch (_) {
        _pending ??= snapshot;
        if (ref.mounted && !_resetting) state = DemoSaveStatus.error;
        return;
      }
      if (!ref.mounted) return;
    }
    if (!_resetting) state = DemoSaveStatus.saved;
  }

  Future<bool> resetActivity() => _reset(plans: false);
  Future<bool> resetPlans() => _reset(plans: true);

  Future<bool> _reset({required bool plans}) async {
    if (_resetting || !ref.read(demoPersistenceEnabledProvider)) return false;
    _resetting = true;
    state = DemoSaveStatus.resetting;
    await flush();
    if (!ref.mounted) return false;
    late final DemoWorkspace seed;
    try {
      final fixture = initialDemoWorkspace();
      seed = DemoWorkspace(
        preferences: _preferences(),
        ledger: plans ? ref.read(demoLedgerProvider) : fixture.ledger,
        receipts: plans
            ? ref.read(savedDemoReceiptsProvider)
            : fixture.receipts,
        budgets: plans ? fixture.budgets : ref.read(demoBudgetPlansProvider),
        subscriptions: plans
            ? fixture.subscriptions
            : ref.read(demoSubscriptionsProvider),
      );
      await ref.read(demoWorkspaceRepositoryProvider)!.save(seed);
    } catch (_) {
      _resetting = false;
      state = DemoSaveStatus.error;
      return false;
    }
    if (!ref.mounted) return false;
    _pending = null;
    if (plans) {
      ref.read(demoBudgetPlansProvider.notifier).restore(seed.budgets);
      ref.read(demoSubscriptionsProvider.notifier).restore(seed.subscriptions);
      ref.invalidate(dismissedBudgetSuggestionsProvider);
    } else {
      ref.read(demoLedgerProvider.notifier).restore(seed.ledger);
      ref.read(savedDemoReceiptsProvider.notifier).restore(seed.receipts);
      ref.invalidate(receiptReviewProvider);
    }
    _resetting = false;
    state = DemoSaveStatus.saved;
    return true;
  }
}

final demoPersistenceProvider =
    NotifierProvider<DemoPersistence, DemoSaveStatus>(DemoPersistence.new);
