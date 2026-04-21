import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_text_input.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/import_csv_bottom_sheet.dart';
import '../widgets/category_management_dialog.dart';
import '../widgets/stock_adjustment_dialog.dart';
import 'product_form_screen.dart';

class ProductManagementScreen extends ConsumerWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manajemen Produk & Stok'),
          actions: [
            IconButton(
              icon: const Icon(Icons.category_outlined),
              onPressed: () => _showCategoryManagement(context),
              tooltip: 'Kelola Kategori',
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.add_circle_outline_rounded),
              position: PopupMenuPosition.under,
              tooltip: 'Tambah Produk',
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
                      Icon(Icons.edit_note_rounded, size: 20),
                      SizedBox(width: 12),
                      Text('Tambah Manual'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'import',
                  child: Row(
                    children: [
                      Icon(Icons.file_download_outlined, size: 20),
                      SizedBox(width: 12),
                      Text('Import dari CSV'),
                    ],
                  ),
                ),
              ],
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Semua Produk'),
              Tab(text: 'Stok Menipis'),
              Tab(text: 'Riwayat Stok'),
            ],
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
          ),
        ),
        body: TabBarView(
          children: [
            _buildAllProductsTab(context, ref),
            _buildLowStockTab(context, ref),
            _buildStockHistoryTab(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildAllProductsTab(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productsProvider);
    final categoriesState = ref.watch(categoriesProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: AppTextInput(
            label: 'Cari Produk',
            hint: 'Nama atau Barcode',
            prefixIcon: Icons.search,
            onChanged: (val) {
              ref.read(productsQueryProvider.notifier).state = val;
            },
          ),
        ),
        _buildCategoryFilter(ref, categoriesState, context),
        const SizedBox(height: 8),
        Expanded(
          child: productsState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (products) => _buildProductGrid(context, ref, products),
          ),
        ),
      ],
    );
  }

  Widget _buildLowStockTab(BuildContext context, WidgetRef ref) {
    final lowStockState = ref.watch(lowStockProductsProvider);

    return lowStockState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (products) {
        if (products.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: AppColors.primary),
                SizedBox(height: 16),
                Text('Stok aman! Tidak ada yang menipis.'),
              ],
            ),
          );
        }
        return _buildProductGrid(context, ref, products);
      },
    );
  }

  Widget _buildStockHistoryTab(BuildContext context, WidgetRef ref) {
    final logsState = ref.watch(stockLogsProvider);

    return logsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (logs) {
        if (logs.isEmpty) {
          return const Center(child: Text('Belum ada riwayat stok.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          separatorBuilder: (_, __) => const Divider(color: AppColors.borderDark),
          itemBuilder: (context, index) {
            final log = logs[index];
            final isPositive = log.qtyChange > 0;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPositive ? Icons.add : Icons.remove,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
              title: Text(log.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${log.type.toUpperCase()} • ${log.createdAt.toString().split('.')[0]}'),
                  if (log.note != null) Text(log.note!, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isPositive ? '+' : ''}${log.qtyChange}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isPositive ? Colors.green : Colors.red,
                      fontSize: 16,
                    ),
                  ),
                  Text('Total: ${log.totalAfter}', style: const TextStyle(fontSize: 11)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductGrid(BuildContext context, WidgetRef ref, List<dynamic> products) {
    if (products.isEmpty) {
      return const Center(child: Text('Tidak ada produk.'));
    }
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 4 : 2;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Stack(
          children: [
            ProductCard(
              product: product,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductFormScreen(product: product),
                  ),
                );
              },
            ),
            Positioned(
              top: 4, right: 4,
              child: IconButton.filledTonal(
                icon: const Icon(Icons.add_business, size: 18),
                onPressed: () => _showStockAdjustment(context, product),
                tooltip: 'Update Stok',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryFilter(WidgetRef ref, AsyncValue categoriesState, BuildContext context) {
    return categoriesState.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (categories) {
        final selectedId = ref.watch(productsCategoryFilterProvider);
        
        return SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 2, // +1 for "Semua", +1 for "+"
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                final isSelected = selectedId == null;
                return ChoiceChip(
                  label: const Text('Semua'),
                  selected: isSelected,
                  onSelected: (selected) {
                    ref.read(productsCategoryFilterProvider.notifier).state = null;
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface2Dark,
                );
              }
              
              if (index == categories.length + 1) {
                return ActionChip(
                  avatar: const Icon(Icons.add, size: 16),
                  label: const Text('Kategori'),
                  onPressed: () => _showCategoryManagement(context),
                  backgroundColor: AppColors.surface2Dark,
                );
              }

              final category = categories[index - 1];
              final isSelected = selectedId == category.id;

              return ChoiceChip(
                label: Text(category.name),
                selected: isSelected,
                onSelected: (selected) {
                  ref.read(productsCategoryFilterProvider.notifier).state = selected ? category.id : null;
                },
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface2Dark,
              );
            },
          ),
        );
      },
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

