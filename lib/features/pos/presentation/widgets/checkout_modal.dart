import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_input.dart';
import '../providers/cart_provider.dart';
import '../../domain/usecases/confirm_payment_usecase.dart';
import '../screens/digital_receipt_screen.dart';
import '../../../../core/utils/currency_formatter.dart';

class CheckoutModal extends ConsumerStatefulWidget {
  const CheckoutModal({super.key});

  @override
  ConsumerState<CheckoutModal> createState() => _CheckoutModalState();
}

class _CheckoutModalState extends ConsumerState<CheckoutModal> {
  final TextEditingController _cashController = TextEditingController();
  double _cashReceived = 0.0;
  bool _isLoading = false;
  final String _paymentMethod = 'CASH'; // Default untuk MVP (Tunai)

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  Future<void> _processPayment(double grandTotal) async {
    if (_cashReceived < grandTotal) return;
    if (_isLoading) return; // Cegah double tap

    setState(() => _isLoading = true);
    try {
      final cartState = ref.read(cartProvider);
      
      // SATU-SATUNYA tugas fungsi ini: simpan transaksi murni
      final transaction = await ref
          .read(confirmPaymentUseCaseProvider)
          .execute(
            cart: cartState,
            paymentMethod: _paymentMethod, 
            paidAmount: _cashReceived,
          );

      // Reset cart setelah berhasil simpan
      ref.read(cartProvider.notifier).clearCart();

      // Tutup modal dan navigasi ke DigitalReceiptScreen
      if (mounted) {
        final navigator = Navigator.of(context);
        navigator.pop(); // Tutup modal

        navigator.push(
          MaterialPageRoute(
            builder: (_) => DigitalReceiptScreen(
              transaction: transaction,
            ),
          ),
        );
      }


    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan transaksi. Coba lagi.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final grandTotal = cartState.grandTotal;
    final change = _cashReceived - grandTotal;
    final isSufficient = _cashReceived >= grandTotal;

    return Padding(
      // Ensure it floats above keyboard
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pembayaran',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Total Amount Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface2Dark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text('Total Tagihan', style: TextStyle(color: AppColors.textMutedDark)),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.format(grandTotal),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Cash Input
            AppTextInput(
              label: 'Tunai Diterima (Cash)',
              controller: _cashController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.money,
              onChanged: (val) {
                setState(() {
                  _cashReceived = double.tryParse(val) ?? 0.0;
                });
              },
            ),
            const SizedBox(height: 16),

            // Change Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kembalian:', style: TextStyle(fontSize: 16)),
                Flexible(
                  child: Text(
                    change < 0 ? 'Kurang Bayar!' : CurrencyFormatter.format(change),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: change < 0 ? AppColors.error : AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Batal',
                    isPrimary: false,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    text: 'Proses Transaksi',
                    isLoading: _isLoading,
                    onPressed: isSufficient ? () => _processPayment(grandTotal) : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
