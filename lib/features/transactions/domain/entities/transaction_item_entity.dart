import 'package:equatable/equatable.dart';
import '../../../../features/products/domain/entities/product_entity.dart';

class TransactionItemEntity extends Equatable {
  final int id;
  final int transactionId;
  final int productId;
  final int qty;
  final double unitPrice;
  final double discount;
  final double subtotal;
  final ProductEntity? product; // Joined data

  const TransactionItemEntity({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.qty,
    required this.unitPrice,
    this.discount = 0.0,
    required this.subtotal,
    this.product,
  });

  TransactionItemEntity copyWith({
    int? id,
    int? transactionId,
    int? productId,
    int? qty,
    double? unitPrice,
    double? discount,
    double? subtotal,
    ProductEntity? product,
  }) {
    return TransactionItemEntity(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      qty: qty ?? this.qty,
      unitPrice: unitPrice ?? this.unitPrice,
      discount: discount ?? this.discount,
      subtotal: subtotal ?? this.subtotal,
      product: product ?? this.product,
    );
  }

  factory TransactionItemEntity.fromJson(Map<String, dynamic> json) {
    return TransactionItemEntity(
      id: json['id'] as int,
      transactionId: json['transaction_id'] as int,
      productId: json['product_id'] as int,
      qty: json['qty'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      // Handle joined data if present
      product: json['barcode'] != null ? ProductEntity.fromJson(json) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'product_id': productId,
      'qty': qty,
      'unit_price': unitPrice,
      'discount': discount,
      'subtotal': subtotal,
    };
  }

  @override
  List<Object?> get props => [
        id,
        transactionId,
        productId,
        qty,
        unitPrice,
        discount,
        subtotal,
        product,
      ];
}
