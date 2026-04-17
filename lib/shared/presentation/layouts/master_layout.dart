import 'package:flutter/material.dart';
import '../../../../features/pos/presentation/screens/pos_screen.dart';
import '../../../../features/products/presentation/screens/product_management_screen.dart';
import '../../../../features/history/presentation/screens/history_screen.dart';
import '../../../../features/settings/presentation/screens/settings_screen.dart';
import '../../../../core/theme/app_theme.dart';

class MasterLayout extends StatefulWidget {
  const MasterLayout({super.key});

  @override
  State<MasterLayout> createState() => _MasterLayoutState();
}

class _MasterLayoutState extends State<MasterLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PosScreen(),
    const ProductManagementScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop / Tablet Landscape mode use NavigationRail
        if (constraints.maxWidth > 800) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (idx) {
                    setState(() {
                      _currentIndex = idx;
                    });
                  },
                  backgroundColor: AppColors.surfaceDark,
                  selectedIconTheme: const IconThemeData(color: AppColors.primary),
                  selectedLabelTextStyle: const TextStyle(color: AppColors.primary),
                  unselectedIconTheme: const IconThemeData(color: AppColors.textMutedDark),
                  unselectedLabelTextStyle: const TextStyle(color: AppColors.textMutedDark),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.point_of_sale),
                      label: Text('Kasir'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.inventory_2),
                      label: Text('Produk'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.history),
                      label: Text('Riwayat'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      label: Text('Pengaturan'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1, color: AppColors.borderDark),
                Expanded(child: _screens[_currentIndex]),
              ],
            ),
          );
        }

        // Mobile use BottomNavigationBar
        return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (idx) {
              setState(() {
                _currentIndex = idx;
              });
            },
            backgroundColor: AppColors.surfaceDark,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textMutedDark,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.point_of_sale),
                label: 'Kasir',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2),
                label: 'Produk',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'Riwayat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Pengaturan',
              ),
            ],
          ),
        );
      },
    );
  }
}
