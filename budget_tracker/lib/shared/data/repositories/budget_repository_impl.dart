import "../../domain/entities/budget.dart";
import "../../domain/entities/enums.dart";
import "../../domain/repositories/budget_repository.dart";
import "../database/database_helper.dart";

class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl(this._dbHelper);
  final DatabaseHelper _dbHelper;
  static const _budgetsTable = "budgets";
  static const _itemsTable = "budget_items";

  @override
  Future<Budget> create(Budget budget, List<BudgetItem> items) async {
    final db = await _dbHelper.database;
    late int budgetId;
    await db.transaction((txn) async {
      budgetId = await txn.insert(_budgetsTable, _budgetToMap(budget));
      for (final item in items) {
        await txn.insert(_itemsTable, _itemToMap(item, budgetId));
      }
    });
    return budget.copyWith(id: budgetId);
  }

  @override
  Future<Budget> update(Budget budget) async {
    final db = await _dbHelper.database;
    await db.update(_budgetsTable, _budgetToMap(budget), where: "id = ?", whereArgs: [budget.id]);
    return budget;
  }

  @override
  Future<void> delete(int id) async {
    final db = await _dbHelper.database;
    await db.update(_budgetsTable, {"is_active": 0}, where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<Budget?> getActiveForDate(int userId, DateTime date) async {
    final db = await _dbHelper.database;
    final ms = date.millisecondsSinceEpoch;
    final rows = await db.query(
      _budgetsTable,
      where: "user_id = ? AND is_active = 1 AND period_start <= ? AND period_end >= ?",
      whereArgs: [userId, ms, ms],
      orderBy: "period_start DESC",
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _budgetFromMap(rows.first);
  }

  @override
  Future<List<Budget>> getAllForUser(int userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(_budgetsTable, where: "user_id = ?", whereArgs: [userId], orderBy: "period_start DESC");
    return rows.map(_budgetFromMap).toList();
  }

  @override
  Future<List<BudgetItem>> getItemsForBudget(int budgetId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(_itemsTable, where: "budget_id = ?", whereArgs: [budgetId]);
    return rows.map(_itemFromMap).toList();
  }

  @override
  Future<BudgetItem> upsertItem(BudgetItem item) async {
    final db = await _dbHelper.database;
    if (item.id == null) {
      final id = await db.insert(_itemsTable, _itemToMap(item, item.budgetId));
      return item.copyWith(id: id);
    } else {
      await db.update(_itemsTable, _itemToMap(item, item.budgetId), where: "id = ?", whereArgs: [item.id]);
      return item;
    }
  }

  Map<String, Object?> _budgetToMap(Budget b) => {
        if (b.id != null) "id": b.id,
        "user_id": b.userId,
        "name": b.name,
        "type": b.type.name,
        "period_start": b.periodStart.millisecondsSinceEpoch,
        "period_end": b.periodEnd.millisecondsSinceEpoch,
        "total_budget": b.totalBudget,
        "strategy": b.strategy.name,
        "is_active": b.isActive ? 1 : 0,
        "created_at": b.createdAt.millisecondsSinceEpoch,
        "updated_at": b.updatedAt.millisecondsSinceEpoch,
      };

  Budget _budgetFromMap(Map<String, Object?> row) => Budget(
        id: row["id"] as int?,
        userId: row["user_id"] as int,
        name: row["name"] as String,
        type: BudgetType.values.byName(row["type"] as String),
        periodStart: DateTime.fromMillisecondsSinceEpoch(row["period_start"] as int),
        periodEnd: DateTime.fromMillisecondsSinceEpoch(row["period_end"] as int),
        totalBudget: (row["total_budget"] as num).toDouble(),
        strategy: BudgetStrategy.values.byName(row["strategy"] as String),
        isActive: (row["is_active"] as int) == 1,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row["created_at"] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(row["updated_at"] as int),
      );

  Map<String, Object?> _itemToMap(BudgetItem item, int budgetId) => {
        if (item.id != null) "id": item.id,
        "budget_id": budgetId,
        "category_id": item.categoryId,
        "amount": item.amount,
        "percentage": item.percentage,
        "created_at": item.createdAt.millisecondsSinceEpoch,
        "updated_at": item.updatedAt.millisecondsSinceEpoch,
      };

  BudgetItem _itemFromMap(Map<String, Object?> row) => BudgetItem(
        id: row["id"] as int?,
        budgetId: row["budget_id"] as int,
        categoryId: row["category_id"] as int,
        amount: (row["amount"] as num).toDouble(),
        percentage: (row["percentage"] as num?)?.toDouble(),
        createdAt: DateTime.fromMillisecondsSinceEpoch(row["created_at"] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(row["updated_at"] as int),
      );
}
