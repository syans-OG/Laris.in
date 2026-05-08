import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_input.dart';
import '../models/cart_state.dart';

class DiscountBottomSheet extends ConsumerStatefulWidget {
  final double currentDiscount;
  final DiscountType currentType;
  final double subTotal;

  const DiscountBottomSheet({
    super.key,
    required this.currentDiscount,
    required this.currentType,
    required this.subTotal,
  });

  @override
  ConsumerState<DiscountBottomSheet> createState() =>
      _DiscountBottomSheetState();
}

class _DiscountBottomSheetState extends ConsumerState<DiscountBottomSheet> {
  late DiscountType _type;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _type = widget.currentType;
    _controller = TextEditingController(
      text: widget.currentDiscount > 0
          ? widget.currentDiscount.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _previewDiscount {
    final val = double.tryParse(_controller.text) ?? 0.0;
    if (_type == DiscountType.percent) {
      return (widget.subTotal * val / 100).clamp(0.0, widget.subTotal);
    }
    return val.clamp(0.0, widget.subTotal);
  }

  bool get _isValid {
    final val = double.tryParse(_controller.text) ?? 0.0;
    if (val <= 0) return false;
    if (_type == DiscountType.percent && val > 100) return false;
    if (_type == DiscountType.nominal && val > widget.subTotal) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text(
              'Tambah Diskon',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Toggle Rp / %
            Row(
              children: [
                Expanded(
                  child: _TypeButton(
                    label: 'Nominal (Rp)',
                    icon: Icons.attach_money,
                    isSelected: _type == DiscountType.nominal,
                    onTap: () => setState(() {
                      _type = DiscountType.nominal;
                      _controller.clear();
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeButton(
                    label: 'Persentase (%)',
                    icon: Icons.percent,
                    isSelected: _type == DiscountType.percent,
                    onTap: () => setState(() {
                      _type = DiscountType.percent;
                      _controller.clear();
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Input
            AppTextInput(
              label: _type == DiscountType.nominal ? 'Jumlah Diskon (Rp)' : 'Persentase Diskon (%)',
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              hint: _type == DiscountType.nominal ? '10000' : '10',
              prefixIcon: _type == DiscountType.nominal ? Icons.money : Icons.percent,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Preview
            if (_previewDiscount > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Potongan harga:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary)),
                    Text(
                      '- ${CurrencyFormatter.format(_previewDiscount)}',
                      style: AppTypography.displaySmall.copyWith(
                          color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),

            // Actions
            Row(
              children: [
                // Hapus diskon
                if (widget.currentDiscount > 0)
                  Expanded(
                    child: AppButton(
                      text: 'Hapus',
                      isPrimary: false,
                      onPressed: () =>
                          Navigator.pop(context, const _DiscountResult.clear()),
                    ),
                  ),
                if (widget.currentDiscount > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    text: 'Terapkan',
                    isPrimary: true,
                    onPressed: _isValid
                        ? () {
                            final val =
                                double.tryParse(_controller.text) ?? 0.0;
                            Navigator.pop(
                                context, _DiscountResult.set(val, _type));
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceLight,
          border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderLight, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? AppColors.primary : AppColors.textMutedLight),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textMutedLight,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Return value dari bottom sheet
class _DiscountResult {
  final bool cleared;
  final double? value;
  final DiscountType? type;

  const _DiscountResult.clear()
      : cleared = true,
        value = null,
        type = null;

  const _DiscountResult.set(double v, DiscountType t)
      : cleared = false,
        value = v,
        type = t;
}

// Helper function untuk dipanggil dari cart panel
Future<void> showDiscountBottomSheet({
  required BuildContext context,
  required double currentDiscount,
  required DiscountType currentType,
  required double subTotal,
  required void Function(double value, DiscountType type) onSet,
  required VoidCallback onClear,
}) async {
  final result = await showModalBottomSheet<_DiscountResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DiscountBottomSheet(
      currentDiscount: currentDiscount,
      currentType: currentType,
      subTotal: subTotal,
    ),
  );

  if (result == null) return;
  if (result.cleared) {
    onClear();
  } else {
    onSet(result.value!, result.type!);
  }
}
