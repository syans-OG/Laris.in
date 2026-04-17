import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_text_input.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/import_csv_bottom_sheet.dart';
import 'product_form_screen.dart';

class ProductManagementScreen extends ConsumerWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productsProvider);
    final categoriesState = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Produk'),
        actions: [
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
      ),
      body: Column(
        children: [
          // Search & Filter Section
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
          
          // Category Filter Horizontal List
          _buildCategoryFilter(ref, categoriesState),

          const SizedBox(height: 8),

          // Product Grid View
          Expanded(
            child: productsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: \$err')),
              data: (products) {
                if (products.isEmpty) {
                  return const Center(child: Text('Tidak ada produk ditemukan.'));
                }
                // Determine generic crossAxisCount based on screen width
                final screenWidth = MediaQuery.of(context).size.width;
                final crossAxisCount = screenWidth > 600 ? 4 : 2;

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductFormScreen(product: product),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(WidgetRef ref, AsyncValue categoriesState) {
    return categoriesState.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (categories) {
        if (categories.isEmpty) return const SizedBox.shrink();
        
        final selectedId = ref.watch(productsCategoryFilterProvider);
        
        return SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 1, // +1 for "Semua"
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final category = isAll ? null : categories[index - 1];
              final categoryId = category?.id;
              final isSelected = selectedId == categoryId;

              return ChoiceChip(
                label: Text(isAll ? 'Semua' : category!.name),
                selected: isSelected,
                onSelected: (selected) {
                  ref.read(productsCategoryFilterProvider.notifier).state = selected ? categoryId : null;
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
}
