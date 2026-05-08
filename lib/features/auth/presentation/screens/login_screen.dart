import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../widgets/cashier_avatar.dart';
import '../widgets/pin_bottom_sheet.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(loginViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 48),
                _buildCashierSelection(context, viewModel, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: const [
        Text(
          'LARIS.IN',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w800,
            fontSize: 32,
            color: Color(0xFF006948),
            letterSpacing: 2.0,
          ),
        ),
        SizedBox(height: 24),
        Text(
          'Selamat Datang Kembali',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            color: Color(0xFF191C1D),
            fontSize: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Pilih akun Anda untuk mengakses sistem\nkasir.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            color: Color(0xFF6D7A72),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCashierSelection(BuildContext context, LoginViewModel viewModel, WidgetRef ref) {
    if (viewModel.isLoading && viewModel.activeCashiers.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF006948)),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: viewModel.activeCashiers.length,
      itemBuilder: (context, index) {
        final cashier = viewModel.activeCashiers[index];
        return CashierAvatar(
          cashier: cashier,
          isSelected: viewModel.selectedCashier?.id == cashier.id,
          onTap: () {
            ref.read(loginViewModelProvider).selectCashier(cashier);
            _showPinSheet(context, ref);
          },
        );
      },
    );
  }

  void _showPinSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PinBottomSheet(),
    ).then((_) {
      if (!ref.read(loginViewModelProvider).isSuccess) {
        ref.read(loginViewModelProvider).selectCashier(null);
      }
    });
  }
}
