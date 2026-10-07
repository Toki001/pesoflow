import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../application/finance_controller.dart';

class FinanceStorageBoundary extends ConsumerStatefulWidget {
  const FinanceStorageBoundary({required this.child, super.key});
  final Widget child;
  @override
  ConsumerState<FinanceStorageBoundary> createState() =>
      _FinanceStorageBoundaryState();
}

class _FinanceStorageBoundaryState extends ConsumerState<FinanceStorageBoundary>
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
    if (state == AppLifecycleState.resumed) {
      unawaited(
        ref
            .read(financeControllerProvider.notifier)
            .evaluateConditions()
            .catchError((Object _) {}),
      );
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(ref.read(financeControllerProvider.notifier).flush());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(financeControllerProvider);
    return Column(
      children: [
        if (state.error != null)
          Material(
            color: context.colors.surface,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(state.error!, style: AppTypography.bodySmall),
                    ),
                    IconButton(
                      onPressed: () => ref
                          .read(financeControllerProvider.notifier)
                          .dismissError(),
                      tooltip: 'Dismiss save message',
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
