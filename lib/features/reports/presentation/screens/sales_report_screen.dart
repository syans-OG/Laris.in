import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../providers/report_provider.dart';


// DESIGN TOKENS
const _background = Color(0xFF111319);
const _surface = Color(0xFF1E1F26);
const _surface2 = Color(0xFF191B22);
const _surface3 = Color(0xFF282A30);
const _accent = Color(0xFF00E5A0);
const _textPrimary = Color(0xFFE2E2EB);
const _textSecondary = Color(0xFFBACBBF);
const _textMuted = Color(0xFF84958A);

const _trendPositive = Color(0xFF00E29E);
const _trendBlue = Color(0xFFAFC6FF);
const _trendAmber = Color(0xFFFFBD65);
const _trendRed = Color(0xFFFFB4AB);

class SalesReportScreen extends ConsumerWidget {
  final bool hideAppBar;
  const SalesReportScreen({super.key, this.hideAppBar = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: _background,
      appBar: hideAppBar
          ? null
          : AppBar(
              title: const Text('Laporan Penjualan'),
              backgroundColor: _background,
              elevation: 0,
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _PeriodTabs(),
            const SizedBox(height: 24),
            const _KpiGrid(),
            const SizedBox(height: 24),
            const _ChartCard(),
            const SizedBox(height: 24),
            const _TopProductsCard(),
            const SizedBox(height: 24),
            const _PaymentMethodsCard(),
          ],
        ),
      ),
    );
  }
}

class _PeriodTabs extends ConsumerWidget {
  const _PeriodTabs();

