import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_text_input.dart';
import '../../../products/presentation/providers/category_provider.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../providers/cart_provider.dart';
import '../providers/scanner_provider.dart';
import '../screens/camera_scanner_screen.dart';
import '../../../../core/theme/app_theme.dart';

class PosGridPanel extends ConsumerWidget {
  const PosGridPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productsProvider);
    final categoriesState = ref.watch(categoriesProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final searchQuery = ref.watch(productsQueryProvider);

    Future<void> handleBarcodeScanned(String barcode) async {
      if (barcode.isEmpty) return;
      final product = await ref.read(productsProvider.notifier).getProductByBarcode(barcode);
      if (!context.mounted) return;
      if (product != null) {
        if (product.stock > 0) {
          cartNotifier.addProduct(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('\${product.name} otomatis ditambahkan ke keranjang')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Stok \${product.name} kosong!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk dengan barcode tersebut tidak ditemukan')),
        );
      }
    }

    // Global USB Barcode Scanner Listener
    ref.listen<AsyncValue<String>>(barcodeStreamProvider, (previous, next) {
      final barcode = next.valueOrNull;
      if (barcode != null) {
        handleBarcodeScanned(barcode);
      }
    });

    return Column(
      children: [
        // Top Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: AppTextInput(
            label: 'Cari Produk',
            hint: 'Ketik nama...',
            prefixIcon: Icons.search,
            suffixIcon: Icons.qr_code_scanner,
            onSuffixTap: () async {
              // Open Camera Scanner
              final result = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (_) => const CameraScannerScreen()),
              );
              if (result != null) {
                handleBarcodeScanned(result);
              }
            },
            onChanged: (val) {
              ref.read(productsQueryProvider.notifier).state = val;
            },
          ),
        ),

        // Category Horizontal Strip
        categoriesState.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (categories) {
            if (categories.isEmpty) return const SizedBox.shrink();

            final selectedId = ref.watch(productsCategoryFilterProvider);

            return SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isAll = index == 0;
                  final category = isAll ? null : categories[index - 1];
                  final categoryId = category?.id;
                  final isSelected = selectedId == categoryId;

                  return ChoiceChip(
                    label: Text(isAll ? 'Semua Kategori' : category!.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      ref.read(productsCategoryFilterProvider.notifier).state =
                          selected ? categoryId : null;
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface2Dark,
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 8),

        // Main Product Grid
        Expanded(
          child: productsState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (products) {
              final filteredProducts = searchQuery.trim().isEmpty
                  ? products
                  : products.where((p) {
                      final q = searchQuery.trim().toLowerCase();
                      return p.name.toLowerCase().contains(q) ||
                             (p.barcode.isNotEmpty && p.barcode.contains(q));
                    }).toList();

              if (filteredProducts.isEmpty) {
                return const Center(child: Text('Tidak ada produk tersedia.'));
              }

              // Responsive Cross Axis Count
              return LayoutBuilder(
                builder: (context, constraints) {
                  // Determine columns dynamically on the allocated panel width
                  int crossAxisCount = 2; // Mobile small
                  if (constraints.maxWidth > 800) {
                    crossAxisCount = 4;
                  } else if (constraints.maxWidth > 500) {
                    crossAxisCount = 3;
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ProductCard(
                        product: product,
                        // Override default edit onTap context
                        onTap: () {
                          if (product.stock > 0) {
                            cartNotifier.addProduct(product);
                            // Optional: SnackBar feedback for adding to cart disabled 
                            // as it triggers too often on fast taps.
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Stok habis!')),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
