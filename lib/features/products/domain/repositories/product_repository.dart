import '../entities/product_entity.dart';
import '../entities/stock_log_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts({int? categoryId, String? searchQuery});
  Future<ProductEntity?> getProductById(int id);
  Future<ProductEntity?> getProductByBarcode(String barcode);
  Future<void> saveProduct(ProductEntity product);
  Future<int> saveProductsBatch(List<ProductEntity> products);
  Future<void> deleteProduct(int id);
  Future<void> updateStock(int productId, int newStock, {String type = 'penyesuaian', String? note});
  Future<List<StockLogEntity>> getStockLogs({int? productId, int limit = 100});
  Future<void> logStockChange(StockLogEntity log);
}
