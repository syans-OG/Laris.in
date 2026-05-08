import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/pos_grid_panel.dart';
import '../widgets/pos_cart_panel.dart';
import '../providers/cart_provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/presentation/widgets/live_clock.dart';
import 'dart:ui';
class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FA),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 33, 20, 0.04),
                blurRadius: 12,
                offset: Offset(0, 4),
              )
            ]
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Laris.in',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: Color(0xFF059669),
                      letterSpacing: -0.5,
                    ),
                  ),
                  LiveClock(),
                  CircleAvatar(
                    radius: 16.5,
                    backgroundColor: Color(0xFFEDEEEF),
                    child: Icon(Icons.person, size: 20, color: AppColors.textMutedLight),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 600) {
            return Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: PosGridPanel(),
                ),
                const VerticalDivider(width: 1, thickness: 1, color: AppColors.borderLight),
                Expanded(
                  flex: 2,
                  child: const PosCartPanel(),
                ),
              ],
            );
          }

          return Consumer(
            builder: (context, ref, _) {
              final cartState = ref.watch(cartProvider);
              final isCartEmpty = cartState.items.isEmpty;

              return Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: isCartEmpty ? 0 : 72),
                    child: const PosGridPanel(),
                  ),
                  if (!isCartEmpty)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildCartBar(context, cartState, theme),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyCartBar() {
    return const SizedBox.shrink(); // Hide the bar completely when empty, per modern minimal design
  }

  Widget _buildCartBar(BuildContext context, dynamic cartState, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          isDismissible: true,
          enableDrag: true,
          barrierColor: Colors.black.withOpacity(0.5),
          builder: (sheetContext) {
            return Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => Navigator.of(sheetContext).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: const ColoredBox(color: Colors.transparent),
                  ),
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.6,
                  minChildSize: 0.4,
                  maxChildSize: 0.92,
                  snap: true,
                  snapSizes: const [0.6, 0.92],
                  builder: (_, scrollController) => GestureDetector(
                    onTap: () {},
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              margin: const EdgeInsets.only(top: 12, bottom: 8),
                              width: 48, height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.borderLight,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Expanded(
                            child: PosCartPanel(scrollController: scrollController),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color.fromRGBO(188, 202, 192, 0.05)),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 33, 20, 0.08),
              blurRadius: 16,
              offset: Offset(0, -8),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Row(
                children: [
                  // Icon Cart with Badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.shopping_basket_outlined, color: Color(0xFF006948)),
                      ),
                      Positioned(
                        top: -8,
                        right: -8,
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
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${cartState.totalQty}',
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
                  const SizedBox(width: 16),
                  // Total Texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total (${cartState.totalQty} items)',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Color(0xFF3D4A42),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.format(cartState.grandTotal),
                          style: AppTypography.displaySmall.copyWith(
                            color: const Color(0xFF191C1D),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF006948), Color(0xFF00855D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 105, 72, 0.2),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    child: const Text(
                      'BAYAR',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

