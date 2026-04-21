import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../../../../core/services/printer/printer_service.dart';
import '../../../../core/di/providers.dart';
import '../../../settings/data/settings_repository.dart';

final testPrintUseCaseProvider = Provider<TestPrintUseCase>((ref) {
  final printerService = ref.read(printerServiceProvider);
  final settings = ref.read(settingsRepositoryProvider);
  return TestPrintUseCase(printerService, settings);
});

class TestPrintUseCase {
  final PrinterService _printerService;
  final SettingsRepository _settings;

  TestPrintUseCase(this._printerService, this._settings);

  Future<bool> execute() async {
    try {
      final isConnected = await _printerService.isConnected;
      if (!isConnected) return false;

      final profile = await CapabilityProfile.load();
      final generator = Generator(
        _settings.paperSize == 80 ? PaperSize.mm80 : PaperSize.mm58, 
        profile,
      );
      
      List<int> bytes = [];

      bytes += generator.text('TEST PRINT',
          styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2));
      bytes += generator.text('Laris.in POS System', styles: const PosStyles(align: PosAlign.center));
      bytes += generator.hr();
      bytes += generator.text('Status: Berhasil Terhubung', styles: const PosStyles(align: PosAlign.center));
      bytes += generator.text('Lebar Kertas: ${_settings.paperSize}mm', styles: const PosStyles(align: PosAlign.center));
      bytes += generator.hr();
      bytes += generator.feed(2);
      bytes += generator.cut();

      return await _printerService.printBytes(bytes);
    } catch (e) {
      return false;
    }
  }
}
