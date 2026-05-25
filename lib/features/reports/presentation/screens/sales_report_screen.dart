import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../providers/report_provider.dart';

const _accent = Color(0xFF006948);
const _accentLight = Color(0xFF00E5A0);
const _textMuted = Color(0xFF6D7A72);

const _trendPositive = Color(0xFF059669);
const _trendBlue = Color(0xFF3B82F6);
const _trendAmber = Color(0xFFF59E0B);
const _trendRed = Color(0xFFBA1A1A);

class SalesReportScreen extends ConsumerWidget {
  final bool hideAppBar;
  const SalesReportScreen({super.key, this.hideAppBar = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: hideAppBar
          ? null
          : AppBar(
              title: Text(
                'Laporan Penjualan',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: _PeriodTabs(),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  _KpiGrid(),
                  SizedBox(height: 24),
                  _ChartCard(),
                  SizedBox(height: 24),
                  _TopProductsCard(),
                  SizedBox(height: 24),
                  _PaymentMethodsCard(),
                  SizedBox(height: 100), // padding bottom
                ],
              ),
            ),
          ),
        ],
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
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: _accent,
              onPrimary: Colors.white,
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
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
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
    return Builder(builder: (context) {
      final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF006948) : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
              color: isActive ? Colors.white : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
    });
  }
}

