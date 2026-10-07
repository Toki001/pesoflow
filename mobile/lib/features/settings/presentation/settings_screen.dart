import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/finance_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/task_screen.dart';
import '../../onboarding/application/onboarding_provider.dart';
import '../application/settings_provider.dart';
import '../domain/appearance.dart';
import '../../demo_workspace/application/demo_workspace_providers.dart';
import '../../demo_workspace/presentation/demo_storage_status.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(settingsProvider);
    final persisted = ref.watch(demoPersistenceEnabledProvider);
    final c = context.colors;
    return TaskScreen(
      title: 'Settings',
      backIcon: Icons.arrow_back,
      backTooltip: 'Back',
      fallbackRoute: '/home',
      child: SingleChildScrollView(
        key: const PageStorageKey('settings-scroll'),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FinanceCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusBadge(
                    'Demo session',
                    foreground: c.primary,
                    background: c.soft(c.primary, AppColors.primarySoft),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Make PesoFlow comfortable',
                    style: AppTypography.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Preferences apply across the app for this session and reset when you restart.',
                    style: AppTypography.bodySmall.copyWith(
                      color: c.secondaryInk,
                    ),
                  ),
                ],
              ),
            ),
            const _SectionTitle('Appearance'),
            FinanceCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final option in Appearance.values) ...[
                    if (option != Appearance.system) const Divider(),
                    _AppearanceOption(
                      option: option,
                      selected: appearance == option,
                      onSelect: () => ref
                          .read(settingsProvider.notifier)
                          .setAppearance(option),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'System follows changes to your device’s light or dark appearance.',
              style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
            ),
            const _SectionTitle('Demo & data'),
            FinanceCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsLink(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Sample accounts',
                    subtitle: 'View illustrative balances and account profiles',
                    onTap: () => context.push('/accounts'),
                  ),
                  const Divider(),
                  _SettingsLink(
                    icon: Icons.info_outline,
                    title: 'View introduction',
                    subtitle: 'Review the demo and its limitations',
                    onTap: () {
                      ref.invalidate(onboardingProvider);
                      context.push('/onboarding');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FinanceCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Your demo data', style: AppTypography.merchant),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    persisted
                        ? 'Balances and transactions are samples. Transaction edits, saved receipts, budget plans and subscription tracking stay on this device. Other edits last for this session. No bank or wallet is connected, no funds can move, and real camera capture and OCR are unavailable.'
                        : 'Balances and transactions are samples. Edits stay in memory for this session. No bank or wallet is connected, no funds can move, and real camera capture and OCR are unavailable.',
                    style: AppTypography.bodySmall.copyWith(
                      color: c.secondaryInk,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Currency · PHP (₱)\nFormatting · English (Philippines)',
                    style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (persisted) ...[
              const DemoStorageSettings(),
              const SizedBox(height: AppSpacing.lg),
            ],
            OutlinedButton(
              onPressed: appearance == Appearance.system
                  ? null
                  : () =>
                        ref.read(settingsProvider.notifier).restoreAppearance(),
              child: const Text('Restore device appearance'),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'This changes only appearance. Your demo edits remain intact.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
    child: Semantics(
      header: true,
      child: Text(title, style: AppTypography.headlineSmall),
    ),
  );
}

class _AppearanceOption extends StatelessWidget {
  const _AppearanceOption({
    required this.option,
    required this.selected,
    required this.onSelect,
  });
  final Appearance option;
  final bool selected;
  final VoidCallback onSelect;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      checked: selected,
      onTap: onSelect,
      inMutuallyExclusiveGroup: true,
      button: true,
      label: '${option.label} appearance',
      hint: option.description,
      excludeSemantics: true,
      child: InkWell(
        key: ValueKey('appearance-${option.name}'),
        borderRadius: BorderRadius.circular(AppRadius.homeCard),
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(switch (option) {
                Appearance.system => Icons.brightness_auto_outlined,
                Appearance.light => Icons.light_mode_outlined,
                Appearance.dark => Icons.dark_mode_outlined,
              }, color: selected ? c.primary : c.mutedInk),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.label, style: AppTypography.merchant),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      option.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: c.mutedInk,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? c.primary : c.mutedInk,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsLink extends StatelessWidget {
  const _SettingsLink({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: InkWell(
      borderRadius: BorderRadius.circular(AppRadius.homeCard),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: context.colors.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title, style: AppTypography.merchant),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.mutedInk,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    ),
  );
}
