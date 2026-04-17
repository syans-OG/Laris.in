import '../../../../core/database/app_database.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final AppDatabase _db;

  CategoryRepositoryImpl(this._db);

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final db = await _db.database;
    final result = db.select('SELECT * FROM categories ORDER BY sort_order ASC, name ASC');
    return result.map((row) => CategoryEntity.fromJson(row)).toList();
  }

  @override
  Future<void> saveCategory(CategoryEntity category) async {
    final db = await _db.database;
    if (category.id > 0) {
      db.execute(
        'UPDATE categories SET name = ?, color = ?, icon = ?, sort_order = ? WHERE id = ?',
        [category.name, category.color, category.icon, category.sortOrder, category.id],
      );
    } else {
      db.execute(
        'INSERT INTO categories (name, color, icon, sort_order) VALUES (?, ?, ?, ?)',
        [category.name, category.color, category.icon, category.sortOrder],
      );
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    final db = await _db.database;
    db.execute('DELETE FROM categories WHERE id = ?', [id]);
  }
}