  Future<void> _pickCustomDateRange(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _accent,
              surface: _surface,
              onPrimary: Color(0xFF006141),
              onSurface: _textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(customDateRangeProvider.notifier).state = DateTimeRange(
        start: picked.start,
        end: DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59),
      );
      ref.read(reportPeriodProvider.notifier).state = ReportPeriod.custom;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPeriod = ref.watch(reportPeriodProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTab(
            label: 'Hari Ini',
            isActive: currentPeriod == ReportPeriod.today,
            onTap: () => ref.read(reportPeriodProvider.notifier).state = ReportPeriod.today,
          ),
          _buildTab(
            label: '7 Hari',
            isActive: currentPeriod == ReportPeriod.sevenDays,
            onTap: () => ref.read(reportPeriodProvider.notifier).state = ReportPeriod.sevenDays,
          ),
          _buildTab(
            label: '30 Hari',
            isActive: currentPeriod == ReportPeriod.thirtyDays,
            onTap: () => ref.read(reportPeriodProvider.notifier).state = ReportPeriod.thirtyDays,
          ),
          _buildTab(
            label: 'Bulan Ini',
            isActive: currentPeriod == ReportPeriod.thisMonth,
            onTap: () => ref.read(reportPeriodProvider.notifier).state = ReportPeriod.thisMonth,
          ),
          _buildTab(
            label: 'Custom',
            isActive: currentPeriod == ReportPeriod.custom,
            onTap: () => _pickCustomDateRange(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({required String label, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _accent : _surface3,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF006141) : _textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _KpiGrid extends ConsumerWidget {
  const _KpiGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(reportSummaryProvider);

    return summaryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: _accent)),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: _trendRed))),
      data: (summary) {
        
        // Calculate trends
        String calcTrend(double current, double? previous) {
          if (previous == null || previous == 0) return '-';
          final diff = current - previous;
          final pct = (diff / previous) * 100;
          final sign = diff > 0 ? '+' : '';
          return '$sign${pct.toStringAsFixed(1)}%';
        }
        
        final revTrendStr = calcTrend(summary.totalRevenue, summary.previousRevenue);
        final trxTrendStr = calcTrend(summary.totalTransactions.toDouble(), summary.previousTransactions);
        
        final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

        return GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: [
            _buildKpiCard(
              title: 'TOTAL OMSET',
              value: currencyFormat.format(summary.totalRevenue),
              trend: revTrendStr,
              valueColor: _accent,
              trendColor: revTrendStr.startsWith('+') ? _trendPositive : (revTrendStr == '-' ? _textMuted : _trendRed),
              icon: revTrendStr.startsWith('+') ? Icons.arrow_upward : Icons.arrow_downward
            ),
            _buildKpiCard(
              title: 'TRANSAKSI',
              value: '${summary.totalTransactions}',
              trend: trxTrendStr,
              valueColor: _textPrimary,
              trendColor: _trendBlue,
              icon: Icons.receipt_long
            ),
            _buildKpiCard(
              title: 'ITEM TERJUAL',
              value: '${summary.totalItemsSold}',
              trend: '-', // Items trend missing from summary, simplify for now
              valueColor: _textPrimary,
              trendColor: _trendAmber,
              icon: Icons.inventory_2
            ),
            _buildKpiCard(
              title: 'RATA-RATA/TRX',
              value: currencyFormat.format(summary.avgPerTransaction),
              trend: '-',
              valueColor: _textPrimary,
              trendColor: _textPrimary,
              icon: Icons.analytics
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard({required String title, required String value, required String trend, required Color valueColor, required Color trendColor, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _surface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderThin, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, color: _textMuted, letterSpacing: 0.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontFamily: 'SpaceMono', fontWeight: FontWeight.bold, color: valueColor), maxLines: 1, overflow: TextOverflow.ellipsis),
          const Spacer(),
          Row(
            children: [
              if (trend != '-') Icon(icon, size: 12, color: trendColor),
              if (trend != '-') const SizedBox(width: 4),
              Text(trend, style: TextStyle(fontSize: 12, color: trendColor, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}

const _borderThin = Color(0xFF2A2F45);

class _ChartCard extends ConsumerWidget {
  const _ChartCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyAsync = ref.watch(dailyRevenueProvider);
    final period = ref.watch(reportPeriodProvider);
    
    // Label depending on period
    String periodLabel = 'Omset Pilihan';
    if (period == ReportPeriod.sevenDays) periodLabel = 'Omset 7 Hari Terakhir';
    else if (period == ReportPeriod.today) periodLabel = 'Omset Hari Ini';
    else if (period == ReportPeriod.thirtyDays) periodLabel = 'Omset 30 Hari Terakhir';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderThin, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(periodLabel, style: const TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: dailyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: _accent)),
              error: (e, _) => Center(child: Text('Error load chart')),
              data: (data) {
                if (data.isEmpty) {
                  return const Center(child: Text('Tidak ada data', style: TextStyle(color: _textMuted)));
                }

                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: data.fold<double>(0, (max, e) => e.revenue > max ? e.revenue : max) * 1.2,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                            
                            final date = data[idx].date;
                            String text;
                            if (period == ReportPeriod.today) {
                              text = DateFormat('HH:mm').format(date); // Not precise if grouping by date, need to adapt if hourly
                            } else {
                              text = DateFormat('EE').format(date); // Sen, Sel, Rab
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(text, style: const TextStyle(color: _textMuted, fontSize: 10)),
                            );
                          },
                          reservedSize: 28,
                        ),
                      ),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: data.fold<double>(0, (max, e) => e.revenue > max ? e.revenue : max) / 4 > 0 ? data.fold<double>(0, (max, e) => e.revenue > max ? e.revenue : max) / 4 : 1000,
                      getDrawingHorizontalLine: (value) => FlLine(color: _textMuted.withValues(alpha: 0.1), strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: data.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final d = entry.value;
                      final isLast = idx == data.length - 1;
                      
                      return BarChartGroupData(
                        x: idx,
                        barRods: [
                          BarChartRodData(
                            toY: d.revenue,
                            color: isLast ? _accent : _accent.withValues(alpha: 0.7),
                            width: 16,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class _TopProductsCard extends ConsumerWidget {
  const _TopProductsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topProductsAsync = ref.watch(topProductsProvider);
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Produk Terlaris', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _textPrimary)),
          const SizedBox(height: 16),
          topProductsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: _accent)),
            error: (e, _) => const Center(child: Text('Error', style: TextStyle(color: _textMuted))),
            data: (products) {
              if (products.isEmpty) return const Text('Tidak ada penjualan', style: TextStyle(color: _textMuted));

              return Column(
                children: products.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final prod = entry.value;
                  final rank = idx + 1;
                  
                  final isTop1 = rank == 1;
                  final rankBg = isTop1 ? const Color.fromRGBO(110, 255, 192, 0.1) : const Color(0xFF33343B);
                  final rankColor = isTop1 ? _trendPositive : _textMuted;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: rankBg, borderRadius: BorderRadius.circular(4)),
                          child: Text('#0$rank', style: TextStyle(color: rankColor, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(prod.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _textPrimary)),
                              Text('${prod.qtySold} terjual', style: const TextStyle(fontSize: 10, color: _textMuted)),
                            ],
                          ),
                        ),
                        Text(
                          currencyFormat.format(prod.revenue),
                          style: TextStyle(fontFamily: 'SpaceMono', fontWeight: FontWeight.bold, fontSize: 12, color: isTop1 ? _accent : _textPrimary),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }
}

class _PaymentMethodsCard extends ConsumerWidget {
  const _PaymentMethodsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentMethodBreakdownProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _textPrimary)),
          const SizedBox(height: 16),
          paymentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: _accent)),
            error: (e, _) => const Center(child: Text('Error', style: TextStyle(color: _textMuted))),
            data: (methods) {
              if (methods.isEmpty) return const Text('Belum ada transaksi', style: TextStyle(color: _textMuted));

              final total = methods.values.fold<double>(0, (sum, val) => sum + val);

              return Row(
                children: [
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: Stack(
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 36,
                            sections: methods.entries.map((e) {
                              Color c = _trendBlue;
                              if (e.key == 'TUNAI') c = const Color(0xFF6EFFC0);
                              else if (e.key == 'TRANSFER') c = _trendAmber;
                              
                              return PieChartSectionData(
                                value: e.value,
                                color: c,
                                showTitle: false,
                                radius: 10,
                              );
                            }).toList(),
                          ),
                        ),
                        const Center(
                          child: Text('TOTAL', style: TextStyle(fontFamily: 'SpaceMono', fontWeight: FontWeight.bold, fontSize: 10, color: _textPrimary)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: methods.entries.map((e) {
                        final pct = (e.value / total) * 100;
                        Color c = _trendBlue;
                        if (e.key == 'TUNAI') c = const Color(0xFF6EFFC0);
                        else if (e.key == 'TRANSFER') c = _trendAmber;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(e.key, style: const TextStyle(fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.w500, color: _textPrimary))),
                              Text('${pct.toStringAsFixed(1)}%', style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 10, fontWeight: FontWeight.bold, color: _textPrimary)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  )
                ],
              );
            },
          )
        ],
      ),
    );
  }
}
