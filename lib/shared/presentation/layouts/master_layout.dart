import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/pos/presentation/screens/pos_screen.dart';
import '../../../features/products/presentation/screens/product_management_screen.dart';
import '../../../features/history/presentation/screens/history_screen.dart';
import '../../../features/laporan/presentation/screens/laporan_screen.dart';
import '../../../features/settings/presentation/screens/settings_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/products/presentation/providers/product_provider.dart';
import '../../../features/products/presentation/providers/category_provider.dart';
import '../../../features/history/presentation/providers/history_provider.dart';
import '../../../features/reports/presentation/providers/report_provider.dart';

class MasterLayout extends ConsumerStatefulWidget {
  const MasterLayout({super.key});

  @override
  ConsumerState<MasterLayout> createState() => _MasterLayoutState();
}

class _MasterLayoutState extends ConsumerState<MasterLayout> {
  int _currentIndex = 0;

  void _refreshData() {
    // Refresh data providers when switching tabs so the new screen gets the latest data
    ref.invalidate(productsProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(historyProvider);
    ref.invalidate(historyByCashierProvider);
    ref.invalidate(reportSummaryProvider);
    ref.invalidate(dailyRevenueProvider);
    ref.invalidate(topProductsProvider);
    ref.invalidate(paymentMethodBreakdownProvider);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final isAdmin = session?.role == 'admin';

    // Admin: Kasir | Produk | Laporan | Pengaturan
    // Kasir: Kasir | Riwayat | Pengaturan
    final screens = isAdmin
        ? const [
            PosScreen(),
            ProductManagementScreen(),
            LaporanScreen(),
            SettingsScreen(),
          ]
        : const [
            PosScreen(),
            HistoryScreen(),
            SettingsScreen(),
          ];

    final adminNavItems = const [
      NavigationDestination(icon: Icon(Icons.point_of_sale_outlined), selectedIcon: Icon(Icons.point_of_sale), label: 'Register'),
      NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Inventory'),
      NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Laporan'),
      NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
    ];

    final kasirNavItems = const [
      NavigationDestination(icon: Icon(Icons.point_of_sale_outlined), selectedIcon: Icon(Icons.point_of_sale), label: 'Register'),
      NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'History'),
      NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
    ];

    // Guard: reset index if it's out of bounds after role switch
    final safeIndex = _currentIndex.clamp(0, screens.length - 1);

    final currentNavItems = isAdmin ? adminNavItems : kasirNavItems;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
           // ... keeping desktop rail the same for now, or just returning standard Scaffold
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: safeIndex,
                  onDestinationSelected: (idx) {
                    if (_currentIndex != idx) {
                      _refreshData();
                      setState(() => _currentIndex = idx);
                    }
                  },
                  backgroundColor: AppColors.surfaceLight,
                  indicatorColor: const Color(0xFFECFDF5),
                  selectedIconTheme:
                      const IconThemeData(color: Color(0xFF059669)),
                  selectedLabelTextStyle:
                      const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w600),
                  unselectedIconTheme:
                      const IconThemeData(color: Color(0xFF3D4A42)),
                  unselectedLabelTextStyle:
                      const TextStyle(color: Color(0xFF3D4A42)),
                  destinations: currentNavItems.map((item) => NavigationRailDestination(
                    icon: item.icon,
                    selectedIcon: item.selectedIcon,
                    label: Text(item.label),
                  )).toList(),
                ),
                const VerticalDivider(
                    thickness: 1, width: 1, color: AppColors.borderLight),
                Expanded(child: screens[safeIndex]),
              ],
            ),
          );
        }

        return Scaffold(
          body: screens[safeIndex],
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Color(0xCCFFFFFF),
              border: Border(top: BorderSide(color: Color.fromRGBO(188, 202, 192, 0.1))),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 33, 20, 0.04),
                  blurRadius: 12,
                  offset: Offset(0, -8),
                )
              ]
            ),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(currentNavItems.length, (index) {
                        final item = currentNavItems[index];
                        final isSelected = index == safeIndex;
                        return GestureDetector(
                          onTap: () {
                            if (_currentIndex != index) {
                              _refreshData();
                              setState(() => _currentIndex = index);
                            }
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFECFDF5) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSelected ? (item.selectedIcon as Icon).icon : (item.icon as Icon).icon, 
                                  color: isSelected ? const Color(0xFF059669) : const Color(0xFF3D4A42), 
                                  size: 20
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    color: isSelected ? const Color(0xFF059669) : const Color(0xFF3D4A42),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
