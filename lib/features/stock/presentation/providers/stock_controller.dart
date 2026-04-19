import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/stock_history.dart';

final stockControllerProvider =
    ChangeNotifierProvider<StockController>((ref) {
  return StockController(ref);
});

class StockController extends ChangeNotifier {
  final Ref _ref;

  StockController(this._ref) {
    loadProducts();
  }

  List<ProductEntity> _products = [];
  List<StockHistory> _history = [];
  bool isLoading = false;
  String? error;

  List<ProductEntity> get allProducts => List.unmodifiable(_products);
  List<ProductEntity> get lowStockProducts =>
      _products.where((p) => p.stock <= 5).toList();
  List<StockHistory> get history =>
      List.unmodifiable(_history.reversed.toList());

  Future<void> loadProducts() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final repo = _ref.read(productRepositoryProvider);
      _products = await repo.getProducts();
    } catch (e) {
      error = 'Gagal memuat produk: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> adjustStock({
    required int productId,
    required int amount,
    required String reason,
    required bool isAddition,
  }) async {
    final idx = _products.indexWhere((p) => p.id == productId);
    if (idx < 0) return;

    final product = _products[idx];
    final change = isAddition ? amount : -amount;
    final newStock = (product.stock + change).clamp(0, 999999);

    try {
      await _ref.read(productRepositoryProvider).updateStock(productId, newStock);

      _products[idx] = product.copyWith(stock: newStock);
      _history.add(StockHistory(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        productId: productId,
        productName: product.name,
        change: change,
        stockAfter: newStock,
        reason: reason,
        createdAt: DateTime.now(),
      ));
      notifyListeners();
    } catch (e) {
      error = 'Gagal menyesuaikan stok: $e';
      notifyListeners();
    }
  }
}
