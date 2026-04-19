import 'package:flutter/material.dart';
import '../../domain/entities/cashier_entity.dart';

const _accent = Color(0xFF00E5A0);
const _textPrimary = Color(0xFFFFFFFF);
const _textSecondary = Color(0xFFBACBBF);

class CashierAvatar extends StatelessWidget {
  final CashierEntity cashier;
  final bool isSelected;
  final VoidCallback onTap;

  const CashierAvatar({
    super.key,
    required this.cashier,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? _accent : Colors.transparent,
                      width: isSelected ? 3 : 0,
                    ),
                    image: DecorationImage(
                      image: const AssetImage('assets/images/avatar_placeholder.png'), // Need fallback if no asset
                      fit: BoxFit.cover,
                      colorFilter: isSelected 
                        ? null 
                        : ColorFilter.mode(Colors.black.withValues(alpha: 0.4), BlendMode.darken),
                    ),
                  ),
                  child: cashier.avatarUrl == null 
                      ? Center(
                          child: Icon(
                            Icons.person,
                            size: 36,
                            color: isSelected ? _textPrimary : _textSecondary,
                          ),
                        )
                      : null,
                ),
                if (isSelected)
                  Container(
                    decoration: const BoxDecoration(
                      color: _accent,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.check,
                      color: Color(0xFF0E1015),
                      size: 14,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              cashier.name.split(' ').first, // Limit name length
              style: TextStyle(
                color: isSelected ? _textPrimary : _textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
