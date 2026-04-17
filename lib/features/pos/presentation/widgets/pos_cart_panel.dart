import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/cart_provider.dart';
import 'checkout_modal.dart';

class PosCartPanel extends ConsumerWidget {
  final ScrollController? scrollController;

  const PosCartPanel({
    super.key,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);

    return Container(
      color: AppColors.surfaceDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Cart
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pesanan Saat Ini',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (cartState.items.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => notifier.clearCart(),
                    icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                    label: const Text('Kosongkan', style: TextStyle(color: AppColors.error)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderDark),

          // ListView of Items
          Expanded(
            child: cartState.items.isEmpty
                ? const Center(
                    child: Text('Keranjang Belanja Kosong', style: TextStyle(color: AppColors.textMutedDark)),
                  )
                : ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: cartState.items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
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
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    CurrencyFormatter.format(item.product.price),
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Qty Controller
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => notifier.decreaseQty(item.product),
                                  icon: const Icon(Icons.remove_circle_outline, size: 24),
                                  color: AppColors.textMutedDark,
                                  splashRadius: 20,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '${item.qty}',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => notifier.addProduct(item.product),
                                  icon: const Icon(Icons.add_circle_outline, size: 24),
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

          // Total Panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface2Dark,
              border: const Border(top: BorderSide(color: AppColors.borderDark)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Subtotal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:', style: TextStyle(color: AppColors.textMutedDark)),
                    Text(
                      CurrencyFormatter.format(cartState.subTotal),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                
                // Discount (User Decision: build but disable interactively for Sprint 1)
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('Diskon', style: TextStyle(color: AppColors.textMutedDark)),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: 'Tersedia di update berikutnya',
                          child: Icon(Icons.info_outline, size: 14, color: AppColors.textMutedDark.withOpacity(0.5)),
                        ),
                      ],
                    ),
                    Text(
                      '- Rp 0',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMutedDark.withOpacity(0.5),
                          ),
                    ),
                  ],
                ),
                
                // Note: Tax has been omitted entirely per Decision 03

                const SizedBox(height: 16),
                const Divider(color: AppColors.borderDark, height: 1),
                const SizedBox(height: 16),

                // Grand Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total:', style: Theme.of(context).textTheme.headlineMedium),
                    Text(
                      CurrencyFormatter.format(cartState.grandTotal),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                AppButton(
                  text: 'Pembayaran',
                  isPrimary: true,
                  onPressed: cartState.items.isEmpty
                      ? null // Standard flutter way to disable button if supported by AppButton
                      : () async {
                          final result = await showModalBottomSheet<bool>(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            builder: (_) => const CheckoutModal(),
                          );
                          if (result == true && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pembayaran berhasil!')),
                            );
                            // If this was a mobile bottom sheet cart, pop it too
                            if (Navigator.canPop(context)) {
                              // Navigator.pop(context); // Optional depending on exact mobile UX desired
                            }
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
}
