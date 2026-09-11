import "../entities/transaction.dart";

/// Contract for transaction persistence. The domain layer depends only on
/// this interface, never on sqflite directly, so use cases and AI tools stay
/// testable with an in-memory fake.
abstract class TransactionRepository {
  Future<Transaction> create(Transaction transaction);
  Future<Transaction> update(Transaction transaction);
  Future<void> delete(int id);
  Future<Transaction?> getById(int id);

  /// Loads all transactions for a user. Callers filter/aggregate via
  /// [FinancialCalculator] rather than pushing ad-hoc queries down here,
  /// so the calculation logic stays in one deterministic, testable place.
  Future<List<Transaction>> getAllForUser(int userId);

  Future<List<Transaction>> search(int userId, String query);
}
