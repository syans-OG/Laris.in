import 'package:equatable/equatable.dart';

class StockLogEntity extends Equatable {
  final int id;
  final int productId;
  final String productName; // Optional helper for UI
  final String type; // 'masuk', 'keluar', 'penyesuaian', 'penjualan'
  final int qtyChange;
  final int totalAfter;
  final String? note;
  final DateTime createdAt;

  const StockLogEntity({
    required this.id,
    required this.productId,
    this.productName = '',
    required this.type,
    required this.qtyChange,
    required this.totalAfter,
    this.note,
    required this.createdAt,
  });

  factory StockLogEntity.fromJson(Map<String, dynamic> json) {
    return StockLogEntity(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      productName: json['product_name'] as String? ?? '',
      type: json['type'] as String,
      qtyChange: json['qty_change'] as int,
      totalAfter: json['total_after'] as int,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'type': type,
      'qty_change': qtyChange,
      'total_after': totalAfter,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, productId, productName, type, qtyChange, totalAfter, note, createdAt];
}
