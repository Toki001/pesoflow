import 'package:flutter/material.dart';
import 'package:pesoflow/features/accounts/domain/financial_account.dart';
import 'package:pesoflow/features/accounts/presentation/manual_account_editor.dart';

Future<void> showAccountCatalog(BuildContext context) =>
    showManualAccountEditor(context);
Future<bool> confirmAccountRemoval(
  BuildContext context,
  FinancialAccount account,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(account.archived ? 'Restore account?' : 'Remove account?'),
        content: Text(
          account.archived ? 'Restore this account for manual entry?' : 'Accounts with transactions will be archived to preserve history. An empty account will be deleted. This does not close any bank or wallet account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ??
    false;
