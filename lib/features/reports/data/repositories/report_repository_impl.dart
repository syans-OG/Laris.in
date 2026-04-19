import '../../../../core/database/app_database.dart';
import '../../domain/entities/report_models.dart';
import '../../domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final AppDatabase _db;

  ReportRepositoryImpl(this._db);

  @override
  Future<ReportSummary> getSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final startStr = startDate.toIso8601String();
    final endStr = endDate.toIso8601String();

    final db = await _db.database;
    final currentPeriodData = db.select('''
      SELECT 
        SUM(total) as totalRevenue, 
        COUNT(id) as totalTransactions 
      FROM transactions 
      WHERE created_at >= ? AND created_at <= ?
    ''', [startStr, endStr]);

    final currentItemsData = db.select('''
      SELECT SUM(qty) as totalItemsSold
      FROM transaction_items
      JOIN transactions ON transactions.id = transaction_items.transaction_id
      WHERE transactions.created_at >= ? AND transactions.created_at <= ?
    ''', [startStr, endStr]);

    final double totalRevenue = (currentPeriodData.first['totalRevenue'] as num?)?.toDouble() ?? 0.0;
    final int totalTransactions = (currentPeriodData.first['totalTransactions'] as num?)?.toInt() ?? 0;
    final int totalItemsSold = (currentItemsData.first['totalItemsSold'] as num?)?.toInt() ?? 0;
    final double avgPerTransaction = totalTransactions > 0 ? (totalRevenue / totalTransactions) : 0.0;

    // Previous period
    final difference = endDate.difference(startDate);
    final prevStartDate = startDate.subtract(difference);
    final prevEndDate = startDate; // up to current start
    
    final prevStartStr = prevStartDate.toIso8601String();
    final prevEndStr = prevEndDate.toIso8601String();

    final prevPeriodData = db.select('''
      SELECT 
        SUM(total) as prevRevenue, 
        COUNT(id) as prevTransactions 
      FROM transactions 
      WHERE created_at >= ? AND created_at < ?
    ''', [prevStartStr, prevEndStr]);

    final double? prevRevenue = (prevPeriodData.first['prevRevenue'] as num?)?.toDouble();
    final double? prevTransactions = (prevPeriodData.first['prevTransactions'] as num?)?.toDouble();

    return ReportSummary(
      totalRevenue: totalRevenue,
      totalTransactions: totalTransactions,
      totalItemsSold: totalItemsSold,
      avgPerTransaction: avgPerTransaction,
      previousRevenue: prevRevenue,
      previousTransactions: prevTransactions,
    );
  }

  @override
  Future<List<DailyRevenue>> getDailyRevenue({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final startStr = startDate.toIso8601String();
    final endStr = endDate.toIso8601String();
    
    final db = await _db.database;
    
    final isHourly = endDate.difference(startDate).inHours <= 24;
    final substrLength = isHourly ? 13 : 10;
    final appendStr = isHourly ? " || ':00:00'" : "";

    final result = db.select('''
      SELECT SUBSTR(created_at, 1, $substrLength)$appendStr as dateString,
             SUM(total) as revenue
      FROM transactions
      WHERE created_at >= ? AND created_at <= ?
      GROUP BY SUBSTR(created_at, 1, $substrLength)
      ORDER BY dateString ASC
    ''', [startStr, endStr]);

    return result.map((row) {
      return DailyRevenue(
        date: DateTime.parse(row['dateString'] as String),
        revenue: (row['revenue'] as num).toDouble(),
      );
    }).toList();
  }

  @override
  Future<List<TopProduct>> getTopProducts({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 5,
  }) async {
    final startStr = startDate.toIso8601String();
    final endStr = endDate.toIso8601String();
    
    final db = await _db.database;
    final result = db.select('''
      SELECT 
        p.name as productName, 
        SUM(ti.qty) as qtySold, 
        SUM(ti.subtotal) as revenue
      FROM transaction_items ti
      JOIN transactions t ON t.id = ti.transaction_id
      JOIN products p ON p.id = ti.product_id
      WHERE t.created_at >= ? AND t.created_at <= ?
      GROUP BY p.id
      ORDER BY qtySold DESC
      LIMIT ?
    ''', [startStr, endStr, limit]);

    return result.map((row) {
      return TopProduct(
        productName: row['productName'] as String,
        qtySold: (row['qtySold'] as num).toInt(),
        revenue: (row['revenue'] as num).toDouble(),
      );
    }).toList();
  }

  @override
  Future<Map<String, double>> getPaymentMethodBreakdown({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final startStr = startDate.toIso8601String();
    final endStr = endDate.toIso8601String();
    
    final db = await _db.database;
    final result = db.select('''
      SELECT payment_method, SUM(total) as revenue
      FROM transactions
      WHERE created_at >= ? AND created_at <= ?
      GROUP BY payment_method
    ''', [startStr, endStr]);

    final Map<String, double> breakdown = {};
    for (var row in result) {
      final method = (row['payment_method'] as String).toUpperCase();
      final revenue = (row['revenue'] as num).toDouble();
      breakdown[method] = revenue;
    }
    
    return breakdown;
  }
}
