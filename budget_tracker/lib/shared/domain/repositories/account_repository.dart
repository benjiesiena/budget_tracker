import "../entities/account.dart";

abstract class AccountRepository {
  Future<Account> create(Account account);
  Future<Account> update(Account account);
  Future<void> delete(int id);
  Future<Account?> getById(int id);
  Future<List<Account>> getAllForUser(int userId, {bool activeOnly = true});
}
