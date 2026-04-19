import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/report_models.dart';

enum ReportPeriod { today, sevenDays, thirtyDays, thisMonth, custom }

final reportPeriodProvider = StateProvider<ReportPeriod>((ref) => ReportPeriod.today);
final customDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);



final reportDateRangeProvider = Provider<DateTimeRange>((ref) {
  final period = ref.watch(reportPeriodProvider);
  final now = DateTime.now();
  
  if (period == ReportPeriod.custom) {
    final customRange = ref.watch(customDateRangeProvider);
    if (customRange != null) {
      return customRange;
    }
    // Fallback to today if custom is selected but not set
    return DateTimeRange(
      start: DateTime(now.year, now.month, now.day),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  // Calculate based on period
  switch (period) {
    case ReportPeriod.today:
      return DateTimeRange(
        start: DateTime(now.year, now.month, now.day),
        end: DateTime(now.year, now.month, now.day, 23, 59, 59),
      );
    case ReportPeriod.sevenDays:
      return DateTimeRange(
        start: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6)),
        end: DateTime(now.year, now.month, now.day, 23, 59, 59),
      );
    case ReportPeriod.thirtyDays:
      return DateTimeRange(
        start: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29)),
        end: DateTime(now.year, now.month, now.day, 23, 59, 59),
      );
    case ReportPeriod.thisMonth:
      return DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month, now.day, 23, 59, 59),
      );
    default:
      return DateTimeRange(
        start: DateTime(now.year, now.month, now.day),
        end: DateTime(now.year, now.month, now.day, 23, 59, 59),
      );
  }
});

final reportSummaryProvider = FutureProvider<ReportSummary>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  final range = ref.watch(reportDateRangeProvider);
  return repository.getSummary(startDate: range.start, endDate: range.end);
});

final dailyRevenueProvider = FutureProvider<List<DailyRevenue>>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  final range = ref.watch(reportDateRangeProvider);
  return repository.getDailyRevenue(startDate: range.start, endDate: range.end);
});

final topProductsProvider = FutureProvider<List<TopProduct>>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  final range = ref.watch(reportDateRangeProvider);
  return repository.getTopProducts(startDate: range.start, endDate: range.end);
});

final paymentMethodBreakdownProvider = FutureProvider<Map<String, double>>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  final range = ref.watch(reportDateRangeProvider);
  return repository.getPaymentMethodBreakdown(startDate: range.start, endDate: range.end);
});
