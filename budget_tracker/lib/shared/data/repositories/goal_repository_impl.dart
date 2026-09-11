import "../../domain/entities/financial_goal.dart";
import "../../domain/repositories/goal_repository.dart";
import "../database/database_helper.dart";

class GoalRepositoryImpl implements GoalRepository {
  GoalRepositoryImpl(this._dbHelper);
  final DatabaseHelper _dbHelper;
  static const _table = "financial_goals";

  @override
  Future<FinancialGoal> create(FinancialGoal goal) async {
    final db = await _dbHelper.database;
    final id = await db.insert(_table, _toMap(goal));
    return goal.copyWith(id: id);
  }

  @override
  Future<FinancialGoal> update(FinancialGoal goal) async {
    final db = await _dbHelper.database;
    await db.update(_table, _toMap(goal), where: "id = ?", whereArgs: [goal.id]);
    return goal;
  }

  @override
  Future<void> delete(int id) async {
    final db = await _dbHelper.database;
    await db.update(_table, {"is_active": 0}, where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<FinancialGoal?> getById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query(_table, where: "id = ?", whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  @override
  Future<List<FinancialGoal>> getAllForUser(int userId, {bool activeOnly = true}) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      _table,
      where: activeOnly ? "user_id = ? AND is_active = 1" : "user_id = ?",
      whereArgs: [userId],
      orderBy: "target_date ASC",
    );
    return rows.map(_fromMap).toList();
  }

  Map<String, Object?> _toMap(FinancialGoal g) => {
        if (g.id != null) "id": g.id,
        "user_id": g.userId,
        "name": g.name,
        "target_amount": g.targetAmount,
        "current_amount": g.currentAmount,
        "target_date": g.targetDate?.millisecondsSinceEpoch,
        "category_id": g.categoryId,
        "icon": g.icon,
        "color": g.color,
        "is_active": g.isActive ? 1 : 0,
        "created_at": g.createdAt.millisecondsSinceEpoch,
        "updated_at": g.updatedAt.millisecondsSinceEpoch,
      };

  FinancialGoal _fromMap(Map<String, Object?> row) => FinancialGoal(
        id: row["id"] as int?,
        userId: row["user_id"] as int,
        name: row["name"] as String,
        targetAmount: (row["target_amount"] as num).toDouble(),
        currentAmount: (row["current_amount"] as num).toDouble(),
        targetDate: row["target_date"] != null ? DateTime.fromMillisecondsSinceEpoch(row["target_date"] as int) : null,
        categoryId: row["category_id"] as int?,
        icon: row["icon"] as String?,
        color: row["color"] as String?,
        isActive: (row["is_active"] as int) == 1,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row["created_at"] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(row["updated_at"] as int),
      );
}
