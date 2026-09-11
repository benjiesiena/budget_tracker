import "../../domain/entities/category.dart";
import "../../domain/entities/enums.dart";
import "../../domain/repositories/category_repository.dart";
import "../database/database_helper.dart";

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._dbHelper);
  final DatabaseHelper _dbHelper;
  static const _table = "categories";

  @override
  Future<Category> create(Category category) async {
    final db = await _dbHelper.database;
    final id = await db.insert(_table, _toMap(category));
    return category.copyWith(id: id);
  }

  @override
  Future<Category> update(Category category) async {
    final db = await _dbHelper.database;
    await db.update(_table, _toMap(category), where: "id = ?", whereArgs: [category.id]);
    return category;
  }

  @override
  Future<void> delete(int id) async {
    final db = await _dbHelper.database;
    await db.update(_table, {"is_active": 0}, where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<Category?> getById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query(_table, where: "id = ?", whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  @override
  Future<List<Category>> getAllForUser(int userId, {bool activeOnly = true}) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      _table,
      where: activeOnly ? "user_id = ? AND is_active = 1" : "user_id = ?",
      whereArgs: [userId],
      orderBy: "sort_order ASC, name ASC",
    );
    return rows.map(_fromMap).toList();
  }

  @override
  Future<void> seedDefaults(int userId) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final batch = db.batch();
    for (final entry in Category.defaults()) {
      batch.insert(_table, {
        "user_id": userId,
        "name": entry["name"],
        "type": entry["type"],
        "icon": entry["icon"],
        "color": entry["color"],
        "is_default": 1,
        "is_active": 1,
        "sort_order": 0,
        "created_at": now,
        "updated_at": now,
      });
    }
    await batch.commit(noResult: true);
  }

  Map<String, Object?> _toMap(Category c) => {
        if (c.id != null) "id": c.id,
        "user_id": c.userId,
        "name": c.name,
        "type": c.type.dbValue,
        "icon": c.icon,
        "color": c.color,
        "is_default": c.isDefault ? 1 : 0,
        "is_active": c.isActive ? 1 : 0,
        "parent_id": c.parentId,
        "sort_order": c.sortOrder,
        "created_at": c.createdAt.millisecondsSinceEpoch,
        "updated_at": c.updatedAt.millisecondsSinceEpoch,
      };

  Category _fromMap(Map<String, Object?> row) => Category(
        id: row["id"] as int?,
        userId: row["user_id"] as int,
        name: row["name"] as String,
        type: CategoryTypeX.fromDb(row["type"] as String),
        icon: row["icon"] as String?,
        color: row["color"] as String?,
        isDefault: (row["is_default"] as int) == 1,
        isActive: (row["is_active"] as int) == 1,
        parentId: row["parent_id"] as int?,
        sortOrder: row["sort_order"] as int,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row["created_at"] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(row["updated_at"] as int),
      );
}
