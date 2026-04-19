class ReportSummary {
  final double totalRevenue;
  final int totalTransactions;
  final int totalItemsSold;
  final double avgPerTransaction;
  final double? previousRevenue;
  final double? previousTransactions;

  const ReportSummary({
    required this.totalRevenue,
    required this.totalTransactions,
    required this.totalItemsSold,
    required this.avgPerTransaction,
    this.previousRevenue,
    this.previousTransactions,
  });
}

class DailyRevenue {
  final DateTime date;
  final double revenue;

  const DailyRevenue({
    required this.date,
    required this.revenue,
  });
}

class TopProduct {
  final String productName;
  final int qtySold;
  final double revenue;

  const TopProduct({
    required this.productName,
    required this.qtySold,
    required this.revenue,
  });
}
