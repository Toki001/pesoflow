import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pesoflow/app/theme/app_colors.dart';
import 'package:pesoflow/app/theme/app_radius.dart';
import 'package:pesoflow/app/theme/app_spacing.dart';
import 'package:pesoflow/app/theme/app_typography.dart';
import 'package:pesoflow/core/widgets/finance_card.dart';
import 'package:pesoflow/core/widgets/task_screen.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/features/onboarding/application/onboarding_provider.dart';
import 'package:pesoflow/features/settings/application/settings_provider.dart';
import 'package:pesoflow/features/settings/domain/appearance.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = ref.watch(workspaceProvider);
    final appearance = ref.watch(settingsProvider);
    return TaskScreen(
      title: 'Settings',
      backIcon: Icons.arrow_back,
      backTooltip: 'Back',
      fallbackRoute: '/home',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FinanceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Make PesoFlow comfortable',
                  style: AppTypography.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Preferences and financial records stay on this device after restart.',
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
                    onSelect: () async {
                      try {
                        await ref
                            .read(settingsProvider.notifier)
                            .setAppearance(option);
                      } catch (_) {}
                    },
                  ),
                ],
              ],
            ),
          ),
          const _SectionTitle('Accounts & data'),
          FinanceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsLink(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Accounts',
                  subtitle: 'Manage your manually tracked accounts',
                  onTap: () => context.push('/accounts'),
                ),
                const Divider(),
                _SettingsLink(
                  icon: Icons.backup_outlined,
                  title: 'Backup & export',
                  subtitle: 'Save an encrypted backup or restore your records',
                  onTap: () => context.push('/settings/backup'),
                ),
                const Divider(),
                _SettingsLink(
                  icon: Icons.info_outline,
                  title: 'View introduction',
                  subtitle: 'Review how local tracking works',
                  onTap: () {
                    ref.invalidate(onboardingProvider);
                    context.push('/onboarding');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FinanceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your financial records', style: AppTypography.merchant),
                const SizedBox(height: 8),
                Text(
                  'Currency: ${w.preferences.currency} • English (Philippines)',
                ),
                const SizedBox(height: 8),
                const Text(
                  'Stored locally with encryption. Save a password-protected backup before changing devices or uninstalling. Automatic cloud backup, bank connections and receipt scanning are not available.',
                ),
              ],
            ),
          ),
          const _SectionTitle('Notifications'),
          FinanceCard(
            child: Material(
              color: Colors.transparent,
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Financial alerts'),
                subtitle: const Text(
                  'Budget and tracked-renewal notices inside PesoFlow',
                ),
                value: w.preferences.notifications,
                onChanged: (v) async {
                  try {
                    await ref
                        .read(financeControllerProvider.notifier)
                        .savePreferences(
                          w.preferences.copyWith(notifications: v),
                        );
                  } catch (_) {}
                },
              ),
            ),
          ),
        ],
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
