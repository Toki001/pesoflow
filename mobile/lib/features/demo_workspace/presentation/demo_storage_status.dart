import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/finance_card.dart';
import '../application/demo_workspace_providers.dart';

class DemoStorageSettings extends ConsumerWidget {
  const DemoStorageSettings({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(demoPersistenceProvider);
    final busy =
        status == DemoSaveStatus.resetting || status == DemoSaveStatus.saving;
    return FinanceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Local demo activity', style: AppTypography.merchant),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Transactions, saved receipt details, budget plans and subscription tracking stay on this device after restart. Appearance, completed demo introduction and sample alert read markers are also saved. Sample connections remain session-only. Local demo storage is not encrypted; use sample data only.',
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.secondaryInk,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            liveRegion: true,
            child: Text(
              switch (status) {
                DemoSaveStatus.memory => 'Memory-only preview',
                DemoSaveStatus.saved => 'Demo activity saved on this device',
                DemoSaveStatus.saving => 'Saving demo activity…',
                DemoSaveStatus.error =>
                  'Local save failed. Changes remain in memory.',
                DemoSaveStatus.resetting => 'Resetting local demo…',
              },
              style: AppTypography.bodySmall.copyWith(
                color: status == DemoSaveStatus.error
                    ? context.colors.warning
                    : context.colors.mutedInk,
              ),
            ),
          ),
          if (status == DemoSaveStatus.error)
            TextButton(
              onPressed: () =>
                  ref.read(demoPersistenceProvider.notifier).flush(),
              child: const Text('Retry local save'),
            ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: busy
                ? null
                : () async {
                    final reset = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Reset demo activity?'),
                        content: const Text(
                          'Restore the original sample transactions and remove saved demo receipts from this device. Transaction edits and added entries will be removed. Budget plans, subscription tracking, appearance, alert read markers and sample account choices stay as they are. No financial institution is contacted.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Reset activity'),
                          ),
                        ],
                      ),
                    );
                    if (reset != true || !context.mounted) return;
                    final success = await ref
                        .read(demoPersistenceProvider.notifier)
                        .resetActivity();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Original demo activity restored on this device.'
                              : 'We could not reset local activity. Please try again.',
                        ),
                      ),
                    );
                  },
            child: const Text('Reset demo activity'),
          ),
          const SizedBox(height: AppSpacing.xs),
          OutlinedButton(
            onPressed: busy
                ? null
                : () async {
                    final reset = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Reset demo plans?'),
                        content: const Text(
                          'Restore the original sample budget plans and subscription tracking. Added plans, edited limits and tracking changes will be removed. Transactions, saved receipts, preferences and alert read markers stay as they are, so budget spending still reflects recorded activity. This does not cancel services or create charges.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Reset plans'),
                          ),
                        ],
                      ),
                    );
                    if (reset != true || !context.mounted) return;
                    final success = await ref
                        .read(demoPersistenceProvider.notifier)
                        .resetPlans();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Original demo plans restored on this device.'
                              : 'We could not reset local plans. Please try again.',
                        ),
                      ),
                    );
                  },
            child: const Text('Reset demo plans'),
          ),
          const SizedBox(height: AppSpacing.xs),
          OutlinedButton(
            onPressed: busy
                ? null
                : () async {
                    final reset = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Reset demo alerts?'),
                        content: const Text(
                          'Restore the original sample read markers: three alerts unread and one read. Alert content, transactions, saved receipts, plans and preferences stay unchanged. This sends no notifications and contacts no financial institution.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Reset alerts'),
                          ),
                        ],
                      ),
                    );
                    if (reset != true || !context.mounted) return;
                    final success = await ref
                        .read(demoPersistenceProvider.notifier)
                        .resetAlerts();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Original demo alert read markers restored on this device.'
                              : 'We could not reset local alert markers. Please try again.',
                        ),
                      ),
                    );
                  },
            child: const Text('Reset demo alerts'),
          ),
        ],
      ),
    );
  }
}

/// Errors are visible on every route; pending reset temporarily blocks edits.
class DemoStorageBoundary extends ConsumerStatefulWidget {
  const DemoStorageBoundary({required this.child, super.key});
  final Widget child;
  @override
  ConsumerState<DemoStorageBoundary> createState() =>
      _DemoStorageBoundaryState();
}

class _DemoStorageBoundaryState extends ConsumerState<DemoStorageBoundary>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(ref.read(demoPersistenceProvider.notifier).flush());
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(demoPersistenceProvider);
    final resetting = status == DemoSaveStatus.resetting;
    return Column(
      children: [
        if (status == DemoSaveStatus.error || resetting)
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          resetting ? 'Resetting local demo…' : 'Local save failed. Changes are still in memory.',
                          style: AppTypography.bodySmall,
                        ),
                      ),
                    ),
                    if (!resetting)
                      TextButton(
                        onPressed: () =>
                            ref.read(demoPersistenceProvider.notifier).flush(),
                        child: const Text('Retry save'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        Expanded(
          child: AbsorbPointer(absorbing: resetting, child: widget.child),
        ),
      ],
    );
  }
}
