import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final int id;
  final String barcode;
  final String name;
  final double price;
  final double? costPrice;
  final int stock;
  final int? categoryId;
  final String? imageUrl;
  final bool isActive;

  const ProductEntity({
    required this.id,
    required this.barcode,
    required this.name,
    required this.price,
    this.costPrice,
    this.stock = 0,
    this.categoryId,
    this.imageUrl,
    this.isActive = true,
  });

  ProductEntity copyWith({
    int? id,
    String? barcode,
    String? name,
    double? price,
    double? costPrice,
    int? stock,
    int? categoryId,
    String? imageUrl,
    bool? isActive,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  factory ProductEntity.fromJson(Map<String, dynamic> json) {
    return ProductEntity(
      id: json['id'] as int,
      barcode: json['barcode'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      costPrice: json['cost_price'] != null ? (json['cost_price'] as num).toDouble() : null,
      stock: json['stock'] as int? ?? 0,
      categoryId: json['category_id'] as int?,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'price': price,
      'cost_price': costPrice,
      'stock': stock,
      'category_id': categoryId,
      'image_url': imageUrl,
      'is_active': isActive ? 1 : 0,
    };
  }

  @override
  List<Object?> get props => [
        id,
        barcode,
        name,
        price,
        costPrice,
        stock,
        categoryId,
        imageUrl,
        isActive,
      ];
}
