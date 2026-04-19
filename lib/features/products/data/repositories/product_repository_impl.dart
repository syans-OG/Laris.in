import '../../../../core/database/app_database.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final AppDatabase _db;

  ProductRepositoryImpl(this._db);

  @override
  Future<List<ProductEntity>> getProducts({int? categoryId, String? searchQuery}) async {
    final db = await _db.database;
    
    String query = 'SELECT * FROM products WHERE is_active = 1';
    List<Object?> args = [];

    if (categoryId != null) {
      query += ' AND category_id = ?';
      args.add(categoryId);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query += ' AND (name LIKE ? OR barcode LIKE ?)';
      final likePattern = '%\$searchQuery%';
      args.addAll([likePattern, likePattern]);
    }

    query += ' ORDER BY name ASC';
    
    final result = db.select(query, args);
    return result.map((row) => ProductEntity.fromJson(row)).toList();
  }

  @override
  Future<ProductEntity?> getProductByBarcode(String barcode) async {
    final db = await _db.database;
    final result = db.select('SELECT * FROM products WHERE barcode = ? AND is_active = 1 LIMIT 1', [barcode]);
    if (result.isEmpty) return null;
    return ProductEntity.fromJson(result.first);
  }

  @override
  Future<void> saveProduct(ProductEntity product) async {
    final db = await _db.database;
    if (product.id > 0) {
      db.execute(
        '''
        UPDATE products 
        SET barcode = ?, name = ?, price = ?, cost_price = ?, stock = ?, category_id = ?, image_url = ?, is_active = ?
        WHERE id = ?
        ''',
        [
          product.barcode, product.name, product.price, product.costPrice, 
          product.stock, product.categoryId, product.imageUrl, product.isActive ? 1 : 0, 
          product.id
        ],
      );
    } else {
      db.execute(
        '''
        INSERT INTO products (barcode, name, price, cost_price, stock, category_id, image_url, is_active)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          product.barcode, product.name, product.price, product.costPrice, 
          product.stock, product.categoryId, product.imageUrl, product.isActive ? 1 : 0
        ],
      );
    }
  }

  @override
  Future<int> saveProductsBatch(List<ProductEntity> products) async {
    if (products.isEmpty) return 0;
    
    final db = await _db.database;
    int successCount = 0;
    
    try {
      db.execute('BEGIN TRANSACTION');
      for (final product in products) {
        if (product.id > 0) {
          db.execute(
            '''
            UPDATE products 
            SET barcode = ?, name = ?, price = ?, cost_price = ?, stock = ?, category_id = ?, image_url = ?, is_active = ?
            WHERE id = ?
            ''',
            [
              product.barcode, product.name, product.price, product.costPrice, 
              product.stock, product.categoryId, product.imageUrl, product.isActive ? 1 : 0, 
              product.id
            ],
          );
        } else {
          db.execute(
            '''
            INSERT INTO products (barcode, name, price, cost_price, stock, category_id, image_url, is_active)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ''',
            [
              product.barcode, product.name, product.price, product.costPrice, 
              product.stock, product.categoryId, product.imageUrl, product.isActive ? 1 : 0
            ],
          );
        }
        successCount++;
      }
      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
    
    return successCount;
  }

  @override
  Future<void> updateStock(int productId, int newStock) async {
    final db = await _db.database;
    db.execute('UPDATE products SET stock = ? WHERE id = ?', [newStock, productId]);
  }

  @override
  Future<void> deleteProduct(int id) async {
    final db = await _db.database;
    // Soft delete per PRD logic
    db.execute('UPDATE products SET is_active = 0 WHERE id = ?', [id]);
  }
}
