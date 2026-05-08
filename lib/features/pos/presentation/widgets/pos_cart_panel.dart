import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/cart_provider.dart';
import '../models/cart_state.dart';
import '../../../settings/data/settings_repository.dart';
import 'checkout_modal.dart';
import 'discount_bottom_sheet.dart';

class PosCartPanel extends ConsumerWidget {
  final ScrollController? scrollController;

  const PosCartPanel({super.key, this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);
    final discountEnabled = ref.watch(discountEnabledProvider);
    final taxEnabled = ref.watch(taxEnabledProvider);

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pesanan Saat Ini',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF191C1D),
                  ),
                ),
                if (cartState.items.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => notifier.clearCart(),
                    icon: const Icon(Icons.delete_outline,
                        color: Color(0xFFBA1A1A), size: 18),
                    label: const Text(
                      'Kosongkan',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFBA1A1A),
                        fontSize: 13,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      backgroundColor: const Color(0xFFFFF0F0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color.fromRGBO(188, 202, 192, 0.2)),

          // ── Item List ────────────────────────────────────────────
          Expanded(
            child: cartState.items.isEmpty
                ? const Center(
                    child: Text(
                      'Keranjang Belanja Kosong',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF3D4A42),
                      ),
                    ),
                  )
                : ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    itemCount: cartState.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color.fromRGBO(188, 202, 192, 0.2)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 33, 20, 0.02),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Color(0xFF191C1D),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    CurrencyFormatter.format(item.product.price),
                                    style: const TextStyle(
                                      fontFamily: 'Space Mono',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(9999),
                                border: Border.all(color: const Color.fromRGBO(188, 202, 192, 0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () => notifier.decreaseQty(item.product),
                                    borderRadius: BorderRadius.circular(9999),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(Icons.remove, size: 18, color: Color(0xFF3D4A42)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      '${item.qty}',
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: Color(0xFF191C1D),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => notifier.addProduct(item.product),
                                    borderRadius: BorderRadius.circular(9999),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(2),
                                        child: const Icon(Icons.add, size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // ── Summary Panel ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FA),
              border: Border(top: BorderSide(color: Color.fromRGBO(188, 202, 192, 0.2))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Subtotal
                _SummaryRow(
                  label: 'Subtotal',
                  value: CurrencyFormatter.format(cartState.subTotal),
                ),

                // ── Diskon ──────────────────────────────────────────
                if (discountEnabled) ...[
                  const SizedBox(height: 12),
                  if (cartState.discountAmount > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('Diskon',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Color(0xFF3D4A42),
                                )),
                            const SizedBox(width: 4),
                            if (cartState.discountType == DiscountType.percent)
                              Text(
                                '${cartState.discount.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontFamily: 'Space Mono',
                                  color: Color(0xFF3D4A42),
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '- ${CurrencyFormatter.format(cartState.discountAmount)}',
                              style: const TextStyle(
                                fontFamily: 'Space Mono',
                                color: Color(0xFF006948),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _openDiscount(context, ref),
                              child: const Icon(Icons.edit,
                                  size: 16, color: Color(0xFF3D4A42)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ] else ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: cartState.items.isEmpty
                            ? null
                            : () => _openDiscount(context, ref),
                        icon: const Icon(Icons.local_offer_outlined, size: 16),
                        label: const Text(
                          'Tambah Diskon',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ],
                ],

                // ── Pajak ────────────────────────────────────────────
                if (taxEnabled && cartState.taxAmount > 0) ...[
                  const SizedBox(height: 12),
                  _SummaryRow(
                    label: 'Pajak (${cartState.taxRate.toStringAsFixed(0)}%)',
                    value: CurrencyFormatter.format(cartState.taxAmount),
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(color: Color.fromRGBO(188, 202, 192, 0.2), height: 1),
                const SizedBox(height: 16),

                // Grand Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF191C1D),
                        )),
                    Text(
                      CurrencyFormatter.format(cartState.grandTotal),
                      style: const TextStyle(
                        fontFamily: 'Space Mono',
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF006948), Color(0xFF00855D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 105, 72, 0.2),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: cartState.items.isEmpty
                          ? null
                          : () async {
                              final result = await showModalBottomSheet<bool>(
                                context: context,
                                isScrollControlled: true,
                                useSafeArea: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => const CheckoutModal(),
                              );
                              if (result == true && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Pembayaran berhasil!')),
                                );
                              }
                            },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'PEMBAYARAN',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 14,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openDiscount(BuildContext context, WidgetRef ref) {
    final cartState = ref.read(cartProvider);
    showDiscountBottomSheet(
      context: context,
      currentDiscount: cartState.discount,
      currentType: cartState.discountType,
      subTotal: cartState.subTotal,
      onSet: (value, type) =>
          ref.read(cartProvider.notifier).setDiscount(value, type),
      onClear: () => ref.read(cartProvider.notifier).clearDiscount(),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF3D4A42),
            )),
        Text(value,
            style: const TextStyle(
              fontFamily: 'Space Mono',
              fontWeight: FontWeight.bold,
              color: Color(0xFF191C1D),
            )),
      ],
    );
  }
}

