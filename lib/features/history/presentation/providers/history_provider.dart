import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

// Semua transaksi (untuk Kasir - melihat miliknya sendiri atau Admin - semua)
final historyProvider = FutureProvider<List<TransactionEntity>>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getTransactions();
});

// Filter per cashierId - null = semua kasir (Admin view)
final historyByCashierProvider =
    FutureProvider.family<List<TransactionEntity>, int?>((ref, cashierId) async {
  final repo = ref.watch(transactionRepositoryProvider);
  final all = await repo.getTransactions();
  if (cashierId == null) return all;
  return all.where((t) => t.cashierId == cashierId).toList();
});
