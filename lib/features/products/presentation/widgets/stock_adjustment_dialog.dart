import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/product_provider.dart';

class StockAdjustmentDialog extends ConsumerStatefulWidget {
  final ProductEntity product;
  const StockAdjustmentDialog({super.key, required this.product});

  @override
  ConsumerState<StockAdjustmentDialog> createState() => _StockAdjustmentDialogState();
}

class _StockAdjustmentDialogState extends ConsumerState<StockAdjustmentDialog> {
  final _qtyController = TextEditingController(text: '1');
  bool _isAddition = true; // true = masuk, false = keluar
  bool _isLoading = false;

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final qty = int.tryParse(_qtyController.text) ?? 0;
    if (qty <= 0) return;

    setState(() => _isLoading = true);
    try {
      final change = _isAddition ? qty : -qty;
      
      await ref.read(productsProvider.notifier).updateStock(
        widget.product.id,
        change,
        type: _isAddition ? 'masuk' : 'keluar',
        note: 'Penyesuaian cepat',
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Stok'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Stok saat ini: ${widget.product.stock}', style: const TextStyle(fontSize: 13, color: AppColors.textMutedDark)),
          const SizedBox(height: 16),
          
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Stok Masuk'), icon: Icon(Icons.add_circle_outline)),
              ButtonSegment(value: false, label: Text('Stok Keluar'), icon: Icon(Icons.remove_circle_outline)),
            ],
            selected: {_isAddition},
            onSelectionChanged: (val) => setState(() => _isAddition = val.first),
          ),
          
          const SizedBox(height: 16),
          TextField(
            controller: _qtyController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Jumlah',
              filled: true,
            ),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Simpan'),
        ),
      ],
    );
  }
}
