import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  final bool hideAppBar;
  final int? cashierId;

  const HistoryScreen({
    super.key,
    this.hideAppBar = false,
    this.cashierId,
  });

  void _refresh(WidgetRef ref) {
    ref.invalidate(historyProvider);
    ref.invalidate(historyByCashierProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = cashierId != null
        ? ref.watch(historyByCashierProvider(cashierId))
        : ref.watch(historyProvider);

    Widget body = historyState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (transactions) {
        if (transactions.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => _refresh(ref),
            child: ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history,
                          size: 64, color: AppColors.textMutedDark),
                      const SizedBox(height: 16),
                      Text('Belum ada transaksi',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      const Text('Tarik ke bawah untuk refresh',
                          style: TextStyle(
                              color: AppColors.textMutedDark, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _refresh(ref),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final trx = transactions[index];
              final invoiceDisplay = trx.invoiceNo.contains(r'${')
                  ? 'TRX-#${trx.id.toString().padLeft(4, '0')}'
                  : trx.invoiceNo;

              return Card(
                color: AppColors.surfaceDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              invoiceDisplay,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${trx.createdAt.day}/${trx.createdAt.month}/${trx.createdAt.year}',
                            style: const TextStyle(
                                color: AppColors.textMutedDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Pembayaran:'),
                          Text(
                            CurrencyFormatter.format(trx.total),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      if (trx.items != null && trx.items!.isNotEmpty) ...[
                        const Divider(
                            height: 24, color: AppColors.borderDark),
                        const Text('Item:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...trx.items!.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.qty}x ${item.product?.name ?? "Item ${item.id}"}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(CurrencyFormatter.format(item.subtotal)),
                                ],
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    if (hideAppBar) return body;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refresh(ref),
          ),
        ],
      ),
      body: body,
    );
  }
}
