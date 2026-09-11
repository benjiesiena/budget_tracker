import "../entities/category.dart";

abstract class CategoryRepository {
  Future<Category> create(Category category);
  Future<Category> update(Category category);
  Future<void> delete(int id);
  Future<Category?> getById(int id);
  Future<List<Category>> getAllForUser(int userId, {bool activeOnly = true});
  Future<void> seedDefaults(int userId);
}
