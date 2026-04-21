import '../../../../core/database/app_database.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_item_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final AppDatabase _db;

  TransactionRepositoryImpl(this._db);

  @override
  Future<List<TransactionEntity>> getTransactions({DateTime? startDate, DateTime? endDate}) async {
    final db = await _db.database;
    
    String query = 'SELECT * FROM transactions';
    List<Object?> args = [];

    if (startDate != null && endDate != null) {
      query += ' WHERE created_at >= ? AND created_at <= ?';
      args.addAll([startDate.toIso8601String(), endDate.toIso8601String()]);
    }

    query += ' ORDER BY created_at DESC';
    
    final result = db.select(query, args);
    return result.map((row) => TransactionEntity.fromJson(row)).toList();
  }

  @override
  Future<TransactionEntity?> getTransactionById(int id) async {
    final db = await _db.database;
    
    // Get transaction header
    final headerResult = db.select('SELECT * FROM transactions WHERE id = ? LIMIT 1', [id]);
    if (headerResult.isEmpty) return null;
    
    TransactionEntity txn = TransactionEntity.fromJson(headerResult.first);

    // Get associated items with joined product data
    final itemsResult = db.select('''
      SELECT ti.*, p.barcode, p.name, p.price, p.cost_price, p.stock, p.category_id, p.image_url, p.is_active
      FROM transaction_items ti 
      JOIN products p ON ti.product_id = p.id
      WHERE ti.transaction_id = ?
    ''', [id]);
    
    List<TransactionItemEntity> items = itemsResult.map((row) => TransactionItemEntity.fromJson(row)).toList();
    
    return txn.copyWith(items: items);
  }

  @override
  Future<TransactionEntity> saveTransaction(TransactionEntity transaction) async {
    final db = await _db.database;
    
    // Use transaction block for safety
    db.execute('BEGIN TRANSACTION');
    
    try {
      // 1. Insert header
      db.execute('''
        INSERT INTO transactions (invoice_no, total, discount, tax, payment_method, paid_amount, change_amount, cashier_id, created_at, is_printed, printed_at, print_method, share_method)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        transaction.invoiceNo,
        transaction.total,
        transaction.discount,
        transaction.tax,
        transaction.paymentMethod,
        transaction.paidAmount,
        transaction.changeAmount,
        transaction.cashierId,
        transaction.createdAt.toIso8601String(),
        transaction.isPrinted,
        transaction.printedAt,
        transaction.printMethod,
        transaction.shareMethod,
      ]);
      
      final txnIdResult = db.select("SELECT last_insert_rowid() as id");
      final newTxnId = txnIdResult.first['id'] as int;

      // 2. Insert items and reduce stock
      if (transaction.items != null) {
        for (final item in transaction.items!) {
          db.execute('''
            INSERT INTO transaction_items (transaction_id, product_id, qty, unit_price, discount, subtotal)
            VALUES (?, ?, ?, ?, ?, ?)
          ''', [
            newTxnId,
            item.productId,
            item.qty,
            item.unitPrice,
            item.discount,
            item.subtotal,
          ]);

          // Decrease product stock
          db.execute('UPDATE products SET stock = stock - ? WHERE id = ?', [item.qty, item.productId]);

          // Log the stock change
          final stockResult = db.select('SELECT stock FROM products WHERE id = ? LIMIT 1', [item.productId]);
          final totalAfter = stockResult.first['stock'] as int;

          db.execute('''
            INSERT INTO stock_logs (product_id, type, qty_change, total_after, note, created_at)
            VALUES (?, ?, ?, ?, ?, ?)
          ''', [
            item.productId,
            'penjualan',
            -item.qty,
            totalAfter,
            'Invoice: ${transaction.invoiceNo}',
            DateTime.now().toIso8601String(),
          ]);
        }
      }

      db.execute('COMMIT');
      
      // Return fresh from DB with items
      return (await getTransactionById(newTxnId))!;
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  @override
  Future<void> updatePrintStatus({
    required int transactionId,
    required int isPrinted,
    required String? printedAt,
    required String? printMethod,
  }) async {
    final db = await _db.database;
    db.execute('''
      UPDATE transactions
      SET is_printed = ?,
          printed_at = ?,
          print_method = ?
      WHERE id = ?
    ''', [isPrinted, printedAt, printMethod, transactionId]);
  }

  @override
  Future<void> deleteAllTransactions() async {
    final db = await _db.database;
    db.execute('DELETE FROM transaction_items');
    db.execute('DELETE FROM transactions');
  }
}
