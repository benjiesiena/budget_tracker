import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../infrastructure/security/key_management/security_manager.dart';

/// Opens and migrates the single on-device SQLite database.
///
/// The database is encrypted at rest via SQLCipher (see PRD 11.1). The
/// passphrase is generated once per install and stored in the platform
/// keychain/keystore through [SecurityManager] — it is never hardcoded and
/// never leaves the device.
///
/// Migrations are plain numbered SQL files under `migrations/`, applied in
/// order inside a single transaction so a partially-applied migration can
/// never leave the schema in a broken state.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String _dbName = 'budget_tracker.db';

  /// Bump this and add a new `V{n}__description.sql` file under
  /// `migrations/` whenever the schema changes. Never edit an already
  /// released migration file — add a new one instead.
  static const int _schemaVersion = 2;

  final SecurityManager _securityManager = SecurityManager();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, _dbName);
    final passphrase = await _securityManager.getOrCreateDatabaseKey();

    return openDatabase(
      dbPath,
      password: passphrase,
      version: _schemaVersion,
      onConfigure: (db) async {
        // Foreign keys are off by default in SQLite; every FK constraint
        // in the schema (ON DELETE CASCADE/RESTRICT/SET NULL) depends on
        // this being enabled.
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        for (int v = 1; v <= version; v++) {
          await _applyMigration(db, v);
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        for (int v = oldVersion + 1; v <= newVersion; v++) {
          await _applyMigration(db, v);
        }
      },
    );
  }

  Future<void> _applyMigration(Database db, int version) async {
    final fileName = _migrationFileFor(version);
    final sql = await rootBundle.loadString('lib/shared/data/database/migrations/$fileName');
    // Strip full-line comments first, then split on ';'. Splitting first and
    // checking whether each resulting chunk *starts with* '--' doesn't work:
    // a comment sitting right before a statement (no blank statement between
    // them) glues onto that statement in the same chunk, so the whole
    // chunk starts with '--' and the statement itself was being silently
    // dropped — which is exactly how `CREATE TABLE users` went missing.
    final withoutComments = sql
        .split('\n')
        .where((line) => !line.trim().startsWith('--'))
        .join('\n');

    final statements = withoutComments
        .split(';')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty);

    await db.transaction((txn) async {
      for (final statement in statements) {
        await txn.execute(statement);
      }
    });
  }

  String _migrationFileFor(int version) {
    switch (version) {
      case 1:
        return 'V1__initial_schema.sql';
      case 2:
        return 'V2__add_indexes.sql';
      default:
        throw StateError('No migration file registered for schema version $version');
    }
  }

  /// Used by tests and "Clear All Data" in settings. Never called on the
  /// happy path.
  Future<void> closeAndDelete() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
