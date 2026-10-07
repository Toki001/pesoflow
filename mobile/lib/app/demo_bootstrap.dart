import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/demo_workspace/application/demo_workspace_providers.dart';
import '../features/demo_workspace/domain/demo_workspace.dart';
import '../core/storage/sqlite_demo_workspace_repository.dart';
import 'app.dart';
import 'theme/app_theme.dart';
import 'theme/app_spacing.dart';
import 'theme/app_typography.dart';

/// Load before providers render. Read failures never silently reseed stored data.
class DemoBootstrap extends StatefulWidget {
  const DemoBootstrap({required this.repository, super.key});
  final DemoWorkspaceRepository repository;
  @override
  State<DemoBootstrap> createState() => _DemoBootstrapState();
}

class _DemoBootstrapState extends State<DemoBootstrap> {
  late Future<DemoWorkspace> loading;
  @override
  void initState() {
    super.initState();
    loading = widget.repository.load();
  }

  void retry() => setState(() {
    loading = widget.repository.load();
  });
  @override
  Widget build(BuildContext context) => FutureBuilder<DemoWorkspace>(
    future: loading,
    builder: (_, state) {
      if (state.connectionState == ConnectionState.done && state.hasData) {
        return ProviderScope(
          overrides: [
            demoWorkspaceRepositoryProvider.overrideWithValue(
              widget.repository,
            ),
            initialDemoWorkspaceProvider.overrideWithValue(state.data!),
          ],
          child: const PesoFlowApp(),
        );
      }
      return MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: Scaffold(
          body: SafeArea(
            child: Builder(
              builder: (context) => Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.hasError
                            ? 'Your local demo could not load'
                            : 'Loading your demo…',
                        style: AppTypography.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        state.hasError
                            ? 'Stored data has not been replaced. Retry, or confirm a reset of saved transactions, receipts, budget plans and subscription tracking. No financial institution was contacted.'
                            : 'Restoring demo data saved on this device.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium,
                      ),
                      if (state.hasError) ...[
                        const SizedBox(height: AppSpacing.md),
                        FilledButton(
                          onPressed: retry,
                          child: const Text('Try Again'),
                        ),
                        TextButton(
                          onPressed: () async {
                            final reset = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Reset stored demo data?'),
                                content: const Text(
                                  'Replace stored transactions, saved receipts, budget plans and subscription tracking with the original samples. This removes all saved demo edits on this device. No financial institution is contacted.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Reset demo data'),
                                  ),
                                ],
                              ),
                            );
                            if (reset != true || !mounted) return;
                            setState(() {
                              loading = _reset();
                            });
                          },
                          child: const Text('Reset stored demo data'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
  Future<DemoWorkspace> _reset() async {
    final seed = initialDemoWorkspace();
    await widget.repository.save(seed);
    return seed;
  }
}
