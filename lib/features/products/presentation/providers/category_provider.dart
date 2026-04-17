import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/category_entity.dart';

final categoriesProvider = StateNotifierProvider<CategoryNotifier, AsyncValue<List<CategoryEntity>>>((ref) {
  return CategoryNotifier(ref);
});

class CategoryNotifier extends StateNotifier<AsyncValue<List<CategoryEntity>>> {
  final Ref _ref;

  CategoryNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(categoryRepositoryProvider);
      final categories = await repository.getCategories();
      state = AsyncValue.data(categories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveCategory(CategoryEntity category) async {
    try {
      final repository = _ref.read(categoryRepositoryProvider);
      await repository.saveCategory(category);
      await loadCategories();
    } catch (e) {
      // Logic for error handling might bubble up or show snackbar
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      final repository = _ref.read(categoryRepositoryProvider);
      await repository.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      rethrow;
    }
  }
}
