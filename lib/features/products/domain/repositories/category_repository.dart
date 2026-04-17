import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getCategories();
  Future<void> saveCategory(CategoryEntity category);
  Future<void> deleteCategory(int id);
}
