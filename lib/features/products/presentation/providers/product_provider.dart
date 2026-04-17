import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/product_entity.dart';

final productsQueryProvider = StateProvider<String>((ref) => '');
final productsCategoryFilterProvider = StateProvider<int?>((ref) => null);

final productsProvider = StateNotifierProvider<ProductNotifier, AsyncValue<List<ProductEntity>>>((ref) {
  return ProductNotifier(ref);
});

class ProductNotifier extends StateNotifier<AsyncValue<List<ProductEntity>>> {
  final Ref _ref;

  ProductNotifier(this._ref) : super(const AsyncValue.loading()) {
    // Listen to query or category filter changes to auto-reload
    _ref.listen(productsCategoryFilterProvider, (previous, next) {
      loadProducts(searchQuery: _ref.read(productsQueryProvider), categoryId: next);
    });

    loadProducts();
  }

  Future<void> loadProducts({String? searchQuery, int? categoryId}) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(productRepositoryProvider);
      final products = await repository.getProducts(categoryId: categoryId, searchQuery: searchQuery);
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
      );
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
      );
    } catch (e) {
      rethrow;
    }
  }
}
