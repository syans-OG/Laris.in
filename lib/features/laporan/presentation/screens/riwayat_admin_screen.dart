import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/entities/cashier_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../history/presentation/screens/history_screen.dart';

const _background = Color(0xFF0E1015);
const _accent = Color(0xFF00E5A0);
const _textMuted = Color(0xFF84958A);
const _surface = Color(0xFF1C1E26);
const _textPrimary = Color(0xFFFFFFFF);

class RiwayatAdminScreen extends ConsumerWidget {
  const RiwayatAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ambil semua kasir aktif dari authRepositoryProvider
    final cashiersFuture = ref.watch(_allCashiersProvider);

    return cashiersFuture.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: _accent)),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (cashiers) {
        if (cashiers.isEmpty) {
          return const Center(
            child: Text('Tidak ada kasir terdaftar',
                style: TextStyle(color: _textMuted)),
          );
        }

        // Tab: Semua + satu tab per kasir
        final tabs = <Tab>[
          const Tab(text: 'Semua'),
          ...cashiers.map((c) => Tab(
                child: _CashierTab(cashier: c),
              )),
        ];

        final views = <Widget>[
          // Tab "Semua" — semua transaksi tanpa filter
          const HistoryScreen(hideAppBar: true, cashierId: null),
          // Tab per kasir
          ...cashiers.map((c) =>
              HistoryScreen(hideAppBar: true, cashierId: c.id)),
        ];

        return DefaultTabController(
          length: tabs.length,
          child: Column(
            children: [
              Container(
                color: _background,
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: _accent,
                  unselectedLabelColor: _textMuted,
                  indicatorColor: _accent,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: tabs,
                ),
              ),
              Expanded(
                child: TabBarView(children: views),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Widget tab kasir — tampilkan nama + role badge
class _CashierTab extends StatelessWidget {
  final CashierEntity cashier;
  const _CashierTab({required this.cashier});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(cashier.name),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: cashier.role == 'admin'
                  ? _accent.withValues(alpha: 0.2)
                  : _surface,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              cashier.role.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                color: cashier.role == 'admin' ? _accent : _textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Provider lokal untuk ambil semua kasir
final _allCashiersProvider = FutureProvider<List<CashierEntity>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.getActiveCashiers();
});
