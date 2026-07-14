import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/inventory_product_card.dart';
import '../widgets/import_csv_bottom_sheet.dart';
import '../widgets/category_management_dialog.dart';
import '../widgets/stock_adjustment_dialog.dart';
import '../widgets/product_filter_bottom_sheet.dart';
import 'product_form_screen.dart';

class ProductManagementScreen extends ConsumerStatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  ConsumerState<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends ConsumerState<ProductManagementScreen> {
  int _activeTab = 0; // 0: Semua Stok, 1: Stok Menipis, 2: Riwayat Masuk

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Produk',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                _buildTabs(),
                if (_activeTab != 2) ...[
                  _buildSearchAndFilter(),
                  _buildCategoryChips(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: const EdgeInsets.only(bottom: 100),
                      child: _activeTab == 0 ? _buildAllProducts() : _buildLowStockProducts(),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: const EdgeInsets.only(bottom: 100),
                      child: _buildStockHistory(),
                    ),
                  ),
                ],
              ],
            ),
            _buildFAB(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(child: _buildTabItem(0, 'Semua Stok')),
            Expanded(child: _buildTabItem(1, 'Menipis')),
            Expanded(child: _buildTabItem(2, 'Riwayat')),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    final theme = Theme.of(context);
    final isActive = _activeTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
              color: isActive ? AppColors.primary : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = theme.colorScheme.outline.withOpacity(isDark ? 0.35 : 0.18);
    final sortBy = ref.watch(productsSortByProvider);
    final isFilterActive = sortBy != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? const Color.fromRGBO(0, 0, 0, 0.14) : const Color.fromRGBO(0, 0, 0, 0.03),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      onChanged: (val) {
                        ref.read(productsQueryProvider.notifier).state = val;
                      },
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cari nama barang atau SKU...',
                        hintStyle: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.75),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _showFilterBottomSheet(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isFilterActive ? AppColors.primary : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: isFilterActive ? null : Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? const Color.fromRGBO(0, 0, 0, 0.14) : const Color.fromRGBO(0, 0, 0, 0.03),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.tune, 
                  color: isFilterActive ? Colors.white : theme.colorScheme.onSurfaceVariant, 
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductFilterBottomSheet(
        currentSortBy: ref.read(productsSortByProvider),
        onApply: (sortBy) {
          ref.read(productsSortByProvider.notifier).state = sortBy;
        },
        onReset: () {
          ref.read(productsSortByProvider.notifier).state = null;
        },
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categoriesState = ref.watch(categoriesProvider);

    return categoriesState.when(
      loading: () => const SizedBox(height: 60),
      error: (_, __) => const SizedBox(height: 60),
      data: (categories) {
        final selectedId = ref.watch(productsCategoryFilterProvider);

        return Container(
          height: 56,
          padding: const EdgeInsets.only(top: 16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildFilterChip(
                label: 'Semua',
                isSelected: selectedId == null,
                onTap: () {
                  ref.read(productsCategoryFilterProvider.notifier).state = null;
                },
              ),
              const SizedBox(width: 8),
              ...categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(
                    label: category.name,
                    isSelected: selectedId == category.id,
                    onTap: () {
                      ref.read(productsCategoryFilterProvider.notifier).state = category.id;
                    },
                  ),
                );
              }),
              _buildCustomFilterChip(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF006948) : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
              color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomFilterChip() {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _showCategoryManagement(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_outlined, size: 14, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              'Custom',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllProducts() {
    final theme = Theme.of(context);
    final productsState = ref.watch(productsProvider);
    return productsState.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.all(32),
        child: Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
      ),
      data: (products) {
        if (products.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text('Tidak ada produk.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          itemCount: products.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final product = products[index];
            return InventoryProductCard(
              product: product,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
                );
              },
              onMoreOptionsTap: () => _showStockAdjustment(context, product),
            );
          },
        );
      },
    );
  }

  Widget _buildLowStockProducts() {
    final theme = Theme.of(context);
    final lowStockState = ref.watch(lowStockProductsProvider);
    return lowStockState.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.all(32),
        child: Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
      ),
      data: (products) {
        if (products.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Stok aman! Tidak ada yang menipis.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          itemCount: products.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final product = products[index];
            return InventoryProductCard(
              product: product,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
                );
              },
              onMoreOptionsTap: () => _showStockAdjustment(context, product),
            );
          },
        );
      },
    );
  }

  Widget _buildStockHistory() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = theme.colorScheme.outline.withOpacity(isDark ? 0.35 : 0.18);
    final logsState = ref.watch(stockLogsProvider);

    return logsState.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.all(32),
        child: Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
      ),
      data: (logs) {
        if (logs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text('Belum ada riwayat stok.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            ),
          );
        }
        return Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: isDark ? const Color.fromRGBO(0, 0, 0, 0.16) : const Color(0x0D000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: logs.length,
            separatorBuilder: (_, __) => Divider(color: borderColor, height: 1),
            itemBuilder: (context, index) {
              final log = logs[index];
              final isPositive = log.qtyChange > 0;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isPositive ? const Color(0x1A059669) : const Color(0x1ABA1A1A),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPositive ? Icons.add : Icons.remove,
                        color: isPositive ? const Color(0xFF059669) : const Color(0xFFBA1A1A),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.productName,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${log.type.toUpperCase()} • ${log.createdAt.toString().split('.')[0]}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (log.note != null && log.note!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              log.note!,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isPositive ? '+' : ''}${log.qtyChange}',
                          style: TextStyle(
                            fontFamily: 'Space Mono',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isPositive ? const Color(0xFF059669) : const Color(0xFFBA1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: ${log.totalAfter}',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Positioned(
      bottom: 24, // adjust to stay above BottomNavBar handled by MasterLayout
      right: 24,
      child: PopupMenuButton<String>(
        position: PopupMenuPosition.over,
        offset: const Offset(0, -120),
        onSelected: (value) {
          if (value == 'manual') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductFormScreen()),
            );
          } else if (value == 'import') {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const ImportCsvBottomSheet(),
            );
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'manual',
            child: Row(
              children: [
                Icon(Icons.edit_note_rounded, size: 20, color: Color(0xFF3D4A42)),
                SizedBox(width: 12),
                Text('Tambah Manual', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14)),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'import',
            child: Row(
              children: [
                Icon(Icons.file_download_outlined, size: 20, color: Color(0xFF3D4A42)),
                SizedBox(width: 12),
                Text('Import dari CSV', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14)),
              ],
            ),
          ),
        ],
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF006948),
                Color(0xFF00855D),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 105, 72, 0.3),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.add, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  void _showCategoryManagement(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const CategoryManagementDialog(),
    );
  }

  void _showStockAdjustment(BuildContext context, dynamic product) {
    showDialog(
      context: context,
      builder: (_) => StockAdjustmentDialog(product: product),
    );
  }
}
