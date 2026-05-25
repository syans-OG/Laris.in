import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/product_entity.dart';

class InventoryProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onTap;
  final VoidCallback onMoreOptionsTap;

  const InventoryProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onMoreOptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLowStock = product.stock <= product.lowStockThreshold;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = theme.colorScheme.surface;
    final elevatedSurfaceColor = theme.colorScheme.surfaceContainerHighest;
    final textColor = theme.colorScheme.onSurface;
    final mutedColor = theme.colorScheme.onSurfaceVariant;

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image (Reduced from 80 to 60)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: elevatedSurfaceColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildProductImage(product.imageUrl, mutedColor),
                ),
                const SizedBox(width: 12),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: 14, // Reduced from 16
                          height: 1.4,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${product.stock}',
                            style: TextStyle(
                              fontFamily: 'Space Mono',
                              fontWeight: FontWeight.bold,
                              fontSize: 16, // Reduced from 20
                              height: 1.4,
                              color: isLowStock ? const Color(0xFFBA1A1A) : const Color(0xFF006948),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'PCS',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w600,
                              fontSize: 10, // Reduced from 12
                              letterSpacing: 0.5,
                              color: mutedColor,
                            ),
                          ),
                          if (isLowStock) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0x1ABA1A1A), // 10% red
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'STOK MENIPIS',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9,
                                  letterSpacing: -0.2,
                                  color: Color(0xFFBA1A1A),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Options Button
                GestureDetector(
                  onTap: onMoreOptionsTap,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Center(
                      child: Icon(Icons.more_vert, color: mutedColor, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            if (isLowStock)
              Positioned(
                top: -12,
                left: -12,
                right: -12,
                child: Container(
                  height: 3,
                  decoration: const BoxDecoration(
                    color: Color(0x33BA1A1A), // 20% red
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
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
        child: Icon(Icons.inventory_2_outlined, size: 24, color: mutedColor),
      );
    }

    final isNetworkImage = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
    if (isNetworkImage) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(Icons.inventory_2_outlined, color: mutedColor, size: 24),
        ),
      );
    }

    final file = File(imageUrl);
    if (!file.existsSync()) {
      return Center(
        child: Icon(Icons.inventory_2_outlined, size: 24, color: mutedColor),
      );
    }

    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Center(
        child: Icon(Icons.inventory_2_outlined, color: mutedColor, size: 24),
      ),
    );
  }
}
