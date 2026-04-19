import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../providers/stock_controller.dart';

const _surface2 = Color(0xFF191B22);
const _textPrimary = Color(0xFFFFFFFF);
const _textSecondary = Color(0xFFBACBBF);
const _textMuted = Color(0xFF84958A);
const _accent = Color(0xFF00E5A0);
const _lowStock = Color(0xFFFFB4AB);

final _reasons = ['Barang Masuk', 'Rusak/Basi', 'Hilang', 'Koreksi'];

class StockAdjustmentBottomSheet extends ConsumerStatefulWidget {
  final ProductEntity product;

  const StockAdjustmentBottomSheet({super.key, required this.product});

  @override
  ConsumerState<StockAdjustmentBottomSheet> createState() =>
      _StockAdjustmentBottomSheetState();
}

class _StockAdjustmentBottomSheetState
    extends ConsumerState<StockAdjustmentBottomSheet> {
  bool _isAddition = true;
  String _selectedReason = _reasons.first;
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jumlah yang valid')),
      );
      return;
    }

    ref.read(stockControllerProvider).adjustStock(
          productId: widget.product.id,
          amount: amount,
          reason: _selectedReason,
          isAddition: _isAddition,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isLow = widget.product.stock <= 5;

    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: _surface2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Product info
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isLow
                      ? _lowStock.withValues(alpha: 0.15)
                      : _accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.product.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: isLow ? _lowStock : _accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product.name,
                      style: const TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  Text('Stok saat ini: ${widget.product.stock}',
                      style: const TextStyle(
                          color: _textSecondary, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Toggle tambah/kurang
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0E1015),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _buildToggle('Tambah Stok (+)', true),
                _buildToggle('Kurangi Stok (-)', false),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Jumlah
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: _textPrimary),
            decoration: InputDecoration(
              labelText: 'Jumlah',
              labelStyle: const TextStyle(color: _textMuted),
              filled: true,
              fillColor: const Color(0xFF0E1015),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _accent),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Alasan
          DropdownButtonFormField<String>(
            value: _selectedReason,
            dropdownColor: const Color(0xFF1C1E26),
            style: const TextStyle(color: _textPrimary),
            decoration: InputDecoration(
              labelText: 'Alasan',
              labelStyle: const TextStyle(color: _textMuted),
              filled: true,
              fillColor: const Color(0xFF0E1015),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            items: _reasons
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedReason = val);
            },
          ),
          const SizedBox(height: 24),

          // Save button
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: const Color(0xFF0E1015),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Simpan Perubahan',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool value) {
    final isSelected = _isAddition == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isAddition = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? _accent : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF0E1015) : _textMuted,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
