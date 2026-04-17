import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/products/domain/entities/product_entity.dart';
import '../models/cart_state.dart';

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addProduct(ProductEntity product, [int qty = 1]) {
    // Pastikan stok mencukupi
    if (product.stock <= 0) return;

    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((i) => i.product.id == product.id);

    if (index >= 0) {
      final currentItem = items[index];
      // Pastikan qty tidak melebihi stok yang ada
      if (currentItem.qty + qty <= product.stock) {
        items[index] = currentItem.copyWith(qty: currentItem.qty + qty);
      } else {
        // Jika melebihi stok, set sampai batas max stok
        items[index] = currentItem.copyWith(qty: product.stock);
      }
    } else {
      // Menambahkan produk baru yang belum ada di keranjang
      items.add(CartItem(product: product, qty: qty > product.stock ? product.stock : qty));
    }

    state = state.copyWith(items: items);
  }

  void decreaseQty(ProductEntity product) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((i) => i.product.id == product.id);

    if (index >= 0) {
      final currentItem = items[index];
      if (currentItem.qty > 1) {
        items[index] = currentItem.copyWith(qty: currentItem.qty - 1);
      } else {
        items.removeAt(index);
      }
      state = state.copyWith(items: items);
    }
  }

  void removeProduct(ProductEntity product) {
    final items = List<CartItem>.from(state.items);
    items.removeWhere((i) => i.product.id == product.id);
    state = state.copyWith(items: items);
  }

  void setDiscount(double discount) {
    // Note: User approved discount logic implemented here to future proof, 
    // but the UI will send 0 for now as requested.
    state = state.copyWith(discount: discount);
  }

  void clearCart() {
    state = const CartState();
  }
}
