import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pesoflow/app/theme/app_colors.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/app/theme/app_spacing.dart';
import 'package:pesoflow/app/theme/app_typography.dart';
import 'package:pesoflow/core/widgets/finance_card.dart';
import 'package:pesoflow/core/widgets/status_badge.dart';
import 'package:pesoflow/features/onboarding/application/onboarding_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saving = ref.watch(financeControllerProvider).saving;
    final step = ref.watch(onboardingProvider);
    final controller = ref.read(onboardingProvider.notifier);
    final c = context.colors;
    final title = switch (step) {
      OnboardingStep.overview => 'Understand your money',
      OnboardingStep.plans => 'Make room for your plans',
      OnboardingStep.ready => 'Start with your own finances',
    };
    final description = switch (step) {
      OnboardingStep.overview =>
        'See your balance, spending and savings together in one calm overview.',
      OnboardingStep.plans => 'Follow your spending against your limits, with clear guidance on what is left.',
      OnboardingStep.ready => 'Add an account and record your first transaction whenever you are ready.',
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
                        if (step != OnboardingStep.ready)
                          TextButton(
                            onPressed: controller.skip,
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
                              'Private manual tracking',
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
                          FinanceCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _OnboardingFact(
                                  icon: Icons.account_balance_wallet_outlined,
                                  title: 'Your accounts, your records',
                                  detail: 'Start empty. Add a cash, bank or wallet account with its actual starting balance.',
                                ),
                                const SizedBox(height: 16),
                                _OnboardingFact(
                                  icon: Icons.pie_chart_outline,
                                  title: 'Budgets based on real spending',
                                  detail: 'Set optional monthly limits. Income and transfers stay separate from expenses.',
                                ),
                                const SizedBox(height: 16),
                                _OnboardingFact(
                                  icon: Icons.lock_outline,
                                  title: 'Saved on this device',
                                  detail: 'Your records are stored locally with encryption. No bank connection or server account is required. Currency: Philippine peso (PHP).',
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
                          onPressed: saving
                              ? null
                              : step == OnboardingStep.ready
                              ? () async {
                                  try {
                                    await ref
                                        .read(
                                          financeControllerProvider.notifier,
                                        )
                                        .savePreferences(
                                          ref
                                              .read(workspaceProvider)
                                              .preferences
                                              .copyWith(
                                                onboardingCompleted: true,
                                              ),
                                        );
                                    if (context.mounted) context.go('/home');
                                  } catch (_) {
                                    /* Shared save error retains this screen. */
                                  }
                                }
                              : controller.next,
                          child: Text(
                            step == OnboardingStep.ready
                                ? 'Get started'
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

class _OnboardingFact extends StatelessWidget {
  const _OnboardingFact({
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
