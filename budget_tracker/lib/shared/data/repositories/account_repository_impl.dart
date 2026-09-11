import "../../domain/entities/account.dart";
import "../../domain/entities/enums.dart";
import "../../domain/repositories/account_repository.dart";
import "../database/database_helper.dart";

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl(this._dbHelper);
  final DatabaseHelper _dbHelper;
  static const _table = "accounts";

  @override
  Future<Account> create(Account account) async {
    final db = await _dbHelper.database;
    final id = await db.insert(_table, _toMap(account));
    return account.copyWith(id: id);
  }

  @override
  Future<Account> update(Account account) async {
    final db = await _dbHelper.database;
    await db.update(_table, _toMap(account), where: "id = ?", whereArgs: [account.id]);
    return account;
  }

  @override
  Future<void> delete(int id) async {
    final db = await _dbHelper.database;
    // Soft-delete: accounts are referenced by transactions with ON DELETE
    // RESTRICT, so hard-deleting an account with history would fail (by
    // design — see PRD schema). Deactivate instead.
    await db.update(_table, {"is_active": 0}, where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<Account?> getById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query(_table, where: "id = ?", whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  @override
  Future<List<Account>> getAllForUser(int userId, {bool activeOnly = true}) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      _table,
      where: activeOnly ? "user_id = ? AND is_active = 1" : "user_id = ?",
      whereArgs: [userId],
      orderBy: "name ASC",
    );
    return rows.map(_fromMap).toList();
  }

  Map<String, Object?> _toMap(Account a) => {
        if (a.id != null) "id": a.id,
        "user_id": a.userId,
        "name": a.name,
        "type": a.type.dbValue,
        "balance": a.balance,
        "currency_code": a.currencyCode,
        "is_active": a.isActive ? 1 : 0,
        "icon": a.icon,
        "color": a.color,
        "created_at": a.createdAt.millisecondsSinceEpoch,
        "updated_at": a.updatedAt.millisecondsSinceEpoch,
      };

  Account _fromMap(Map<String, Object?> row) => Account(
        id: row["id"] as int?,
        userId: row["user_id"] as int,
        name: row["name"] as String,
        type: AccountTypeX.fromDb(row["type"] as String),
        balance: (row["balance"] as num).toDouble(),
        currencyCode: row["currency_code"] as String,
        isActive: (row["is_active"] as int) == 1,
        icon: row["icon"] as String?,
        color: row["color"] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row["created_at"] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(row["updated_at"] as int),
      );
}
