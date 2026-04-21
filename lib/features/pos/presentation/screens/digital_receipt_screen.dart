import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../settings/data/settings_repository.dart';
import '../../../../features/transactions/domain/entities/transaction_entity.dart';
import '../../../../shared/presentation/layouts/master_layout.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/usecases/print_receipt_usecase.dart';

class DigitalReceiptScreen extends ConsumerStatefulWidget {
  final TransactionEntity transaction;

  const DigitalReceiptScreen({
    super.key,
    required this.transaction,
  });

  @override
  ConsumerState<DigitalReceiptScreen> createState() => _DigitalReceiptScreenState();
}

enum _PrintButtonState { idle, loading, success, failed }

class _DigitalReceiptScreenState extends ConsumerState<DigitalReceiptScreen>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _checkmarkController;
  late Animation<double> _scaleAnimation;
  Timer? _countdownTimer;
  int _secondsRemaining = 8;
  bool _countdownActive = true;
  _PrintButtonState _printState = _PrintButtonState.idle;

  @override
  void initState() {
    super.initState();
    
    _checkmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkmarkController,
        curve: Curves.elasticOut,
      ),
    );

    _startCheckmarkAnimation();
    _startCountdown();
    HapticFeedback.mediumImpact();
  }

  void _startCheckmarkAnimation() {
    _checkmarkController.forward();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1), (timer) {
        if (!_countdownActive) {
          timer.cancel();
          return;
        }
        setState(() => _secondsRemaining--);
        if (_secondsRemaining <= 0) {
          timer.cancel();
          _navigateToPOS();
        }
      },
    );
  }

  void _stopCountdown() {
    if (_countdownActive) {
      setState(() => _countdownActive = false);
      _countdownTimer?.cancel();
    }
  }

  void _navigateToPOS() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MasterLayout()),
      (route) => false,
    );
  }

  Future<void> _onPrintTapped() async {
    _stopCountdown();
    setState(() => _printState = _PrintButtonState.loading);

    PrintResult result;
    try {
      result = await ref
          .read(printReceiptUseCaseProvider)
          .execute(widget.transaction)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => PrintResult.timeout,
          );
    } catch (e) {
      result = PrintResult.failed;
    }

    if (!mounted) return;

    switch (result) {
      case PrintResult.success:
        setState(() => _printState = _PrintButtonState.success);
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) _navigateToPOS();
        break;
      case PrintResult.noPrinter:
        setState(() => _printState = _PrintButtonState.failed);
        _showPrintError('Printer tidak terhubung. Cek Bluetooth dan coba lagi.');
        break;
      case PrintResult.timeout:
        setState(() => _printState = _PrintButtonState.failed);
        _showPrintError('Printer tidak merespons (timeout). Coba lagi.');
        break;
      case PrintResult.failed:
        setState(() => _printState = _PrintButtonState.failed);
        _showPrintError('Gagal mencetak. Coba lagi.');
        break;
    }
  }

  void _showPrintError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _checkmarkController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: GestureDetector(
        onTap: _stopCountdown,
        child: Scaffold(
          backgroundColor: const Color(0xFF0F1117),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),

                  // ── Animated Checkmark                  // ── Header Icon Bordered ──
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5A0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF00E5A0), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5A0).withOpacity(0.15),
                            blurRadius: 40,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.print_rounded,
                        color: Color(0xFF00E5A0),
                        size: 40,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Header Terminals ──
                  const Text(
                    'Pembayaran Berhasil!',
                    style: TextStyle(
                      color: Color(0xFF00E5A0),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Digital Receipt Card ──
                  DigitalReceiptCard(transaction: widget.transaction),

                  const SizedBox(height: 32),

                  // ── Tombol CETAK (full width) ──
                  SizedBox(
                    width: double.infinity,
                    child: _buildPrintButton(),
                  ),

                  const SizedBox(height: 12),

                  // ── Row: Bagikan + Transaksi Baru ──
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fitur share segera hadir')),
                          ),
                          icon: const Icon(Icons.share_outlined, size: 18),
                          label: const Text('Bagikan Struk'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withOpacity(0.1)),
                            minimumSize: const Size(0, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _navigateToPOS,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF33343B),
                            foregroundColor: const Color(0xFF00E5A0),
                            minimumSize: const Size(0, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Transaksi Baru →', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Countdown Footer Pill ──
                  if (_countdownActive)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF191B22),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF84958A)),
                            const SizedBox(width: 6),
                            Text(
                              'Kembali ke kasir dalam $_secondsRemaining detik...',
                              style: const TextStyle(
                                color: Color(0xFF84958A),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrintButton() {
    switch (_printState) {
      case _PrintButtonState.idle:
        return FilledButton.icon(
          onPressed: _onPrintTapped,
          icon: const Icon(Icons.print_outlined),
          label: const Text('CETAK STRUK', style: TextStyle(fontWeight: FontWeight.bold)),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF00E5A0),
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      case _PrintButtonState.loading:
        return FilledButton(
          onPressed: null,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF00E5A0),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 8),
              Text('Mencetak...',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      case _PrintButtonState.success:
        return FilledButton.icon(
          onPressed: null,
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Tercetak ✓', style: TextStyle(fontWeight: FontWeight.bold)),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      case _PrintButtonState.failed:
        return FilledButton.icon(
          onPressed: _onPrintTapped,
          icon: const Icon(Icons.warning_amber_outlined, size: 18, color: Color(0xFFFFB4AB)),
          label: const Text('⚠ Gagal Mencetak · Coba Lagi',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFB4AB))),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF33343B),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
    }
  }
}

