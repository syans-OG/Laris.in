import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/pos_grid_panel.dart';
import '../widgets/pos_cart_panel.dart';
import '../providers/cart_provider.dart';
import '../../../../core/utils/currency_formatter.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laris.in'),
        centerTitle: false,
        actions: [
          // Top bar placeholder based on User Decision 01 "Default Admin"
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, size: 18, color: AppColors.black),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Admin',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // If screen width >= 600px, show horizontal split pane (Tablet/Desktop)
          if (constraints.maxWidth >= 600) {
            return Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: PosGridPanel(), // 60% left space
                ),
                const VerticalDivider(width: 1, thickness: 1, color: AppColors.borderDark),
                Expanded(
                  flex: 2,
                  child: const PosCartPanel(), // 40% right space
                ),
              ],
            );
          }

          return Stack(
            children: [
              // Produk grid dengan padding bottom agar tidak tertutup bottom bar
              const Padding(
                padding: EdgeInsets.only(bottom: 72),
                child: PosGridPanel(),
              ),

              // Persistent bottom bar selalu di bawah
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Consumer(
                  builder: (context, ref, _) {
                    final cartState = ref.watch(cartProvider);
                    if (cartState.items.isEmpty) {
                      return _buildEmptyCartBar();
                    }
                    return _buildCartBar(context, cartState);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCartBar() {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Color(0xFF181C27),
        border: Border(top: BorderSide(color: Color(0xFF2A2F45))),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, color: Color(0xFF6B7280), size: 20),
          SizedBox(width: 8),
          Text(
            'Keranjang kosong',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCartBar(BuildContext context, dynamic cartState) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          isDismissible: true,
          enableDrag: true,
          barrierColor: Colors.black.withOpacity(0.5),
          builder: (sheetContext) {
            return Stack(
              children: [
                // ── Area luar sheet: tap untuk dismiss ──
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => Navigator.of(sheetContext).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: const ColoredBox(
                      color: Colors.transparent,
                    ),
                  ),
                ),

                // ── Sheet content ──
                DraggableScrollableSheet(
                  initialChildSize: 0.6,
                  minChildSize: 0.4,
                  maxChildSize: 0.92,
                  snap: true,
                  snapSizes: const [0.6, 0.92],
                  builder: (_, scrollController) => GestureDetector(
                    // Cegah tap di dalam sheet ter-forward ke barrier di atas
                    onTap: () {},
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF181C27),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Drag handle
                          Center(
                            child: Container(
                              margin: const EdgeInsets.only(top: 12, bottom: 8),
                              width: 40, height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2F45),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          // Cart content
                          Expanded(
                            child: PosCartPanel(scrollController: scrollController),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: Color(0xFF181C27),
          border: Border(top: BorderSide(color: Color(0xFF2A2F45))),
        ),
        child: Row(
          children: [
            // Badge jumlah item
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5A0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${cartState.totalQty} item', // cartState.totalQty digunakan agar konsisten
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Label
            const Text('Lihat keranjang', style: TextStyle(color: Colors.white, fontSize: 14)),
            const Spacer(),
            // Total
            Text(
              CurrencyFormatter.format(cartState.grandTotal),
              style: const TextStyle(
                color: Color(0xFF00E5A0),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'SpaceMono',
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_up, color: Color(0xFF00E5A0)),
          ],
        ),
      ),
    );
  }
}
