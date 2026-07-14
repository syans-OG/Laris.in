import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

enum HistoryFilterPeriod { all, today, sevenDays, thirtyDays, custom }

// Filter state
final historyFilterPeriodProvider = StateProvider<HistoryFilterPeriod>(
  (ref) => HistoryFilterPeriod.all,
);
final historyFilterDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

// Semua transaksi (untuk Kasir - melihat miliknya sendiri atau Admin - semua)
final historyProvider = FutureProvider<List<TransactionEntity>>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  final all = await repo.getTransactions();
  
  final period = ref.watch(historyFilterPeriodProvider);
  final customRange = ref.watch(historyFilterDateRangeProvider);
  
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  return all.where((t) {
    switch (period) {
      case HistoryFilterPeriod.all:
        return true;
      case HistoryFilterPeriod.today:
        final d = t.createdAt;
        return d.year == today.year && d.month == today.month && d.day == today.day;
      case HistoryFilterPeriod.sevenDays:
        return t.createdAt.isAfter(today.subtract(const Duration(days: 7)));
      case HistoryFilterPeriod.thirtyDays:
        return t.createdAt.isAfter(today.subtract(const Duration(days: 30)));
      case HistoryFilterPeriod.custom:
        if (customRange == null) return true;
        return t.createdAt.isAfter(
              customRange.start.subtract(const Duration(seconds: 1))) &&
            t.createdAt.isBefore(
              customRange.end.add(const Duration(seconds: 1)));
    }
  }).toList();
});

// Filter per cashierId - null = semua kasir (Admin view)
final historyByCashierProvider =
    FutureProvider.family<List<TransactionEntity>, int?>((ref, cashierId) async {
  final repo = ref.watch(transactionRepositoryProvider);
  final all = await repo.getTransactions();
  if (cashierId == null) return all;
  return all.where((t) => t.cashierId == cashierId).toList();
});

// Fetch full transaction details (including items) by ID
final transactionDetailsProvider =
    FutureProvider.family<TransactionEntity?, int>((ref, transactionId) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getTransactionById(transactionId);
});
