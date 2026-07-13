import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import '../../../../core/services/receipt_save_service.dart';
import '../../../../core/services/printer/receipt_generator.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../pos/domain/usecases/print_receipt_usecase.dart';
import '../../../settings/data/settings_repository.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../providers/history_provider.dart';

class DigitalReceiptBottomSheet extends ConsumerWidget {
  final TransactionEntity transaction;
  final ScreenshotController _screenshotController = ScreenshotController();

  DigitalReceiptBottomSheet({
    super.key,
    required this.transaction,
  });

  Future<void> _handlePrint(BuildContext context, WidgetRef ref) async {
    // Tampilkan loading dialog atau ubah state
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menyiapkan printer...')),
    );

    final useCase = ref.read(printReceiptUseCaseProvider);
    final result = await useCase.execute(transaction);

    if (!context.mounted) return;

    switch (result) {
      case PrintResult.success:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Struk berhasil dicetak!')),
        );
        break;
      case PrintResult.noPrinter:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Printer tidak terhubung. Periksa pengaturan printer Anda.')),
        );
        break;
      case PrintResult.timeout:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Koneksi printer timeout.')),
        );
        break;
      case PrintResult.failed:
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mencetak struk.')),
        );
        break;
    }
  }

  void _handleShare(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsRepositoryProvider);
    final receiptText = ReceiptGenerator.generateTextReceipt(transaction, settings);
    Share.share(receiptText, subject: 'Struk Laris.in');
  }

  Future<void> _handleSave(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menyiapkan gambar struk...')),
    );

    final success = await ReceiptSaveService.captureAndSave(
      controller: _screenshotController,
      invoiceNo: transaction.invoiceNo,
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Struk berhasil dibagikan/disimpan!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan struk.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch store info from settings
    final storeName = ref.watch(storeNameProvider);
    final storeAddress = ref.watch(storeAddressProvider);
    final storePhone = ref.watch(storePhoneProvider);

    final invoiceDisplay = transaction.invoiceNo.contains(r'${')
        ? 'TRX-${transaction.id.toString().padLeft(4, '0')}'
        : transaction.invoiceNo;
    
    final transactionDetailsAsync = ref.watch(transactionDetailsProvider(transaction.id));
    final fullTransaction = transactionDetailsAsync.value;
    
    // Check if item details are available. In history, it might just be the summary. 
    // Usually transaction.items holds the detail if eager loaded.
    final itemsToDisplay = fullTransaction?.items ?? transaction.items;
    final hasItems = itemsToDisplay != null && itemsToDisplay.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              height: 6,
              width: 48,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFE7E8E9),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          
          // Receipt Container
          Screenshot(
            controller: _screenshotController,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFBCCAC0).withValues(alpha: 0.3),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(25, 33, 25, 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (Store Info)
                Text(
                  storeName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Space Mono',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF191C1D),
                  ),
                ),
                if (storeAddress.isNotEmpty)
                  Text(
                    storeAddress,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Space Mono',
                      fontSize: 12,
                      color: Color(0xFF3D4A42),
                    ),
                  ),
                if (storePhone.isNotEmpty && storePhone != '-')
                  Text(
                    'Telp: $storePhone',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Space Mono',
                      fontSize: 12,
                      color: Color(0xFF3D4A42),
                    ),
                  ),
                  
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    '--------------------------------------------------',
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(fontFamily: 'Space Mono', color: Color(0xFF3D4A42), fontSize: 12),
                  ),
                ),
                
                // Transaction Meta
                _buildMetaRow('Invoice:', invoiceDisplay),
                _buildMetaRow('Waktu:', DateFormat('dd MMM yyyy HH:mm').format(transaction.createdAt)),
                _buildMetaRow('Kasir:', transaction.cashierId == 1 ? 'Admin' : 'Kasir ${transaction.cashierId}'),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    '--------------------------------------------------',
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(fontFamily: 'Space Mono', color: Color(0xFF3D4A42), fontSize: 12),
                  ),
                ),

                // Items list
                if (transactionDetailsAsync.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Color(0xFF006948), strokeWidth: 2),
                      ),
                    ),
                  )
                else if (hasItems) ...[
                  ...itemsToDisplay!.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product?.name ?? 'Produk ${item.productId}',
                                  style: const TextStyle(
                                    fontFamily: 'Space Mono',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Color(0xFF3D4A42),
                                  ),
                                ),
                                Text(
                                  '${item.qty} x ${CurrencyFormatter.format(item.unitPrice)}',
                                  style: const TextStyle(
                                    fontFamily: 'Space Mono',
                                    fontSize: 12,
                                    color: Color(0xFF3D4A42),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(item.subtotal),
                            style: const TextStyle(
                              fontFamily: 'Space Mono',
                              fontSize: 12,
                              color: Color(0xFF3D4A42),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Padding(
                    padding: EdgeInsets.only(top: 4, bottom: 8.0),
                    child: Text(
                      '--------------------------------------------------',
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: TextStyle(fontFamily: 'Space Mono', color: Color(0xFF3D4A42), fontSize: 12),
                    ),
                  ),
                ],

                // Totals
                if (hasItems && transaction.tax > 0) ...[
                  _buildTotalRow('SUBTOTAL', transaction.total + transaction.discount - transaction.tax, isBold: true),
                  _buildTotalRow('PAJAK', transaction.tax),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      '--------------------------------------------------',
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: TextStyle(fontFamily: 'Space Mono', color: Color(0xFF3D4A42), fontSize: 12),
                    ),
                  ),
                ],
                
                // Grand Total
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL',
                        style: TextStyle(
                          fontFamily: 'Space Mono',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF006948),
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(transaction.total),
                        style: const TextStyle(
                          fontFamily: 'Space Mono',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF006948),
                        ),
                      ),
                    ],
                  ),
                ),

                // Payment Method
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'METODE BAYAR:',
                        style: TextStyle(
                          fontFamily: 'Space Mono',
                          fontSize: 12,
                          color: Color(0xFF3D4A42),
                        ),
                      ),
                      Text(
                        transaction.paymentMethod.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Space Mono',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF3D4A42),
                        ),
                      ),
                    ],
                  ),
                ),

                // Footer
                const Center(
                  child: Text(
                    'Terima kasih atas kunjungan Anda!\nSimpan struk ini sebagai bukti',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Space Mono',
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      color: Color(0xFF3D4A42),
                    ),
                  ),
                )
              ],
            ),
          ),
          ),
          const SizedBox(height: 16),
          
          // Actions Row
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.print_outlined,
                  label: 'CETAK',
                  onTap: () => _handlePrint(context, ref),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.share_outlined,
                  label: 'BAGIKAN',
                  onTap: () => _handleShare(context, ref),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.download_outlined,
                  label: 'SIMPAN',
                  onTap: () => _handleSave(context),
                  isPrimary: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Close button
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Tutup Detail',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0x993D4A42),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Space Mono', fontSize: 12, color: Color(0xFF3D4A42))),
          Text(value, style: const TextStyle(fontFamily: 'Space Mono', fontSize: 12, color: Color(0xFF3D4A42))),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: TextStyle(
              fontFamily: 'Space Mono', 
              fontSize: 12, 
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: const Color(0xFF191C1D)
            )
          ),
          Text(
            CurrencyFormatter.format(amount), 
            style: TextStyle(
              fontFamily: 'Space Mono', 
              fontSize: 12, 
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: const Color(0xFF191C1D)
            )
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? null : const Color(0xFFE7E8E9),
          gradient: isPrimary 
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF006948), Color(0xFF00855D)],
              )
            : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isPrimary
            ? const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  blurRadius: 15,
                  offset: Offset(0, 10),
                ),
              ]
            : null,
        ),
        child: Column(
          children: [
            Icon(
              icon, 
              size: 20, 
              color: isPrimary ? Colors.white : const Color(0xFF3D4A42)
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 0.5,
                color: isPrimary ? Colors.white : const Color(0xFF3D4A42),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
