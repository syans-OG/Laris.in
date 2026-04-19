class StockHistory {
  final String id;
  final int productId;
  final String productName;
  final int change;       // positive = tambah, negative = kurang
  final int stockAfter;
  final String reason;   // 'Barang Masuk', 'Rusak/Basi', 'Hilang', 'Koreksi'
  final DateTime createdAt;

  const StockHistory({
    required this.id,
    required this.productId,
    required this.productName,
    required this.change,
    required this.stockAfter,
    required this.reason,
    required this.createdAt,
  });

  bool get isAddition => change > 0;
}
