import 'package:flutter/material.dart';

class ProductFilterBottomSheet extends StatefulWidget {
  final String? currentSortBy;
  final void Function(String? sortBy) onApply;
  final VoidCallback onReset;

  const ProductFilterBottomSheet({
    super.key,
    this.currentSortBy,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<ProductFilterBottomSheet> createState() => _ProductFilterBottomSheetState();
}

class _ProductFilterBottomSheetState extends State<ProductFilterBottomSheet> {
  String? _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.currentSortBy;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 8, 24, bottomPad + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFDDE0DF),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter & Urutkan',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF191C1D),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSort = null;
                  });
                  widget.onReset();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Reset',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF006948),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Urutkan ──
          const Text(
            'Urutkan',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF6D7A72),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip(
                label: 'Nama: A ke Z',
                value: 'name_asc',
                groupValue: _selectedSort,
                onTap: (v) => setState(() => _selectedSort = _selectedSort == v ? null : v),
              ),
              _buildChip(
                label: 'Nama: Z ke A',
                value: 'name_desc',
                groupValue: _selectedSort,
                onTap: (v) => setState(() => _selectedSort = _selectedSort == v ? null : v),
              ),
              _buildChip(
                label: 'Harga: Termurah',
                value: 'price_asc',
                groupValue: _selectedSort,
                onTap: (v) => setState(() => _selectedSort = _selectedSort == v ? null : v),
              ),
              _buildChip(
                label: 'Harga: Termahal',
                value: 'price_desc',
                groupValue: _selectedSort,
                onTap: (v) => setState(() => _selectedSort = _selectedSort == v ? null : v),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_selectedSort);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006948),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Terapkan Filter',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required String value,
    required String? groupValue,
    required void Function(String) onTap,
  }) {
    final isSelected = groupValue == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F3EF) : const Color(0xFFF3F4F5),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? const Color(0xFF006948) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
            color: isSelected ? const Color(0xFF006948) : const Color(0xFF4A5550),
          ),
        ),
      ),
    );
  }
}
