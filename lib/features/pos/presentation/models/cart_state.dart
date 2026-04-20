import 'package:equatable/equatable.dart';
import '../../../../features/products/domain/entities/product_entity.dart';

enum DiscountType { nominal, percent }

class CartItem extends Equatable {
  final ProductEntity product;
  final int qty;

  const CartItem({
    required this.product,
    required this.qty,
  });

  CartItem copyWith({ProductEntity? product, int? qty}) {
    return CartItem(product: product ?? this.product, qty: qty ?? this.qty);
  }

  double get subtotal => product.price * qty;

  @override
  List<Object?> get props => [product, qty];
}

class CartState extends Equatable {
  final List<CartItem> items;
  final double discount;
  final DiscountType discountType;
  final double taxRate; // persentase, misal 11.0 untuk 11%

  const CartState({
    this.items = const [],
    this.discount = 0.0,
    this.discountType = DiscountType.nominal,
    this.taxRate = 0.0,
  });

  CartState copyWith({
    List<CartItem>? items,
    double? discount,
    DiscountType? discountType,
    double? taxRate,
  }) {
    return CartState(
      items: items ?? this.items,
      discount: discount ?? this.discount,
      discountType: discountType ?? this.discountType,
      taxRate: taxRate ?? this.taxRate,
    );
  }

  int get totalQty => items.fold(0, (sum, item) => sum + item.qty);

  double get subTotal => items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get discountAmount {
    if (discount <= 0) return 0.0;
    if (discountType == DiscountType.percent) {
      return (subTotal * discount / 100).clamp(0.0, subTotal);
    }
    return discount.clamp(0.0, subTotal);
  }

  double get taxAmount {
    if (taxRate <= 0) return 0.0;
    return (subTotal - discountAmount) * taxRate / 100;
  }

  double get grandTotal => subTotal - discountAmount + taxAmount;

  @override
  List<Object?> get props => [items, discount, discountType, taxRate];
}
