import '../../domain/entities/stock_log_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/product_entity.dart';

final productsQueryProvider = StateProvider<String>((ref) => '');
final productsCategoryFilterProvider = StateProvider<int?>((ref) => null);
final productsSortByProvider = StateProvider<String?>((ref) => null);
final productsStockFilterProvider = StateProvider<String?>((ref) => null);

final productsProvider = StateNotifierProvider<ProductNotifier, AsyncValue<List<ProductEntity>>>((ref) {
  return ProductNotifier(ref);
});

class ProductNotifier extends StateNotifier<AsyncValue<List<ProductEntity>>> {
  final Ref _ref;

  ProductNotifier(this._ref) : super(const AsyncValue.loading()) {
    _ref.listen(productsCategoryFilterProvider, (_, __) => _reload());
    _ref.listen(productsQueryProvider, (_, __) => _reload());
    _ref.listen(productsSortByProvider, (_, __) => _reload());
    _ref.listen(productsStockFilterProvider, (_, __) => _reload());
    loadProducts();
  }

  void _reload() {
    loadProducts(
      searchQuery: _ref.read(productsQueryProvider),
      categoryId: _ref.read(productsCategoryFilterProvider),
      sortBy: _ref.read(productsSortByProvider),
      stockFilter: _ref.read(productsStockFilterProvider),
    );
  }

  Future<void> loadProducts({String? searchQuery, int? categoryId, String? sortBy, String? stockFilter}) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(productRepositoryProvider);
      final products = await repository.getProducts(
        categoryId: categoryId,
        searchQuery: searchQuery,
        sortBy: sortBy,
        stockFilter: stockFilter,
      );
      state = AsyncValue.data(products);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<ProductEntity?> getProductByBarcode(String barcode) async {
    try {
      final repository = _ref.read(productRepositoryProvider);
      return await repository.getProductByBarcode(barcode);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveProduct(ProductEntity product) async {
    try {
      final repository = _ref.read(productRepositoryProvider);
      await repository.saveProduct(product);
      await loadProducts(
        searchQuery: _ref.read(productsQueryProvider),
        categoryId: _ref.read(productsCategoryFilterProvider),
        sortBy: _ref.read(productsSortByProvider),
        stockFilter: _ref.read(productsStockFilterProvider),
      );
      // Also refresh logs if any
      _ref.invalidate(stockLogsProvider);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStock(int productId, int qtyChange, {String type = 'penyesuaian', String? note}) async {
    try {
      final repository = _ref.read(productRepositoryProvider);
      await repository.updateStock(productId, qtyChange, type: type, note: note);
      await loadProducts(
        searchQuery: _ref.read(productsQueryProvider),
        categoryId: _ref.read(productsCategoryFilterProvider),
        sortBy: _ref.read(productsSortByProvider),
        stockFilter: _ref.read(productsStockFilterProvider),
      );
      _ref.invalidate(stockLogsProvider);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final repository = _ref.read(productRepositoryProvider);
      await repository.deleteProduct(id);
      await loadProducts(
        searchQuery: _ref.read(productsQueryProvider),
        categoryId: _ref.read(productsCategoryFilterProvider),
        sortBy: _ref.read(productsSortByProvider),
        stockFilter: _ref.read(productsStockFilterProvider),
      );
    } catch (e) {
      rethrow;
    }
  }
}

final lowStockProductsProvider = Provider<AsyncValue<List<ProductEntity>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  return productsAsync.whenData((products) {
    return products.where((p) => p.stock <= p.lowStockThreshold).toList();
  });
});

final stockLogsProvider = FutureProvider<List<StockLogEntity>>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  return await repository.getStockLogs();
});

