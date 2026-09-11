import "../entities/recurring_transaction.dart";

abstract class RecurringTransactionRepository {
  Future<RecurringTransaction> create(RecurringTransaction recurring);
  Future<RecurringTransaction> update(RecurringTransaction recurring);
  Future<void> delete(int id);
  Future<List<RecurringTransaction>> getAllForUser(int userId, {bool activeOnly = true});
}
