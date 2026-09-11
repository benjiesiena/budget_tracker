import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'shared/data/database/database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Opens (and, on first launch, creates + migrates) the encrypted local
  // database before any widget tries to read from it. This is also where
  // a splash-screen-driven bootstrap (PRD 9.1) would seed the `users` row
  // from onboarding answers and load the on-device AI model.
  //
  // Startup failures here happen *before* runApp() — with no widget tree
  // yet, an uncaught exception at this point just leaves the OS's blank
  // launch screen on forever, with no error visible anywhere on-device.
  // Catching it and rendering the error directly turns that into an
  // actionable message instead of a silent black screen.
  try {
    await DatabaseHelper.instance.database;
    await _ensureSeedUser();
  } catch (error, stackTrace) {
    debugPrint('Startup failed: $error\n$stackTrace');
    runApp(_StartupErrorApp(error: error, stackTrace: stackTrace));
    return;
  }

  runApp(const ProviderScope(child: BudgetTrackerApp()));
}

/// Creates user #1 if this is a fresh install. A real onboarding flow (PRD
/// 9.2) would collect currency/income/budgeting-style answers first and
/// pass them in here; this scaffold seeds sensible PHP/en_PH defaults so
/// the rest of the app has something to read immediately.
Future<void> _ensureSeedUser() async {
  final db = await DatabaseHelper.instance.database;
  final existing = await db.query('users', where: 'id = ?', whereArgs: [1], limit: 1);
  if (existing.isNotEmpty) return;

  final now = DateTime.now().millisecondsSinceEpoch;
  await db.insert('users', {
    'id': 1,
    'name': 'You',
    'currency_code': 'PHP',
    'locale': 'en_PH',
    'timezone': 'Asia/Manila',
    'created_at': now,
    'updated_at': now,
    'is_active': 1,
  });
  await db.insert('app_settings', {
    'user_id': 1,
    'created_at': now,
    'updated_at': now,
  });
}

/// Minimal fallback UI so a failed startup is visible and copyable on the
/// device itself, not just buried in `flutter run`'s terminal output.
class _StartupErrorApp extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;

  const _StartupErrorApp({required this.error, required this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('Startup failed'), backgroundColor: Colors.red.shade50),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectableText(
            '$error\n\n$stackTrace',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ),
    );
  }
}
