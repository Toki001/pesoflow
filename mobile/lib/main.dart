import 'package:pesoflow/core/storage/financial_cipher.dart';
import 'package:flutter/material.dart';

import 'package:pesoflow/app/finance_bootstrap.dart';
import 'package:pesoflow/core/storage/finance_database.dart';
import 'package:pesoflow/features/workspace/data/sqlite_finance_repository.dart';

import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en_PH');
  runApp(
    FinanceBootstrap(
      repository: SqliteFinanceRepository(
        FinanceDatabase(),
        FinancialCipher(SecureEncryptionKeyStore()),
      ),
    ),
  );
}