class DigitalReceiptCard extends ConsumerWidget {
  final TransactionEntity transaction;
  const DigitalReceiptCard({
    super.key,
    required this.transaction,
  });

  double get _subtotal => (transaction.items ?? []).fold(0, (sum, item) => sum + item.subtotal);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showLogo = ref.watch(showLogoProvider);
    final logoPath = ref.watch(logoPathProvider);
    final showName = ref.watch(showStoreNameProvider);
    final storeName = ref.watch(storeNameProvider);
    final showAddress = ref.watch(showAddressProvider);
    final storeAddress = ref.watch(storeAddressProvider);
    final storePhone = ref.watch(storePhoneProvider);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1F26),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF3B4A41).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(33),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Store Identity Header
          if (showLogo) ...[
            if (logoPath != null && File(logoPath).existsSync())
              Image.file(File(logoPath), width: 64, height: 64, fit: BoxFit.contain)
            else
              Image.asset('assets/images/logo.png', width: 64, height: 64, fit: BoxFit.contain),
            const SizedBox(height: 12),
          ],
          if (showName) ...[
            Text(
              storeName.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
          ],
          if (showAddress) ...[
            Text(
              storeAddress,
              style: const TextStyle(color: Color(0xFF84958A), fontSize: 11),
              textAlign: TextAlign.center,
            ),
            Text(
              'Telp: $storePhone',
              style: const TextStyle(color: Color(0xFF84958A), fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],

          if (showName || showAddress || showLogo) ...[
            _buildDashedDivider(),
            const SizedBox(height: 24),
          ],

          // "TOTAL PEMBAYARAN" Label
          const Text(
            'TOTAL PEMBAYARAN',
            style: TextStyle(
              color: Color(0xFF84958A),
              fontSize: 11,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Total Large Amount
          Text(
            CurrencyFormatter.format(transaction.total),
            style: const TextStyle(
              color: Color(0xFF00E5A0),
              fontSize: 42,
              fontWeight: FontWeight.bold,
              fontFamily: 'SpaceMono',
            ),
          ),
          const SizedBox(height: 24),

          _buildDashedDivider(),

          const SizedBox(height: 24),

          // Invoice Info (Smaller details)
          _infoRow('No. Invoice', transaction.invoiceNo),
          _infoRow('Tanggal', DateFormat('dd/MM/yyyy HH:mm').format(transaction.createdAt)),
          const SizedBox(height: 12),

          _buildDashedDivider(),

          const SizedBox(height: 16),

          // Items List
          ...(transaction.items ?? []).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.product?.name ?? "Produk"} x ${item.qty}',
                        style: const TextStyle(color: Color(0xFFBACBBF), fontSize: 13),
                      ),
                    ),
                    _buildDashedConnector(), // Just visual dashed connector gap
                    const SizedBox(width: 8),
                    Text(
                      CurrencyFormatter.formatCompact(item.subtotal),
                      style: const TextStyle(color: Color(0xFFE2E2EB), fontSize: 13),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 12),

          _buildDashedDivider(),

          const SizedBox(height: 16),

          // Breakdown
          _summaryRow('Subtotal', CurrencyFormatter.format(_subtotal)),
          if (transaction.discount > 0)
            _summaryRow('Diskon', '-${CurrencyFormatter.format(transaction.discount)}',
                valueColor: const Color(0xFF81C784)),
          if (transaction.tax > 0)
            _summaryRow('Pajak', '+${CurrencyFormatter.format(transaction.tax)}',
                valueColor: const Color(0xFFFFB74D)),
          _summaryRow('TOTAL', CurrencyFormatter.format(transaction.total),
              bold: true, valueColor: const Color(0xFF00E5A0)),

          const SizedBox(height: 16),

          // Payment Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0C0E14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.payment_rounded, size: 14, color: Color(0xFFBACBBF)),
                        const SizedBox(width: 6),
                        Text(transaction.paymentMethod, style: const TextStyle(color: Color(0xFFBACBBF), fontSize: 12)),
                      ],
                    ),
                    Text(CurrencyFormatter.format(transaction.paidAmount),
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                if (transaction.changeAmount > 0) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: Color(0xFF2A2F45), height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Kembalian', style: TextStyle(color: Color(0xFFFFBD65), fontSize: 12)),
                      Text(CurrencyFormatter.format(transaction.changeAmount),
                          style: const TextStyle(color: Color(0xFFFFBD65), fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          if (ref.watch(storeFooterProvider).isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildDashedDivider(),
            const SizedBox(height: 16),
            Text(
              ref.watch(storeFooterProvider),
              style: const TextStyle(
                color: Color(0xFF84958A),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF84958A), fontSize: 11)),
          Text(value, style: const TextStyle(color: Color(0xFFBACBBF), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: bold ? Colors.white : const Color(0xFF84958A),
                  fontSize: bold ? 14 : 13,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontSize: bold ? 14 : 13,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildDashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFF2A2F45)),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildDashedConnector() {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boxWidth = constraints.constrainWidth();
          const dashWidth = 3.0;
          const dashHeight = 1.0;
          final dashCount = (boxWidth / (2 * dashWidth)).floor();
          if (dashCount <= 0) return const SizedBox.shrink();
          return Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.horizontal,
            children: List.generate(dashCount, (_) {
              return const SizedBox(
                width: dashWidth,
                height: dashHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xFF33343B)),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
