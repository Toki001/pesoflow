import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/workspace/application/finance_controller.dart';
import '../features/workspace/domain/finance_workspace.dart';
import 'app.dart';
import 'theme/app_theme.dart';
import 'theme/app_typography.dart';

class FinanceBootstrap extends StatefulWidget {
  const FinanceBootstrap({required this.repository, super.key});
  final FinanceRepository repository;
  @override
  State<FinanceBootstrap> createState() => _FinanceBootstrapState();
}

class _FinanceBootstrapState extends State<FinanceBootstrap> {
  late Future<FinanceWorkspace> loading;
  @override
  void initState() {
    super.initState();
    loading = widget.repository.load();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<FinanceWorkspace>(
    future: loading,
    builder: (_, snapshot) {
      if (snapshot.hasData) {
        return ProviderScope(
          overrides: [
            financeRepositoryProvider.overrideWithValue(widget.repository),
            initialWorkspaceProvider.overrideWithValue(snapshot.data!),
          ],
          child: const PesoFlowApp(),
        );
      }
      return MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snapshot.hasError
                          ? 'Your saved data could not be opened'
                          : 'Opening PesoFlow…',
                      textAlign: TextAlign.center,
                      style: AppTypography.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.hasError
                          ? 'Your stored records have not been replaced. Unlock your device and try again. If the problem continues, keep the app installed to preserve your data.'
                          : 'Opening your encrypted financial workspace.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    if (snapshot.hasError)
                      FilledButton(
                        onPressed: () => setState(() {
                          loading = widget.repository.load();
                        }),
                        child: const Text('Try again'),
                      )
                    else
                      const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
