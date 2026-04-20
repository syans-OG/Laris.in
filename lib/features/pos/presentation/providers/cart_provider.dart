import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/products/domain/entities/product_entity.dart';
import '../models/cart_state.dart';
import '../../../settings/data/settings_repository.dart';

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final taxEnabled = ref.watch(taxEnabledProvider);
  final taxRate = ref.watch(taxRateProvider);
  return CartNotifier(taxEnabled: taxEnabled, taxRate: taxRate);
});

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier({required bool taxEnabled, required double taxRate})
      : super(CartState(taxRate: taxEnabled ? taxRate : 0.0));

  void addProduct(ProductEntity product, [int qty = 1]) {
    if (product.stock <= 0) return;

    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((i) => i.product.id == product.id);

    if (index >= 0) {
      final current = items[index];
      final newQty = (current.qty + qty).clamp(1, product.stock);
      items[index] = current.copyWith(qty: newQty);
    } else {
      items.add(CartItem(
          product: product, qty: qty > product.stock ? product.stock : qty));
    }

    state = state.copyWith(items: items);
  }

  void decreaseQty(ProductEntity product) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((i) => i.product.id == product.id);

    if (index >= 0) {
      final current = items[index];
      if (current.qty > 1) {
        items[index] = current.copyWith(qty: current.qty - 1);
      } else {
        items.removeAt(index);
      }
      state = state.copyWith(items: items);
    }
  }

  void removeProduct(ProductEntity product) {
    final items = List<CartItem>.from(state.items)
      ..removeWhere((i) => i.product.id == product.id);
    state = state.copyWith(items: items);
  }

  void setDiscount(double value, DiscountType type) {
    state = state.copyWith(discount: value, discountType: type);
  }

  void clearDiscount() {
    state = state.copyWith(discount: 0.0, discountType: DiscountType.nominal);
  }

  void updateTaxRate(bool enabled, double rate) {
    state = state.copyWith(taxRate: enabled ? rate : 0.0);
  }

  void clearCart() {
    state = CartState(taxRate: state.taxRate);
  }
}
