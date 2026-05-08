import 'dart:ui';
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
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 33, 20, 0.08),
                blurRadius: 24,
                offset: Offset(0, -12),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top drag indicator
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7E8E9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Title
              const Text(
                'Pembayaran',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  color: Color(0xFF191C1D),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Total Amount Summary (Hero area)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Text(
                      'TOTAL TAGIHAN', 
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFF3D4A42),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      )
                    ),
                    const SizedBox(height: 12),
                    Text(
                      CurrencyFormatter.format(grandTotal),
                      style: const TextStyle(
                        fontFamily: 'Space Mono',
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Cash Input
              const Text(
                'Tunai Diterima',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF3D4A42),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color.fromRGBO(188, 202, 192, 0.4), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 20, right: 12),
                      child: Text(
                        'Rp',
                        style: TextStyle(
                          fontFamily: 'Space Mono',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color(0xFF3D4A42),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _cashController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontFamily: 'Space Mono',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF191C1D),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: '0',
                          hintStyle: TextStyle(
                            color: Color(0xFFBCCAC0),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _cashReceived = double.tryParse(val) ?? 0.0;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Change Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kembalian', 
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF3D4A42)
                    )
                  ),
                  Flexible(
                    child: Text(
                      change < 0 ? 'Kurang Bayar' : CurrencyFormatter.format(change),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Space Mono',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: change < 0 ? const Color(0xFFBA1A1A) : const Color(0xFF191C1D),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF3D4A42),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isSufficient 
                          ? const LinearGradient(
                              colors: [Color(0xFF006948), Color(0xFF00855D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                        color: isSufficient ? null : const Color(0xFFE7E8E9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSufficient ? const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 105, 72, 0.2),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ] : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isSufficient ? () => _processPayment(grandTotal) : null,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Center(
                              child: _isLoading
                                ? const SizedBox(
                                    height: 20, width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    'Proses Transaksi',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.bold,
                                      color: isSufficient ? Colors.white : const Color(0xFFBCCAC0),
                                      fontSize: 16,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