class _KpiGrid extends ConsumerWidget {
  const _KpiGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(reportSummaryProvider);
    final theme = Theme.of(context);

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
          childAspectRatio: 1.4,
          children: [
            _buildKpiCard(
              context: context,
              title: 'TOTAL OMSET',
              value: currencyFormat.format(summary.totalRevenue),
              trend: revTrendStr,
              valueColor: _accent,
              trendColor: revTrendStr.startsWith('+') ? _trendPositive : (revTrendStr == '-' ? theme.colorScheme.onSurfaceVariant : _trendRed),
              icon: revTrendStr.startsWith('+') ? Icons.trending_up : Icons.trending_down
            ),
            _buildKpiCard(
              context: context,
              title: 'TRANSAKSI',
              value: '${summary.totalTransactions}',
              trend: trxTrendStr,
              valueColor: Theme.of(context).colorScheme.onSurface,
              trendColor: _trendBlue,
              icon: Icons.receipt_long
            ),
            _buildKpiCard(
              context: context,
              title: 'ITEM TERJUAL',
              value: '${summary.totalItemsSold}',
              trend: '-',
              valueColor: Theme.of(context).colorScheme.onSurface,
              trendColor: _trendAmber,
              icon: Icons.inventory_2
            ),
            _buildKpiCard(
              context: context,
              title: 'RATA-RATA/TRX',
              value: currencyFormat.format(summary.avgPerTransaction),
              trend: '-',
              valueColor: Theme.of(context).colorScheme.onSurface,
              trendColor: Theme.of(context).colorScheme.onSurfaceVariant,
              icon: Icons.analytics
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard({required BuildContext context, required String title, required String value, required String trend, required Color valueColor, required Color trendColor, required IconData icon}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(isDark ? 0.28 : 0.08)),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color.fromRGBO(0, 0, 0, 0.16) : const Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                title, 
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 10, 
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value, 
            style: TextStyle(
              fontFamily: 'Space Mono', 
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: valueColor,
              letterSpacing: -0.5,
            ), 
            maxLines: 1, 
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              if (trend != '-') ...[
                Icon(
                  trend.startsWith('+') ? Icons.arrow_upward : Icons.arrow_downward, 
                  size: 12, 
                  color: trendColor
                ),
                const SizedBox(width: 4),
              ],
              Text(
                trend, 
                style: TextStyle(
                  fontFamily: 'Space Mono',
                  fontSize: 11, 
                  color: trendColor, 
                  fontWeight: FontWeight.bold
                )
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _ChartCard extends ConsumerWidget {
  const _ChartCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyAsync = ref.watch(dailyRevenueProvider);
    final period = ref.watch(reportPeriodProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    String periodLabel = 'Grafik Penjualan';
    if (period == ReportPeriod.sevenDays) periodLabel = 'Omset 7 Hari Terakhir';
    else if (period == ReportPeriod.today) periodLabel = 'Omset Hari Ini';
    else if (period == ReportPeriod.thirtyDays) periodLabel = 'Omset 30 Hari Terakhir';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(isDark ? 0.28 : 0.08)),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color.fromRGBO(0, 0, 0, 0.16) : const Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            periodLabel, 
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              color: theme.colorScheme.onSurface,
              fontSize: 16, 
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 220,
            child: dailyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: _accent)),
              error: (e, _) => const Center(child: Text('Gagal memuat grafik', style: TextStyle(color: _trendRed))),
              data: (data) {
                if (data.isEmpty) {
                  return Center(child: Text('Tidak ada data', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)));
                }

                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: data.fold<double>(0, (max, e) => e.revenue > max ? e.revenue : max) * 1.2,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => theme.colorScheme.inverseSurface,
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(rod.toY),
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Space Mono',
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
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
                              text = DateFormat('HH:mm').format(date);
                            } else {
                              text = DateFormat('dd MMM').format(date);
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Text(text, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 10, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600)),
                            );
                          },
                          reservedSize: 32,
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
                      getDrawingHorizontalLine: (value) => FlLine(color: theme.colorScheme.outline.withOpacity(isDark ? 0.28 : 0.16), strokeWidth: 1, dashArray: [4, 4]),
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
                            color: isLast ? _accent : _accentLight,
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(isDark ? 0.28 : 0.08)),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color.fromRGBO(0, 0, 0, 0.16) : const Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Produk Terlaris', 
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.bold, 
              fontSize: 16, 
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          topProductsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: _accent)),
            error: (e, _) => const Center(child: Text('Error', style: TextStyle(color: _trendRed))),
            data: (products) {
              if (products.isEmpty) return Text('Belum ada penjualan', style: TextStyle(color: theme.colorScheme.onSurfaceVariant));

              return Column(
                children: products.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final prod = entry.value;
                  final rank = idx + 1;
                  
                  final isTop1 = rank == 1;
                  final rankBg = isTop1 ? const Color(0xFFC0EDD3) : theme.colorScheme.surfaceContainerHighest;
                  final rankColor = isTop1 ? const Color(0xFF002114) : theme.colorScheme.onSurfaceVariant;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: rankBg, 
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '#$rank', 
                              style: TextStyle(
                                fontFamily: 'Space Mono',
                                color: rankColor, 
                                fontSize: 12, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prod.productName, 
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 14, 
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${prod.qtySold} terjual', 
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 12, 
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          currencyFormat.format(prod.revenue),
                          style: TextStyle(
                            fontFamily: 'Space Mono', 
                            fontWeight: FontWeight.bold, 
                            fontSize: 14, 
                            color: isTop1 ? _accent : theme.colorScheme.onSurface,
                          ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(isDark ? 0.28 : 0.08)),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color.fromRGBO(0, 0, 0, 0.16) : const Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Metode Pembayaran',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          paymentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: _accent)),
            error: (e, _) => const Center(child: Text('Error', style: TextStyle(color: _trendRed))),
            data: (methods) {
              if (methods.isEmpty) {
                return Text('Belum ada transaksi', style: TextStyle(color: theme.colorScheme.onSurfaceVariant));
              }

              final total = methods.fold<double>(0, (sum, item) => sum + item.revenue);
              final totalTransactions = methods.fold<int>(0, (sum, item) => sum + item.transactionCount);
              final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
              final entries = methods.toList()
                ..sort((a, b) => _methodOrder(a.method).compareTo(_methodOrder(b.method)));

              return Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 104,
                        height: 104,
                        child: Stack(
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 4,
                                centerSpaceRadius: 36,
                                sections: entries.map((e) {
                                  return PieChartSectionData(
                                    value: e.revenue,
                                    color: _methodColor(e.method),
                                    showTitle: false,
                                    radius: 12,
                                  );
                                }).toList(),
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'TOTAL',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    NumberFormat.compact(locale: 'id_ID').format(total),
                                    style: TextStyle(
                                      fontFamily: 'Space Mono',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Pembayaran Masuk',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              currencyFormat.format(total),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Space Mono',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$totalTransactions transaksi',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: entries.map((e) {
                      final pct = total == 0 ? 0 : (e.revenue / total) * 100;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _methodColor(e.method),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _methodLabel(e.method),
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${e.method} - ${e.transactionCount} transaksi',
                                    style: TextStyle(
                                      fontFamily: 'Space Mono',
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currencyFormat.format(e.revenue),
                                  style: TextStyle(
                                    fontFamily: 'Space Mono',
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${pct.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontFamily: 'Space Mono',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          )
        ],
      ),
    );
  }

  String _methodLabel(String method) {
    switch (method.toUpperCase()) {
      case 'CASH':
      case 'TUNAI':
        return 'Tunai';
      case 'QRIS':
        return 'QRIS';
      case 'TRANSFER':
        return 'Transfer';
      default:
        return method;
    }
  }

  Color _methodColor(String method) {
    switch (method.toUpperCase()) {
      case 'CASH':
      case 'TUNAI':
        return _trendAmber;
      case 'QRIS':
        return _accent;
      case 'TRANSFER':
        return _trendBlue;
      default:
        return _textMuted;
    }
  }

  int _methodOrder(String method) {
    switch (method.toUpperCase()) {
      case 'CASH':
      case 'TUNAI':
        return 0;
      case 'QRIS':
        return 1;
      case 'TRANSFER':
        return 2;
      default:
        return 99;
    }
  }
}
