import '../entities/report_models.dart';

abstract class ReportRepository {
  Future<ReportSummary> getSummary({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<DailyRevenue>> getDailyRevenue({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<TopProduct>> getTopProducts({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 5,
  });

  Future<Map<String, double>> getPaymentMethodBreakdown({
    required DateTime startDate,
    required DateTime endDate,
  });
}
