import 'package:flutter/material.dart';
import '../../../reports/presentation/screens/sales_report_screen.dart';
import 'riwayat_admin_screen.dart';

const _background = Color(0xFF0E1015);
const _accent = Color(0xFF00E5A0);
const _textMuted = Color(0xFF84958A);

class LaporanScreen extends StatelessWidget {
  const LaporanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          title: const Text('Laporan'),
          backgroundColor: _background,
          elevation: 0,
          bottom: const TabBar(
            labelColor: _accent,
            unselectedLabelColor: _textMuted,
            indicatorColor: _accent,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Penjualan'),
              Tab(text: 'Riwayat'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SalesReportScreen(hideAppBar: true),
            RiwayatAdminScreen(),
          ],
        ),
      ),
    );
  }
}
