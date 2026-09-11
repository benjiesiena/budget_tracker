import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../../shared/domain/entities/account.dart";
import "../../../shared/domain/entities/enums.dart";
import "../../../shared/presentation/providers/app_providers.dart";

/// Accounts, seeded with a single default "Cash" account on first run so
/// the onboarding flow (PRD 9.2) always has somewhere to post transactions.
final accountsProvider = FutureProvider<List<Account>>((ref) async {
  final repo = ref.watch(accountRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  var accounts = await repo.getAllForUser(userId);
  if (accounts.isEmpty) {
    final now = DateTime.now();
    await repo.create(Account(
      userId: userId,
      name: "Cash",
      type: AccountType.cash,
      currencyCode: "PHP",
      createdAt: now,
      updatedAt: now,
    ));
    accounts = await repo.getAllForUser(userId);
  }
  return accounts;
});
