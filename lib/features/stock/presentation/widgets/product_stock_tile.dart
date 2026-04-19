import 'package:flutter/material.dart';
import '../../../products/domain/entities/product_entity.dart';

const _surface = Color(0xFF1C1E26);
const _textPrimary = Color(0xFFFFFFFF);
const _textSecondary = Color(0xFFBACBBF);
const _accent = Color(0xFF00E5A0);
const _lowStock = Color(0xFFFFB4AB);

class ProductStockTile extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onAdjust;

  const ProductStockTile({
    super.key,
    required this.product,
    required this.onAdjust,
  });

  @override
  Widget build(BuildContext context) {
    final isLow = product.stock <= 5;
    final initials = product.name.isNotEmpty
        ? product.name.substring(0, 1).toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Avatar initial
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isLow
                  ? _lowStock.withValues(alpha: 0.15)
                  : _accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                color: isLow ? _lowStock : _accent,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name & barcode
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  product.barcode,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Stock & adjust button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${product.stock}',
                style: TextStyle(
                  color: isLow ? _lowStock : _textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 4),
              OutlinedButton(
                onPressed: onAdjust,
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: BorderSide(
                    color: isLow ? _lowStock : _accent,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'Sesuaikan',
                  style: TextStyle(
                    color: isLow ? _lowStock : _accent,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
