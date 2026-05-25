import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = theme.colorScheme.surface;
    final elevatedSurfaceColor = theme.colorScheme.surfaceContainerHighest;
    final textColor = theme.colorScheme.onSurface;
    final mutedColor = theme.colorScheme.onSurfaceVariant;
    final borderColor = theme.colorScheme.outline.withOpacity(isDark ? 0.35 : 0.2);

    return Container(
      color: surfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pesanan Saat Ini',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: textColor,
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
          Divider(height: 1, color: borderColor),

          // ── Item List ────────────────────────────────────────────
          Expanded(
            child: cartState.items.isEmpty
                ? Center(
                    child: Text(
                      'Keranjang Belanja Kosong',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: mutedColor,
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
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? const Color.fromRGBO(0, 0, 0, 0.18) : const Color.fromRGBO(0, 33, 20, 0.02),
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
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: textColor,
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
                                color: elevatedSurfaceColor,
                                borderRadius: BorderRadius.circular(9999),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () => notifier.decreaseQty(item.product),
                                    borderRadius: BorderRadius.circular(9999),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(Icons.remove, size: 18, color: mutedColor),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      '${item.qty}',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: textColor,
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
            decoration: BoxDecoration(
              color: elevatedSurfaceColor,
              border: Border(top: BorderSide(color: borderColor)),
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
                            Text('Diskon',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: mutedColor,
                                )),
                            const SizedBox(width: 4),
                            if (cartState.discountType == DiscountType.percent)
                              Text(
                                '${cartState.discount.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontFamily: 'Space Mono',
                                  color: mutedColor,
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
                              child: Icon(Icons.edit,
                                  size: 16, color: mutedColor),
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
                Divider(color: borderColor, height: 1),
                const SizedBox(height: 16),

                // Grand Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor,
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
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontFamily: 'Inter',
              color: theme.colorScheme.onSurfaceVariant,
            )),
        Text(value,
            style: TextStyle(
              fontFamily: 'Space Mono',
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            )),
      ],
    );
  }
}

