import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/pos/presentation/screens/pos_screen.dart';
import '../../../features/products/presentation/screens/product_management_screen.dart';
import '../../../features/history/presentation/screens/history_screen.dart';
import '../../../features/laporan/presentation/screens/laporan_screen.dart';
import '../../../features/settings/presentation/screens/settings_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';

class MasterLayout extends ConsumerStatefulWidget {
  const MasterLayout({super.key});

  @override
  ConsumerState<MasterLayout> createState() => _MasterLayoutState();
}

class _MasterLayoutState extends ConsumerState<MasterLayout> {
  int _currentIndex = 0;

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
      BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'Kasir'),
      BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Produk'),
      BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Laporan'),
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Pengaturan'),
    ];

    final kasirNavItems = const [
      BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'Kasir'),
      BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Pengaturan'),
    ];

    // Guard: reset index if it's out of bounds after role switch
    final safeIndex = _currentIndex.clamp(0, screens.length - 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: safeIndex,
                  onDestinationSelected: (idx) =>
                      setState(() => _currentIndex = idx),
                  backgroundColor: AppColors.surfaceDark,
                  selectedIconTheme:
                      const IconThemeData(color: AppColors.primary),
                  selectedLabelTextStyle:
                      const TextStyle(color: AppColors.primary),
                  unselectedIconTheme:
                      const IconThemeData(color: AppColors.textMutedDark),
                  unselectedLabelTextStyle:
                      const TextStyle(color: AppColors.textMutedDark),
                  destinations: isAdmin
                      ? const [
                          NavigationRailDestination(
                              icon: Icon(Icons.point_of_sale),
                              label: Text('Kasir')),
                          NavigationRailDestination(
                              icon: Icon(Icons.inventory_2),
                              label: Text('Produk')),
                          NavigationRailDestination(
                              icon: Icon(Icons.bar_chart),
                              label: Text('Laporan')),
                          NavigationRailDestination(
                              icon: Icon(Icons.settings),
                              label: Text('Pengaturan')),
                        ]
                      : const [
                          NavigationRailDestination(
                              icon: Icon(Icons.point_of_sale),
                              label: Text('Kasir')),
                          NavigationRailDestination(
                              icon: Icon(Icons.history),
                              label: Text('Riwayat')),
                          NavigationRailDestination(
                              icon: Icon(Icons.settings),
                              label: Text('Pengaturan')),
                        ],
                ),
                const VerticalDivider(
                    thickness: 1, width: 1, color: AppColors.borderDark),
                Expanded(child: screens[safeIndex]),
              ],
            ),
          );
        }

        return Scaffold(
          body: screens[safeIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: safeIndex,
            onTap: (idx) => setState(() => _currentIndex = idx),
            backgroundColor: AppColors.surfaceDark,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textMutedDark,
            type: BottomNavigationBarType.fixed,
            items: isAdmin ? adminNavItems : kasirNavItems,
          ),
        );
      },
    );
  }
}
