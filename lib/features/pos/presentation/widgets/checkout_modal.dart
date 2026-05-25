import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../settings/data/settings_repository.dart';
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
  String _paymentMethod = 'CASH';

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  Future<void> _processPayment(double grandTotal) async {
    final isQris = _paymentMethod == 'QRIS';
    if (!isQris && _cashReceived < grandTotal) return;
    if (_isLoading) return; // Cegah double tap

    setState(() => _isLoading = true);
    try {
      final cartState = ref.read(cartProvider);
      final paidAmount = isQris ? grandTotal : _cashReceived;
      
      // SATU-SATUNYA tugas fungsi ini: simpan transaksi murni
      final transaction = await ref
          .read(confirmPaymentUseCaseProvider)
          .execute(
            cart: cartState,
            paymentMethod: _paymentMethod, 
            paidAmount: paidAmount,
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

  Widget _buildPaymentMethodSelector(bool canUseQris, bool qrisEnabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Metode Pembayaran',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF3D4A42),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPaymentMethodOption(
                method: 'CASH',
                label: 'Tunai',
                icon: Icons.payments,
                enabled: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPaymentMethodOption(
                method: 'QRIS',
                label: 'QRIS',
                icon: Icons.qr_code_2,
                enabled: canUseQris,
                disabledMessage: qrisEnabled ? 'Upload gambar QRIS dulu' : 'Aktifkan QRIS di pengaturan',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodOption({
    required String method,
    required String label,
    required IconData icon,
    required bool enabled,
    String? disabledMessage,
  }) {
    final selected = _paymentMethod == method;
    final borderColor = selected ? AppColors.primary : const Color.fromRGBO(188, 202, 192, 0.4);
    final backgroundColor = selected ? const Color(0xFFEAF7F1) : Colors.white;
    final foregroundColor = enabled
        ? selected ? AppColors.primary : const Color(0xFF3D4A42)
        : const Color(0xFFBCCAC0);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: enabled
            ? () => setState(() => _paymentMethod = method)
            : () {
                if (disabledMessage == null) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(disabledMessage)),
                );
              },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: selected ? 1.8 : 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foregroundColor, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: foregroundColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrisPanel(String? qrisImagePath, bool canUseQris) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromRGBO(188, 202, 192, 0.35)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: canUseQris && qrisImagePath != null
                ? Image.file(
                    File(qrisImagePath),
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  )
                : Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.white,
                    child: const Icon(Icons.qr_code_2, size: 72, color: Color(0xFFBCCAC0)),
                  ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Pastikan pembayaran sudah masuk sebelum konfirmasi.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF3D4A42),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final qrisEnabled = ref.watch(qrisEnabledProvider);
    final qrisImagePath = ref.watch(qrisImagePathProvider);
    final hasQrisImage = qrisImagePath != null && qrisImagePath.isNotEmpty && File(qrisImagePath).existsSync();
    final canUseQris = qrisEnabled && hasQrisImage;
    final grandTotal = cartState.grandTotal;
    final isQris = _paymentMethod == 'QRIS';
    final change = isQris ? 0.0 : _cashReceived - grandTotal;
    final isSufficient = isQris ? canUseQris : _cashReceived >= grandTotal;

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

              _buildPaymentMethodSelector(canUseQris, qrisEnabled),
              const SizedBox(height: 24),

              if (isQris) ...[
                _buildQrisPanel(qrisImagePath, canUseQris),
              ] else ...[
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
              ],
              const SizedBox(height: 24),

              // Payment Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isQris ? 'Nominal QRIS' : 'Kembalian',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF3D4A42)
                    )
                  ),
                  Flexible(
                    child: Text(
                      isQris
                          ? CurrencyFormatter.format(grandTotal)
                          : change < 0 ? 'Kurang Bayar' : CurrencyFormatter.format(change),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Space Mono',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: !isQris && change < 0 ? const Color(0xFFBA1A1A) : const Color(0xFF191C1D),
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
                                    isQris ? 'Konfirmasi Dibayar' : 'Proses Transaksi',
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

