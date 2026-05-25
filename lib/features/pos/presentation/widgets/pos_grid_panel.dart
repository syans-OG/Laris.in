import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = theme.colorScheme.surface;
    final elevatedSurfaceColor = theme.colorScheme.surfaceContainerHighest;
    final textColor = theme.colorScheme.onSurface;
    final mutedColor = theme.colorScheme.onSurfaceVariant;
    final borderColor = theme.colorScheme.outline.withOpacity(isDark ? 0.35 : 0.18);

    Future<void> handleBarcodeScanned(String barcode) async {
      if (barcode.isEmpty) return;
      final product = await ref.read(productsProvider.notifier).getProductByBarcode(barcode);
      if (!context.mounted) return;
      if (product != null) {
        if (product.stock > 0) {
          cartNotifier.addProduct(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${product.name} otomatis ditambahkan ke keranjang')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Stok ${product.name} kosong!')),
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
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: surfaceColor,
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
                Icon(Icons.search, color: mutedColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    onChanged: (val) {
                      ref.read(productsQueryProvider.notifier).state = val;
                    },
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      color: textColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      hintStyle: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: mutedColor.withOpacity(0.7),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      suffixIcon: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(Icons.qr_code_scanner, color: mutedColor, size: 20),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CameraScannerScreen(
                                onScan: (barcode) {
                                  handleBarcodeScanned(barcode);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
              height: 40,
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

                  return GestureDetector(
                    onTap: () {
                      ref.read(productsCategoryFilterProvider.notifier).state =
                          isSelected ? null : categoryId;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF006948) : elevatedSurfaceColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Center(
                        child: Text(
                          isAll ? 'Semua' : category!.name,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 13,
                            color: isSelected ? Colors.white : mutedColor,
                          ),
                        ),
                      ),
                    ),
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
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (err, _) => Center(child: Text('Error: $err', style: TextStyle(color: AppColors.error))),
            data: (products) {
              final filteredProducts = searchQuery.trim().isEmpty
                  ? products
                  : products.where((p) {
                      final q = searchQuery.trim().toLowerCase();
                      return p.name.toLowerCase().contains(q) ||
                             (p.barcode.isNotEmpty && p.barcode.contains(q));
                    }).toList();

              if (filteredProducts.isEmpty) {
                return Center(
                  child: Text(
                    'Tidak ada produk tersedia.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: mutedColor),
                  ),
                );
              }

              // Responsive Cross Axis Count
              return LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 2;
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
                        onTap: () {
                          if (product.stock > 0) {
                            cartNotifier.addProduct(product);
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
