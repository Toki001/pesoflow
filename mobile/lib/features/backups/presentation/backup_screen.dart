import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/finance_card.dart';
import '../../../core/widgets/task_screen.dart';
import '../../workspace/application/finance_controller.dart';
import '../../workspace/domain/finance_workspace.dart';
import '../application/backup_actions.dart';
import '../data/transaction_csv.dart';
import '../domain/finance_backup.dart';

class BackupSettingsScreen extends ConsumerWidget {
  const BackupSettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = ref.watch(workspaceProvider);
    return BackupScreen(
      actions: ref.watch(backupActionsProvider),
      currentDescription:
          '${w.accounts.length} accounts and ${w.ledger.length} transactions on this device',
      onRestored: () => context.go('/home'),
    );
  }
}

class BackupScreen extends StatefulWidget {
  const BackupScreen({
    required this.actions,
    required this.onRestored,
    this.recovery = false,
    this.currentDescription = '',
    super.key,
  });
  final BackupActions actions;
  final VoidCallback onRestored;
  final bool recovery;
  final String currentDescription;
  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final password = TextEditingController();
  final confirmation = TextEditingController();
  bool busy = false;
  String? message;
  Uint8List? selected;
  FinanceBackup? preview;
  int? revision;
  @override
  void dispose() {
    password.dispose();
    confirmation.dispose();
    super.dispose();
  }

