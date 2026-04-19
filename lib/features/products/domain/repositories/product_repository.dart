import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts({int? categoryId, String? searchQuery});
  Future<ProductEntity?> getProductByBarcode(String barcode);
  Future<void> saveProduct(ProductEntity product);
  Future<int> saveProductsBatch(List<ProductEntity> products);
  Future<void> deleteProduct(int id);
  Future<void> updateStock(int productId, int newStock);
}
