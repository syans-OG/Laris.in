import 'package:equatable/equatable.dart';
import '../../../../features/products/domain/entities/product_entity.dart';

class CartItem extends Equatable {
  final ProductEntity product;
  final int qty;

  const CartItem({
    required this.product,
    required this.qty,
  });

  CartItem copyWith({
    ProductEntity? product,
    int? qty,
  }) {
    return CartItem(
      product: product ?? this.product,
      qty: qty ?? this.qty,
    );
  }

  double get subtotal => product.price * qty;

  @override
  List<Object?> get props => [product, qty];
}

class CartState extends Equatable {
  final List<CartItem> items;
  final double discount;
  final double tax;

  const CartState({
    this.items = const [],
    this.discount = 0.0,
    this.tax = 0.0,
  });

  CartState copyWith({
    List<CartItem>? items,
    double? discount,
    double? tax,
  }) {
    return CartState(
      items: items ?? this.items,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
    );
  }

  int get totalQty => items.fold(0, (sum, item) => sum + item.qty);

  double get subTotal => items.fold(0.0, (sum, item) => sum + item.subtotal);

  // Per user decision 02: discount logic disabled for MVP (forced to 0) 
  // Per user decision 03: tax logic disabled for MVP (forced to 0)
  double get grandTotal => subTotal - discount + tax;

  @override
  List<Object?> get props => [items, discount, tax];
}
