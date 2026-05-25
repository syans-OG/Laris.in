import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/history_provider.dart';
import '../widgets/digital_receipt_bottom_sheet.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  final bool hideAppBar;
  final int? cashierId;

  const HistoryScreen({
    super.key,
    this.hideAppBar = false,
    this.cashierId,
  });

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    ref.invalidate(historyProvider);
    ref.invalidate(historyByCashierProvider);
  }

  @override
  Widget build(BuildContext context) {
    final historyState = widget.cashierId != null
        ? ref.watch(historyByCashierProvider(widget.cashierId))
        : ref.watch(historyProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = theme.colorScheme.outline.withOpacity(isDark ? 0.28 : 0.12);

    Widget body = Column(
      children: [
        // Search Bar Section
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? const Color.fromRGBO(0, 0, 0, 0.16) : const Color.fromRGBO(0, 0, 0, 0.03),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari nomor invoice...',
                      hintStyle: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.75),
                      ),
                      prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? const Color.fromRGBO(0, 0, 0, 0.16) : const Color.fromRGBO(0, 0, 0, 0.03),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.filter_list, color: theme.colorScheme.onSurfaceVariant),
                  onPressed: () {
                    // Filter action
                  },
                ),
              ),
            ],
          ),
        ),

        // List Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terbaru',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                DateFormat('dd MMM yyyy').format(DateTime.now()).toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Space Mono',
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Transaction List
        Expanded(
          child: historyState.when(
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF006948))),
            error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Color(0xFFBA1A1A)))),
            data: (transactions) {
              final filtered = transactions.where((t) {
                final inv = t.invoiceNo.toLowerCase();
                return inv.contains(_searchQuery);
              }).toList();

              if (filtered.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () async => _refresh(),
                  child: ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.receipt_long, size: 40, color: theme.colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Menampilkan semua transaksi hari ini',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: const Color(0xFF006948),
                onRefresh: () async => _refresh(),
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final trx = filtered[index];
                    final invoiceDisplay = trx.invoiceNo.contains(r'${')
                        ? 'TRX-${trx.id.toString().padLeft(4, '0')}'
                        : trx.invoiceNo;
                    
                    final isCash = (trx.paymentMethod.toUpperCase() == 'TUNAI' || trx.paymentMethod.toUpperCase() == 'CASH');
                    final badgeColor = isCash ? theme.colorScheme.surfaceContainerHighest : const Color(0xFFC0EDD3);
                    final badgeTextColor = isCash ? theme.colorScheme.onSurfaceVariant : const Color(0xFF002114);

                    return GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => Padding(
                            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24),
                            child: DigitalReceiptBottomSheet(transaction: trx),
                          ),
                        );
                      },
                        child: Container(
                          decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? const Color.fromRGBO(0, 0, 0, 0.16) : const Color.fromRGBO(0, 0, 0, 0.05),
                              blurRadius: 1,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left side: Time & Invoice
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      DateFormat('HH:mm').format(trx.createdAt),
                                      style: TextStyle(
                                        fontFamily: 'Space Mono',
                                        fontSize: 12,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    margin: const EdgeInsets.only(top: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFBCCAC0),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      invoiceDisplay,
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Right side: Total & Badge
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  CurrencyFormatter.format(trx.total),
                                  style: const TextStyle(
                                    fontFamily: 'Space Mono',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF006948),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: badgeColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    trx.paymentMethod.toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      color: badgeTextColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );

    if (widget.hideAppBar) return Scaffold(backgroundColor: theme.scaffoldBackgroundColor, body: body);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Riwayat Transaksi',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: body,
    );
  }
}
