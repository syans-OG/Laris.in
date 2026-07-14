import '../../domain/entities/stock_log_entity.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final AppDatabase _db;

  ProductRepositoryImpl(this._db);

  @override
  Future<List<ProductEntity>> getProducts({int? categoryId, String? searchQuery, String? sortBy, String? stockFilter}) async {
    final db = await _db.database;
    
    String query = 'SELECT * FROM products WHERE is_active = 1';
    List<Object?> args = [];

    if (categoryId != null) {
      query += ' AND category_id = ?';
      args.add(categoryId);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query += ' AND (name LIKE ? OR barcode LIKE ?)';
      final likePattern = '%$searchQuery%';
      args.addAll([likePattern, likePattern]);
    }

    if (stockFilter != null) {
      if (stockFilter == 'low') {
        query += ' AND stock <= low_stock_threshold';
      } else if (stockFilter == 'out') {
        query += ' AND stock = 0';
      } else if (stockFilter == 'available') {
        query += ' AND stock > 0';
      }
    }

    if (sortBy != null) {
      if (sortBy == 'name_asc') {
        query += ' ORDER BY name ASC';
      } else if (sortBy == 'name_desc') {
        query += ' ORDER BY name DESC';
      } else if (sortBy == 'price_asc') {
        query += ' ORDER BY price ASC';
      } else if (sortBy == 'price_desc') {
        query += ' ORDER BY price DESC';
      } else if (sortBy == 'stock_asc') {
        query += ' ORDER BY stock ASC';
      } else if (sortBy == 'stock_desc') {
        query += ' ORDER BY stock DESC';
      } else {
        query += ' ORDER BY name ASC';
      }
    } else {
      query += ' ORDER BY name ASC';
    }
    
    final result = db.select(query, args);
    return result.map((row) => ProductEntity.fromJson(row)).toList();
  }

  @override
  Future<ProductEntity?> getProductById(int id) async {
    final db = await _db.database;
    final result = db.select('SELECT * FROM products WHERE id = ? LIMIT 1', [id]);
    if (result.isEmpty) return null;
    return ProductEntity.fromJson(result.first);
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
    
    db.execute('BEGIN TRANSACTION');
    try {
      if (product.id > 0) {
        // 1. Get current stock for logging if changed
        final current = await getProductById(product.id);
        
        // 2. Update product
        db.execute(
          '''
          UPDATE products 
          SET barcode = ?, name = ?, price = ?, cost_price = ?, stock = ?, category_id = ?, image_url = ?, is_active = ?, low_stock_threshold = ?
          WHERE id = ?
          ''',
          [
            product.barcode, product.name, product.price, product.costPrice, 
            product.stock, product.categoryId, product.imageUrl, product.isActive ? 1 : 0, 
            product.lowStockThreshold, product.id
          ],
        );

        // 3. Log if stock changed
        if (current != null && current.stock != product.stock) {
          await logStockChange(StockLogEntity(
            id: 0,
            productId: product.id,
            type: 'penyesuaian',
            qtyChange: product.stock - current.stock,
            totalAfter: product.stock,
            createdAt: DateTime.now(),
          ));
        }
      } else {
        // New Product
        db.execute(
          '''
          INSERT INTO products (barcode, name, price, cost_price, stock, category_id, image_url, is_active, low_stock_threshold)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
          ''',
          [
            product.barcode, product.name, product.price, product.costPrice, 
            product.stock, product.categoryId, product.imageUrl, product.isActive ? 1 : 0,
            product.lowStockThreshold
          ],
        );
        
        final newId = db.select('SELECT last_insert_rowid() as id').first['id'] as int;
        if (product.stock != 0) {
          await logStockChange(StockLogEntity(
            id: 0,
            productId: newId,
            type: 'masuk',
            qtyChange: product.stock,
            totalAfter: product.stock,
            createdAt: DateTime.now(),
          ));
        }
      }
      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  @override
  Future<int> saveProductsBatch(List<ProductEntity> products) async {
    if (products.isEmpty) return 0;
    
    int successCount = 0;
    
    for (final product in products) {
      try {
        await saveProduct(product);
        successCount++;
      } catch (e) {
        // Biarkan lanjut ke produk berikutnya jika satu gagal
        print('Gagal save product batch: $e');
      }
    }
    
    return successCount;
  }

  @override
  Future<void> updateStock(int productId, int qtyChange, {String type = 'penyesuaian', String? note}) async {
    final db = await _db.database;
    
    db.execute('BEGIN TRANSACTION');
    try {
      // 1. Update relative stock
      db.execute('UPDATE products SET stock = stock + ? WHERE id = ?', [qtyChange, productId]);
      
      // 2. Get new total for logging
      final res = db.select('SELECT stock FROM products WHERE id = ?', [productId]);
      if (res.isEmpty) throw 'Produk tidak ditemukan';
      final newTotal = (res.first['stock'] as num).toInt();

      // 3. Log
      await logStockChange(StockLogEntity(
        id: 0,
        productId: productId,
        type: type,
        qtyChange: qtyChange,
        totalAfter: newTotal,
        note: note,
        createdAt: DateTime.now(),
      ));

      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    final db = await _db.database;
    db.execute('UPDATE products SET is_active = 0 WHERE id = ?', [id]);
  }

  @override
  Future<List<StockLogEntity>> getStockLogs({int? productId, int limit = 100}) async {
    final db = await _db.database;
    String query = '''
      SELECT sl.*, p.name as product_name
      FROM stock_logs sl
      JOIN products p ON sl.product_id = p.id
    ''';
    List<Object?> args = [];

    if (productId != null) {
      query += ' WHERE sl.product_id = ?';
      args.add(productId);
    }

    query += ' ORDER BY sl.created_at DESC LIMIT ?';
    args.add(limit);

    final result = db.select(query, args);
    return result.map((row) => StockLogEntity.fromJson(row)).toList();
  }

  @override
  Future<void> logStockChange(StockLogEntity log) async {
    final db = await _db.database;
    db.execute(
      '''
      INSERT INTO stock_logs (product_id, type, qty_change, total_after, note, created_at)
      VALUES (?, ?, ?, ?, ?, ?)
      ''',
      [log.productId, log.type, log.qtyChange, log.totalAfter, log.note, log.createdAt.toIso8601String()],
    );
  }
}
