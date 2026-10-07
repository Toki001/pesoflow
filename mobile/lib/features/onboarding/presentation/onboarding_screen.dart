import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../demo_workspace/application/demo_workspace_providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/finance_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../dashboard/data/dashboard_fixture.dart';
import '../../dashboard/presentation/widgets/balance_summary.dart';
import '../../dashboard/presentation/widgets/budget_summary.dart';
import '../application/onboarding_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persisted = ref.watch(demoPersistenceEnabledProvider);
    final step = ref.watch(onboardingProvider);
    final controller = ref.read(onboardingProvider.notifier);
    final c = context.colors;
    final title = switch (step) {
      OnboardingStep.overview => 'Understand your money',
      OnboardingStep.plans => 'Make room for your plans',
      OnboardingStep.demo => 'Explore PesoFlow with sample data',
    };
    final description = switch (step) {
      OnboardingStep.overview =>
        'See your balance, spending and savings together in one calm overview.',
      OnboardingStep.plans => 'Follow your spending against your limits, with clear guidance on what is left.',
      OnboardingStep.demo => 'Try the dashboard, budgets and receipt review without connecting an account.',
    };
    return PopScope(
      canPop: step == OnboardingStep.overview,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.back();
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 512),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    constraints: const BoxConstraints(minHeight: 80),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: c.soft(
                            c.primary,
                            AppColors.primarySoft,
                          ),
                          child: Text(
                            'PF',
                            style: AppTypography.labelMedium.copyWith(
                              color: c.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            'PesoFlow',
                            style: AppTypography.headlineSmall,
                          ),
                        ),
                        if (step != OnboardingStep.demo)
                          TextButton(
                            onPressed: controller.skipToDemo,
                            child: const Text('Skip'),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      key: ValueKey(step),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: StatusBadge(
                              'Demo preview',
                              foreground: c.primary,
                              background: c.soft(
                                c.primary,
                                AppColors.primarySoft,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Semantics(
                            header: true,
                            child: Text(
                              title,
                              style: AppTypography.headlineLarge,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            description,
                            style: AppTypography.bodyMedium.copyWith(
                              color: c.secondaryInk,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (step == OnboardingStep.overview)
                            BalanceHero(data: homeFixture()),
                          if (step == OnboardingStep.plans)
                            BudgetSummary(data: homeFixture()),
                          if (step != OnboardingStep.demo) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Sample figures · October 2024',
                              style: AppTypography.bodySmall.copyWith(
                                color: c.mutedInk,
                              ),
                            ),
                          ],
                          if (step == OnboardingStep.demo)
                            FinanceCard(
                              padding: EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                spacing: AppSpacing.lg,
                                children: [
                                  _DemoFact(
                                    icon: Icons.visibility_outlined,
                                    title: 'Sample financial data',
                                    detail: 'Balances, accounts and transactions are illustrative. They are not your real finances.',
                                  ),
                                  _DemoFact(
                                    icon: Icons.history_outlined,
                                    title: persisted
                                        ? 'Demo activity stays on this device'
                                        : 'Changes last for this session',
                                    detail: persisted
                                        ? 'Transactions, saved receipts, budget plans and subscription tracking stay locally after restart. Appearance and completed demo introduction are also saved. Notifications and sample connections reset. Use sample data only; local demo storage is not encrypted. Nothing is saved to a server.'
                                        : 'Expenses, budgets and receipt edits reset when you restart the app. Nothing is saved to a server.',
                                  ),
                                  _DemoFact(
                                    icon: Icons.lock_outline,
                                    title: 'No account connection',
                                    detail: 'No bank or wallet is connected. PesoFlow cannot transfer money in this demo and does not ask for credentials.',
                                  ),
                                  _DemoFact(
                                    icon: Icons.receipt_long_outlined,
                                    title: 'Receipt review uses a fixture',
                                    detail: 'Camera capture and real receipt recognition are not available yet.',
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: c.surface,
                      border: Border(top: BorderSide(color: c.border)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            'Step ${step.index + 1} of 3',
                            textAlign: TextAlign.center,
                            style: AppTypography.labelMedium.copyWith(
                              color: c.mutedInk,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        FilledButton(
                          onPressed: step == OnboardingStep.demo
                              ? () {
                                  ref
                                      .read(
                                        demoIntroductionCompletedProvider
                                            .notifier,
                                      )
                                      .complete();
                                  context.go('/home');
                                }
                              : controller.next,
                          child: Text(
                            step == OnboardingStep.demo
                                ? 'Explore demo'
                                : 'Next',
                          ),
                        ),
                        if (step != OnboardingStep.overview)
                          TextButton(
                            onPressed: controller.back,
                            child: const Text('Back'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoFact extends StatelessWidget {
  const _DemoFact({
    required this.icon,
    required this.title,
    required this.detail,
  });
  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: context.colors.primary),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: AppTypography.merchant),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              detail,
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.secondaryInk,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
