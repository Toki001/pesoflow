import 'package:flutter/material.dart';
import 'package:pesoflow/features/accounts/domain/account_view.dart';
import 'package:pesoflow/features/accounts/presentation/manual_account_editor.dart';

Future<void> showAccountCatalog(BuildContext context) =>
    showManualAccountEditor(context);
Future<bool> confirmAccountRemoval(
  BuildContext context,
  AccountView account,
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
Future<bool> showConnectionUnavailable(
  BuildContext context,
  AccountView account,
) async {
  await showDialog<void>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Connections are not configured'),
      content: const Text('Use a manual account to track your finances.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c),
          child: const Text('Close'),
        ),
      ],
    ),
  );
  return false;
}
