import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../../shared/domain/entities/category.dart";
import "../../../shared/presentation/providers/app_providers.dart";

/// Categories rarely change after onboarding, so this is a plain
/// FutureProvider rather than a full notifier — screens that need to
/// mutate categories (settings -> manage categories) can invalidate it.
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  var categories = await repo.getAllForUser(userId);
  if (categories.isEmpty) {
    await repo.seedDefaults(userId);
    categories = await repo.getAllForUser(userId);
  }
  return categories;
});