  Future<void> run(Future<void> Function() operation) async {
    if (busy) return;
    setState(() {
      busy = true;
      message = null;
    });
    try {
      await operation();
    } on BackupFailure catch (e) {
      if (mounted) setState(() => message = e.message);
    } on WorkspaceConflict {
      if (mounted) {
        setState(() {
          preview = null;
          message = 'Your data changed while reviewing. Open the backup again before restoring.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => message = 'This operation could not finish. Your previously saved data is intact. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void say(String value) {
    if (mounted) setState(() => message = value);
  }

  Future<void> exportBackup() => run(() async {
    if (password.text != confirmation.text) {
      throw const BackupFailure('The passwords do not match.');
    }
    final snapshot = await widget.actions.capture();
    final bytes = await widget.actions.seal(snapshot, password.text);
    if (!mounted) return;
    final saved = await widget.actions.files.save(
      'pesoflow-${DateFormat('yyyyMMdd-HHmmss').format(snapshot.createdAt)}.pfbackup',
      bytes,
    );
    if (saved) {
      password.clear();
      confirmation.clear();
    }
    say(
      saved
          ? 'Backup saved. Keep the file and password somewhere safe, separately from this app.'
          : 'Save canceled. No backup was saved.',
    );
  });
  Future<void> choose() => run(() async {
    final bytes = await widget.actions.files.pick();
    if (!mounted) return;
    setState(() {
      selected = bytes;
      preview = null;
      revision = null;
    });
    if (bytes == null) say('Selection canceled. Your data is unchanged.');
  });
  Future<void> unlock() => run(() async {
    final backup = await widget.actions.open(selected!, password.text);
    final current = await widget.actions.revision();
    if (!mounted) return;
    password.clear();
    confirmation.clear();
    setState(() {
      preview = backup;
      revision = current;
      selected = null;
    });
  });
  Future<void> restore() async {
    final backup = preview;
    final expected = revision;
    if (busy || backup == null || expected == null) return;
    final approved = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Replace local data?'),
        content: Text(
          'Restore ${backup.workspace.accounts.length} accounts and ${backup.workspace.ledger.length} transactions, along with budgets, plans, receipts and preferences. This replaces all existing local data; it does not merge records. Save a backup of your current data first. This cannot be undone without a backup.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Replace and restore'),
          ),
        ],
      ),
    );
    if (approved != true || !mounted) return;
    await run(() async {
      await widget.actions.restore(backup, expected);
      if (!mounted) return;
      setState(() {
        preview = null;
        revision = null;
      });
      widget.onRestored();
    });
  }

  Future<void> csv() async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Export readable transactions?'),
        content: const Text(
          'CSV includes your transaction details and notes without encryption. Anyone with the file can read them. It cannot restore PesoFlow. Choose a private save location.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Choose location'),
          ),
        ],
      ),
    );
    if (approved != true || !mounted) return;
    await run(() async {
      final bytes = transactionCsv(await widget.actions.transactions());
      if (bytes.length > maxBackupPlaintextBytes) {
        throw const BackupFailure('This export exceeds the 32 MB limit.');
      }
      final saved = await widget.actions.files.save(
        'pesoflow-transactions.csv',
        bytes,
        csv: true,
      );
      say(saved ? 'Transaction CSV saved.' : 'Export canceled.');
    });
  }

  Widget card(String title, List<Widget> children) => FinanceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: AppTypography.headlineSmall),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );
  Widget secret(TextEditingController controller, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      enabled: !busy,
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: TaskScreen(
      title: widget.recovery ? 'Recover from backup' : 'Backup & export',
      fallbackRoute: '/settings',
      onClose: busy
          ? () {}
          : widget.recovery
          ? () => Navigator.of(context).pop()
          : null,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          card('Keep a recoverable copy', [
            const Text(
              'An encrypted backup contains your accounts, transactions, budgets, plans, receipt data and preferences. Use the file and its password to restore on another device.',
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose a strong password of at least 12 characters. PesoFlow does not store it and cannot recover a forgotten password.',
            ),
            if (widget.recovery) ...[
              const SizedBox(height: 8),
              const Text(
                'Your existing local data could not be opened. Only a previously saved backup can recover it. Nothing changes until you confirm replacement.',
              ),
            ],
          ]),
          const SizedBox(height: 16),
          if (preview == null)
            card('Backup password', [
              secret(password, 'Backup password'),
              if (!widget.recovery)
                secret(confirmation, 'Confirm password for new backup'),
              if (!widget.recovery)
                FilledButton(
                  onPressed: busy ? null : exportBackup,
                  child: const Text('Save encrypted backup'),
                ),
            ]),
          const SizedBox(height: 16),
          card('Restore a backup', [
            if (widget.currentDescription.isNotEmpty)
              Text(widget.currentDescription),
            const SizedBox(height: 8),
            const Text(
              'Restore replaces local records. It never adds duplicate copies to existing records.',
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: busy ? null : choose,
              child: const Text('Choose backup file'),
            ),
            if (selected != null)
              FilledButton(
                onPressed: busy ? null : unlock,
                child: const Text('Unlock and review'),
              ),
            if (preview case final b?) ...[
              const SizedBox(height: 12),
              Text(
                'Backup from ${DateFormat('MMM d, yyyy · h:mm a').format(b.createdAt.toLocal())}',
                style: AppTypography.merchant,
              ),
              const SizedBox(height: 8),
              Text(
                '${b.workspace.accounts.length} accounts • ${b.workspace.ledger.length} transactions\n${b.workspace.budgets.length} budgets • ${b.workspace.subscriptions.length} plans\n${b.workspace.receipts.length} receipts • ${b.images.length} receipt images\nCurrency: ${b.workspace.preferences.currency}',
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: busy ? null : restore,
                child: const Text('Review replacement'),
              ),
              TextButton(
                onPressed: busy
                    ? null
                    : () => setState(() {
                        preview = null;
                        revision = null;
                      }),
                child: const Text('Discard preview'),
              ),
            ],
          ]),
          if (!widget.recovery) ...[
            const SizedBox(height: 16),
            card('Readable transaction export', [
              const Text(
                'CSV contains transactions only, with amounts in minor units (centavos for PHP). It is not a backup.',
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: busy ? null : csv,
                child: const Text('Export transaction CSV'),
              ),
            ]),
          ],
          if (busy)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Semantics(
                liveRegion: true,
                child: Text('Working… Keep this screen open.'),
              ),
            ),
          if (message != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  message!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.colors.secondaryInk,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
