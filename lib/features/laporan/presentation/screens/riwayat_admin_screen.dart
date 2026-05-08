import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/entities/cashier_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../history/presentation/screens/history_screen.dart';

const _background = Color(0xFFF8F9FA);
const _accent = Color(0xFF006948);
const _textMuted = Color(0xFF6D7A72);
const _textPrimary = Color(0xFF191C1D);

class RiwayatAdminScreen extends ConsumerStatefulWidget {
  const RiwayatAdminScreen({super.key});

  @override
  ConsumerState<RiwayatAdminScreen> createState() => _RiwayatAdminScreenState();
}

class _RiwayatAdminScreenState extends ConsumerState<RiwayatAdminScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil semua kasir aktif dari authRepositoryProvider
    final cashiersFuture = ref.watch(_allCashiersProvider);

    return cashiersFuture.when(
      loading: () => const Center(child: CircularProgressIndicator(color: _accent)),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (cashiers) {
        if (cashiers.isEmpty) {
          return const Center(
            child: Text('Tidak ada kasir terdaftar', style: TextStyle(color: _textMuted)),
          );
        }

        final List<String> tabLabels = ['Semua', ...cashiers.map((c) => c.name)];
        final views = <Widget>[
          const HistoryScreen(hideAppBar: true, cashierId: null),
          ...cashiers.map((c) => HistoryScreen(hideAppBar: true, cashierId: c.id)),
        ];

        return Column(
          children: [
            // Custom Chip Tabs (Matching SalesReportScreen style)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              color: _background,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: List.generate(tabLabels.length, (index) {
                    final isActive = _selectedIndex == index;
                    return GestureDetector(
                      onTap: () => _onTabTapped(index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? _accent.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive ? _accent.withOpacity(0.3) : const Color(0xFFD3D5D4),
                          ),
                        ),
                        child: Text(
                          tabLabels[index],
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            color: isActive ? _accent : _textMuted,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _selectedIndex = index);
                },
                children: views,
              ),
            ),
          ],
        );
      },
    );
  }
}

// Provider lokal untuk ambil semua kasir
final _allCashiersProvider = FutureProvider<List<CashierEntity>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.getActiveCashiers();
});
