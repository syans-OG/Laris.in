import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/printer/printer_service.dart';
import '../../../../core/services/printer/receipt_generator.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../../settings/data/settings_repository.dart';
import '../../../../core/di/providers.dart';

enum PrintResult { success, failed, noPrinter, timeout }

final printReceiptUseCaseProvider = Provider<PrintReceiptUseCase>((ref) {
  final printerService = ref.read(printerServiceProvider);
  final repository = ref.read(transactionRepositoryProvider);
  final settings = ref.read(settingsRepositoryProvider);
  return PrintReceiptUseCase(printerService, repository, settings);
});

class PrintReceiptUseCase {
  final PrinterService _printerService;
  final TransactionRepository _repository;
  final SettingsRepository _settings;

  PrintReceiptUseCase(this._printerService, this._repository, this._settings);

  Future<PrintResult> execute(TransactionEntity transaction) async {
    try {
      // 1. Cek koneksi printer dengan timeout 5 detik
      final isConnected = await _printerService.isConnected.timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );
      
      if (!isConnected) {
        return PrintResult.noPrinter;
      }

      // 2. Generate ESC/POS bytes
      final bytes = await ReceiptGenerator.generateReceipt(transaction, _settings);

      // 3. Kirim ke printer dengan timeout
      final isSuccess = await _printerService
          .printBytes(bytes)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Print timeout'),
          );

      if (!isSuccess) {
        return PrintResult.failed;
      }

      // 4. Update database HANYA jika print berhasil
      try {
        await _repository.updatePrintStatus(
          transactionId: transaction.id,
          isPrinted: 1,
          printedAt: DateTime.now().toIso8601String(),
          printMethod: 'bluetooth',
        );
      } catch (e) {
        // Jika update DB gagal: tetap return success
        // print sudah keluar, data kurang penting dari kertas
      }

      return PrintResult.success;
    } on TimeoutException {
      return PrintResult.timeout;
    } catch (e) {
      return PrintResult.failed;
    }
  }
}
