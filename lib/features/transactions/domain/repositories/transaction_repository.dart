import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<List<TransactionEntity>> getTransactions({DateTime? startDate, DateTime? endDate});
  Future<TransactionEntity?> getTransactionById(int id);
  Future<TransactionEntity> saveTransaction(TransactionEntity transaction);
  Future<void> updatePrintStatus({
    required int transactionId,
    required int isPrinted,
    required String? printedAt,
    required String? printMethod,
  });
}
