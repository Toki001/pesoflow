import 'package:flutter/material.dart';

import 'app/demo_bootstrap.dart';
import 'core/storage/demo_database.dart';
import 'core/storage/sqlite_demo_workspace_repository.dart';

import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en_PH');
  runApp(
    DemoBootstrap(repository: SqliteDemoWorkspaceRepository(DemoDatabase())),
  );
}
