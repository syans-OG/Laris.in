import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/stock_controller.dart';
import '../widgets/product_stock_tile.dart';
import '../widgets/stock_adjustment_bottom_sheet.dart';

const _background = Color(0xFF0E1015);
const _accent = Color(0xFF00E5A0);
const _lowStock = Color(0xFFFFB4AB);
const _textPrimary = Color(0xFFFFFFFF);
const _textMuted = Color(0xFF84958A);
const _textSecondary = Color(0xFFBACBBF);

class StockManagementScreen extends ConsumerWidget {
  final bool hideAppBar;
  const StockManagementScreen({super.key, this.hideAppBar = false});

  void _showAdjustSheet(BuildContext context, product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StockAdjustmentBottomSheet(product: product),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(stockControllerProvider);

    final tabBar = TabBar(
      labelColor: _accent,
      unselectedLabelColor: _textMuted,
      indicatorColor: _accent,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      tabs: [
        const Tab(text: 'Semua Stok'),
        Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Menipis'),
              if (controller.lowStockProducts.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: _lowStock,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${controller.lowStockProducts.length}',
                    style: const TextStyle(
                        color: Color(0xFF0E1015),
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
        const Tab(text: 'Riwayat'),
      ],
    );

    final tabBarView = controller.isLoading
        ? const Center(child: CircularProgressIndicator(color: _accent))
        : TabBarView(
            children: [
              // Tab 1: Semua Stok
              RefreshIndicator(
                color: _accent,
                onRefresh: controller.loadProducts,
                child: controller.allProducts.isEmpty
                    ? _emptyState('Belum ada produk')
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: controller.allProducts.length,
                        itemBuilder: (ctx, i) {
                          final p = controller.allProducts[i];
                          return ProductStockTile(
                            product: p,
                            onAdjust: () => _showAdjustSheet(ctx, p),
                          );
                        },
                      ),
              ),

              // Tab 2: Menipis
              controller.lowStockProducts.isEmpty
                  ? _emptyState('Semua stok aman 🎉', icon: Icons.check_circle_outline)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: controller.lowStockProducts.length,
                      itemBuilder: (ctx, i) {
                        final p = controller.lowStockProducts[i];
                        return ProductStockTile(
                          product: p,
                          onAdjust: () => _showAdjustSheet(ctx, p),
                        );
                      },
                    ),

              // Tab 3: Riwayat
              controller.history.isEmpty
                  ? _emptyState('Belum ada riwayat penyesuaian')
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: controller.history.length,
                      itemBuilder: (_, i) {
                        final h = controller.history[i];
                        final isPlus = h.isAddition;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: isPlus
                                ? _accent.withValues(alpha: 0.12)
                                : _lowStock.withValues(alpha: 0.12),
                            child: Icon(
                              isPlus ? Icons.add : Icons.remove,
                              color: isPlus ? _accent : _lowStock,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            h.productName,
                            style: const TextStyle(
                                color: _textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(h.reason,
                                  style: const TextStyle(color: _textSecondary, fontSize: 11)),
                              Text(
                                DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(h.createdAt),
                                style: const TextStyle(color: _textMuted, fontSize: 10),
                              ),
                            ],
                          ),
                          trailing: Text(
                            '${isPlus ? '+' : ''}${h.change}',
                            style: TextStyle(
                              color: isPlus ? _accent : _lowStock,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        );
                      },
                    ),
            ],
          );

    // When embedded (hideAppBar = true), wrap with own DefaultTabController
    // and return Column with TabBar + Expanded body
    if (hideAppBar) {
      return DefaultTabController(
        length: 3,
        child: Column(
          children: [
            tabBar,
            Expanded(child: tabBarView),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          title: const Text('Manajemen Stok'),
          backgroundColor: _background,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(stockControllerProvider).loadProducts(),
            ),
          ],
          bottom: tabBar,
        ),
        body: tabBarView,
      ),
    );
  }

  Widget _emptyState(String message, {IconData icon = Icons.inventory_2_outlined}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: _textMuted),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: _textMuted, fontSize: 14)),
        ],
      ),
    );
  }
}
