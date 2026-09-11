import "../../domain/entities/recurring_transaction.dart";
import "../../domain/entities/enums.dart";
import "../../domain/repositories/recurring_transaction_repository.dart";
import "../database/database_helper.dart";

class RecurringTransactionRepositoryImpl implements RecurringTransactionRepository {
  RecurringTransactionRepositoryImpl(this._dbHelper);
  final DatabaseHelper _dbHelper;
  static const _table = "recurring_transactions";

  @override
  Future<RecurringTransaction> create(RecurringTransaction recurring) async {
    final db = await _dbHelper.database;
    final id = await db.insert(_table, _toMap(recurring));
    return recurring.copyWith(id: id);
  }

  @override
  Future<RecurringTransaction> update(RecurringTransaction recurring) async {
    final db = await _dbHelper.database;
    await db.update(_table, _toMap(recurring), where: "id = ?", whereArgs: [recurring.id]);
    return recurring;
  }

  @override
  Future<void> delete(int id) async {
    final db = await _dbHelper.database;
    await db.update(_table, {"is_active": 0}, where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<List<RecurringTransaction>> getAllForUser(int userId, {bool activeOnly = true}) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      _table,
      where: activeOnly ? "user_id = ? AND is_active = 1" : "user_id = ?",
      whereArgs: [userId],
      orderBy: "next_due_date ASC",
    );
    return rows.map(_fromMap).toList();
  }

  Map<String, Object?> _toMap(RecurringTransaction r) => {
        if (r.id != null) "id": r.id,
        "user_id": r.userId,
        "account_id": r.accountId,
        "category_id": r.categoryId,
        "type": r.type.dbValue,
        "amount": r.amount,
        "description": r.description,
        "frequency": r.frequency.dbValue,
        "interval": r.interval,
        "start_date": r.startDate.millisecondsSinceEpoch,
        "end_date": r.endDate?.millisecondsSinceEpoch,
        "last_processed_date": r.lastProcessedDate?.millisecondsSinceEpoch,
        "next_due_date": r.nextDueDate?.millisecondsSinceEpoch,
        "is_active": r.isActive ? 1 : 0,
        "created_at": r.createdAt.millisecondsSinceEpoch,
        "updated_at": r.updatedAt.millisecondsSinceEpoch,
      };

  RecurringTransaction _fromMap(Map<String, Object?> row) => RecurringTransaction(
        id: row["id"] as int?,
        userId: row["user_id"] as int,
        accountId: row["account_id"] as int,
        categoryId: row["category_id"] as int,
        type: TransactionTypeX.fromDb(row["type"] as String),
        amount: (row["amount"] as num).toDouble(),
        description: row["description"] as String,
        frequency: RecurringFrequencyX.fromDb(row["frequency"] as String),
        interval: row["interval"] as int,
        startDate: DateTime.fromMillisecondsSinceEpoch(row["start_date"] as int),
        endDate: row["end_date"] != null ? DateTime.fromMillisecondsSinceEpoch(row["end_date"] as int) : null,
        lastProcessedDate:
            row["last_processed_date"] != null ? DateTime.fromMillisecondsSinceEpoch(row["last_processed_date"] as int) : null,
        nextDueDate: row["next_due_date"] != null ? DateTime.fromMillisecondsSinceEpoch(row["next_due_date"] as int) : null,
        isActive: (row["is_active"] as int) == 1,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row["created_at"] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(row["updated_at"] as int),
      );
}
