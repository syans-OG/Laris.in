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
      color: AppColors.surfaceDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pesanan Saat Ini',
                    style: Theme.of(context).textTheme.headlineMedium),
                if (cartState.items.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => notifier.clearCart(),
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.error, size: 20),
                    label: const Text('Kosongkan',
                        style: TextStyle(color: AppColors.error)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderDark),

          // ── Item List ────────────────────────────────────────────
          Expanded(
            child: cartState.items.isEmpty
                ? const Center(
                    child: Text('Keranjang Belanja Kosong',
                        style:
                            TextStyle(color: AppColors.textMutedDark)),
                  )
                : ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: cartState.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      return AppCard(
                        padding: const EdgeInsets.all(12),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    CurrencyFormatter.format(item.product.price),
                                    style: const TextStyle(
                                        color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      notifier.decreaseQty(item.product),
                                  icon: const Icon(
                                      Icons.remove_circle_outline,
                                      size: 24),
                                  color: AppColors.textMutedDark,
                                  splashRadius: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  child: Text('${item.qty}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      notifier.addProduct(item.product),
                                  icon: const Icon(
                                      Icons.add_circle_outline,
                                      size: 24),
                                  color: AppColors.primary,
                                  splashRadius: 20,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // ── Summary Panel ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface2Dark,
              border: Border(top: BorderSide(color: AppColors.borderDark)),
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
                  const SizedBox(height: 8),
                  if (cartState.discountAmount > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('Diskon',
                                style: TextStyle(
                                    color: AppColors.textMutedDark)),
                            const SizedBox(width: 4),
                            if (cartState.discountType ==
                                DiscountType.percent)
                              Text(
                                '${cartState.discount.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                    color: AppColors.textMutedDark,
                                    fontSize: 12),
                              ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '- ${CurrencyFormatter.format(cartState.discountAmount)}',
                              style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => _openDiscount(context, ref),
                              child: const Icon(Icons.edit,
                                  size: 14,
                                  color: AppColors.textMutedDark),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ] else ...[
                    TextButton.icon(
                      onPressed: cartState.items.isEmpty
                          ? null
                          : () => _openDiscount(context, ref),
                      icon: const Icon(Icons.local_offer_outlined, size: 16),
                      label: const Text('Tambah Diskon'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 32),
                          tapTargetSize:
                              MaterialTapTargetSize.shrinkWrap),
                    ),
                  ],
                ],

                // ── Pajak ────────────────────────────────────────────
                if (taxEnabled && cartState.taxAmount > 0) ...[
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label:
                        'Pajak (${cartState.taxRate.toStringAsFixed(0)}%)',
                    value: CurrencyFormatter.format(cartState.taxAmount),
                    valueColor: Colors.orangeAccent,
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(color: AppColors.borderDark, height: 1),
                const SizedBox(height: 12),

                // Grand Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total:',
                        style: Theme.of(context).textTheme.headlineMedium),
                    Text(
                      CurrencyFormatter.format(cartState.grandTotal),
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                AppButton(
                  text: 'Pembayaran',
                  isPrimary: true,
                  onPressed: cartState.items.isEmpty
                      ? null
                      : () async {
                          final result =
                              await showModalBottomSheet<bool>(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            builder: (_) => const CheckoutModal(),
                          );
                          if (result == true && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Pembayaran berhasil!')),
                            );
                          }
                        },
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
  final Color? valueColor;

  const _SummaryRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.textMutedDark)),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: valueColor)),
      ],
    );
  }
}
