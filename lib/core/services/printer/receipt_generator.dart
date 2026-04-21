import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../../../../features/transactions/domain/entities/transaction_entity.dart';
import '../../../../features/settings/data/settings_repository.dart';

class ReceiptGenerator {
  /// Generates the byte format for ESC/POS thermal printers
  static Future<List<int>> generateReceipt(
    TransactionEntity transaction,
    SettingsRepository settings,
  ) async {
    final profile = await CapabilityProfile.load();
    // Default 58mm printer
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    // Header
    if (settings.showStoreName) {
      bytes += generator.text(
        settings.storeName.toUpperCase(),
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          bold: true,
        ),
      );
    }

    if (settings.showAddress) {
      bytes += generator.text(settings.storeAddress,
          styles: const PosStyles(align: PosAlign.center));
      bytes += generator.text('Telp: ${settings.storePhone}',
          styles: const PosStyles(align: PosAlign.center));
    }
    
    bytes += generator.feed(1);
    bytes += generator.hr();

    // Transaction Info
    bytes += generator.text("No  : TRX-${transaction.id.toString().padLeft(6, '0')}");
    bytes += generator.text("Tgl : ${_formatDate(transaction.createdAt)}");
    bytes += generator.text("Ksr : Admin (ID:${transaction.cashierId})");
    
    bytes += generator.hr();

    // Items List
    for (int i = 0; i < transaction.items!.length; i++) {
      final item = transaction.items![i];
      bytes += generator.text(
        item.product?.name ?? "Item ${item.id}",
        styles: const PosStyles(bold: true),
      );
      
      // Line 2: Prices
      bytes += generator.row([
        PosColumn(
          text: '\${item.qty} x \${item.unitPrice.toStringAsFixed(0)}',
          width: 7,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: item.subtotal.toStringAsFixed(0),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();

    // Grand Totals
    bytes += generator.row([
      PosColumn(text: 'Subtotal', width: 6),
      PosColumn(
        text: transaction.total.toStringAsFixed(0),
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    if (transaction.discount > 0) {
      bytes += generator.row([
        PosColumn(text: 'Diskon', width: 6),
        PosColumn(
          text: '-\${transaction.discount.toStringAsFixed(0)}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    // Note: Tax has been omitted entirely per MVP Decision 03

    // Manually computing grandTotal since the entity only stores total, discount, tax
    final grandTotal = transaction.total - transaction.discount + transaction.tax;

    bytes += generator.row([
      PosColumn(text: 'TOTAL', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(
        text: grandTotal.toStringAsFixed(0),
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
    
    bytes += generator.feed(1);

    bytes += generator.row([
      PosColumn(text: 'TUNAI', width: 6),
      PosColumn(
        text: transaction.paidAmount.toStringAsFixed(0),
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: 'KEMBALI', width: 6),
      PosColumn(
        text: transaction.changeAmount.toStringAsFixed(0),
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.feed(1);
    bytes += generator.hr();
    
    // Footer
    bytes += generator.text(settings.storeFooter,
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('Dicetak oleh Laris.in',
        styles: const PosStyles(align: PosAlign.center, fontType: PosFontType.fontB));
    
    // Feed space to cut/tear
    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }

  static String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min';
  }
}

