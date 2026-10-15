import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../workspace/application/finance_controller.dart';
import '../data/transaction_csv.dart';

Future<void> exportTransactions(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Export transactions'),
      content: const Text(
        'The CSV contains readable financial records. Anyone with access to the file can read them. Choose a private destination.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Export CSV'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  try {
    await ref.read(financeControllerProvider.notifier).flush();
    if (!context.mounted) return;
    final bytes = transactionCsv(ref.read(workspaceProvider));
    final saved = await FilePicker.saveFile(
      fileName: 'pesoflow-transactions.csv',
      bytes: bytes,
      mimeType: 'text/csv',
      dialogTitle: 'Export transactions',
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            saved == null ? 'Export canceled.' : 'Transactions exported.',
          ),
        ),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not export. Your saved records are unchanged. Please try again.',
          ),
        ),
      );
    }
  }
}
