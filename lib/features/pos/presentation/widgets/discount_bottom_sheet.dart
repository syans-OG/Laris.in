import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/currency_formatter.dart';
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
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const Text(
              'Tambah Diskon',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

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
            const SizedBox(height: 16),

            // Input
            TextField(
              controller: _controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              decoration: InputDecoration(
                labelText:
                    _type == DiscountType.nominal ? 'Jumlah Diskon (Rp)' : 'Persentase Diskon (%)',
                hintText: _type == DiscountType.nominal ? '10000' : '10',
                prefixIcon: Icon(
                    _type == DiscountType.nominal ? Icons.money : Icons.percent),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixText: _type == DiscountType.percent ? '%' : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Preview
            if (_previewDiscount > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Potongan harga:',
                        style: TextStyle(color: Colors.green)),
                    Text(
                      '- ${CurrencyFormatter.format(_previewDiscount)}',
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Actions
            Row(
              children: [
                // Hapus diskon
                if (widget.currentDiscount > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.pop(context, const _DiscountResult.clear()),
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.redAccent),
                      label: const Text('Hapus',
                          style: TextStyle(color: Colors.redAccent)),
                    ),
                  ),
                if (widget.currentDiscount > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _isValid
                        ? () {
                            final val =
                                double.tryParse(_controller.text) ?? 0.0;
                            Navigator.pop(
                                context, _DiscountResult.set(val, _type));
                          }
                        : null,
                    child: const Text('Terapkan'),
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
    final color = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
              color: isSelected ? color : Colors.grey[600]!, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? color : Colors.grey[400]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[400],
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
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
