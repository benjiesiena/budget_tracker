import 'dart:convert';
import 'package:sqflite_sqlcipher/sqflite.dart' hide Transaction;

import '../../domain/entities/transaction.dart';
import '../../domain/entities/enums.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../database/database_helper.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._dbHelper);

  final DatabaseHelper _dbHelper;
  static const _table = 'transactions';

  @override
  Future<Transaction> create(Transaction transaction) async {
    final db = await _dbHelper.database;
    final id = await db.insert(_table, _toMap(transaction));
    return transaction.copyWith(id: id);
  }

  @override
  Future<Transaction> update(Transaction transaction) async {
    final db = await _dbHelper.database;
    await db.update(_table, _toMap(transaction), where: 'id = ?', whereArgs: [transaction.id]);
    return transaction;
  }

  @override
  Future<void> delete(int id) async {
    final db = await _dbHelper.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<Transaction?> getById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query(_table, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  @override
  Future<List<Transaction>> getAllForUser(int userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(_table, where: 'user_id = ?', whereArgs: [userId], orderBy: 'date DESC');
    return rows.map(_fromMap).toList();
  }

  @override
  Future<List<Transaction>> search(int userId, String query) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      _table,
      where: 'user_id = ? AND (description LIKE ? OR notes LIKE ?)',
      whereArgs: [userId, '%$query%', '%$query%'],
      orderBy: 'date DESC',
    );
    return rows.map(_fromMap).toList();
  }

  Map<String, Object?> _toMap(Transaction t) {
    return {
      if (t.id != null) 'id': t.id,
      'user_id': t.userId,
      'account_id': t.accountId,
      'category_id': t.categoryId,
      'type': t.type.dbValue,
      'amount': t.amount,
      'description': t.description,
      'notes': t.notes,
      'date': t.date.millisecondsSinceEpoch,
      'tags': jsonEncode(t.tags),
      'is_recurring': t.isRecurring ? 1 : 0,
      'recurring_transaction_id': t.recurringTransactionId,
      'created_at': t.createdAt.millisecondsSinceEpoch,
      'updated_at': t.updatedAt.millisecondsSinceEpoch,
    };
  }

  Transaction _fromMap(Map<String, Object?> row) {
    return Transaction(
      id: row['id'] as int?,
      userId: row['user_id'] as int,
      accountId: row['account_id'] as int,
      categoryId: row['category_id'] as int,
      type: TransactionTypeX.fromDb(row['type'] as String),
      amount: (row['amount'] as num).toDouble(),
      description: row['description'] as String?,
      notes: row['notes'] as String?,
      date: DateTime.fromMillisecondsSinceEpoch(row['date'] as int),
      tags: row['tags'] != null ? List<String>.from(jsonDecode(row['tags'] as String)) : const [],
      isRecurring: (row['is_recurring'] as int) == 1,
      recurringTransactionId: row['recurring_transaction_id'] as int?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int),
    );
  }
}
