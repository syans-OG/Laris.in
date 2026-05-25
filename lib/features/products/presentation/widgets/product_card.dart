import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/product_entity.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../pos/presentation/providers/cart_provider.dart';

class ProductCard extends ConsumerWidget {
  final ProductEntity product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = theme.colorScheme.surface;
    final elevatedSurfaceColor = theme.colorScheme.surfaceContainerHighest;
    final textColor = theme.colorScheme.onSurface;
    final mutedColor = theme.colorScheme.onSurfaceVariant;

    final cartState = ref.watch(cartProvider);
    final cartItem = cartState.items.cast<dynamic?>().firstWhere(
      (item) => item?.product.id == product.id, 
      orElse: () => null
    );
    final int qtyInCart = cartItem?.qty ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(isDark ? 0.28 : 0.08)),
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color.fromRGBO(0, 0, 0, 0.18) : const Color.fromRGBO(0, 33, 20, 0.03),
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: elevatedSurfaceColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildProductImage(product.imageUrl, mutedColor),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1.25,
                          color: textColor,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              CurrencyFormatter.format(product.price),
                              style: AppTypography.displaySmall.copyWith(
                                color: const Color(0xFF006948),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: qtyInCart > 0 ? const Color(0xFF00855D) : elevatedSurfaceColor,
                              shape: BoxShape.circle,
                              boxShadow: qtyInCart > 0 ? const [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.05),
                                  blurRadius: 1,
                                  offset: Offset(0, 1),
                                )
                              ] : null,
                            ),
                            child: Icon(
                              Icons.add,
                              size: 16,
                              color: qtyInCart > 0 ? Colors.white : textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (qtyInCart > 0)
              Positioned(
                top: -8,
                left: -8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFFBA1A1A),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.05),
                        blurRadius: 1,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$qtyInCart',
                      style: AppTypography.displaySmall.copyWith(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String? imageUrl, Color mutedColor) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Center(
        child: Icon(Icons.inventory_2_outlined, size: 40, color: mutedColor),
      );
    }

    final isNetworkImage = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
    if (isNetworkImage) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(Icons.inventory_2_outlined, color: mutedColor),
        ),
      );
    }

    final file = File(imageUrl);
    if (!file.existsSync()) {
      return Center(
        child: Icon(Icons.inventory_2_outlined, size: 40, color: mutedColor),
      );
    }

    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Center(
        child: Icon(Icons.inventory_2_outlined, color: mutedColor),
      ),
    );
  }
}
