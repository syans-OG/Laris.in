import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../widgets/cashier_avatar.dart';
import '../widgets/pin_bottom_sheet.dart';

const _background = Color(0xFF0E1015);
const _accent = Color(0xFF00E5A0);
const _textPrimary = Color(0xFFFFFFFF);
const _textSecondary = Color(0xFFBACBBF);
const _textMuted = Color(0xFF84958A);

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(loginViewModelProvider);
    
    // No need to listen here, PinBottomSheet handles its own closing
    // and AuthGate in main.dart handles navigation.

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
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
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.storefront,
            color: _background,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Laris.in',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Selamat datang, silakan login',
          style: TextStyle(
            color: _textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCashierSelection(BuildContext context, LoginViewModel viewModel, WidgetRef ref) {
    if (viewModel.isLoading && viewModel.activeCashiers.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: _accent),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'PILIH KASIR',
              style: TextStyle(
                color: _textMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              '${viewModel.activeCashiers.length} Aktif',
              style: const TextStyle(
                color: _accent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Switch to GridView for better Layout based on revision
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
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
        ),
      ],
    );
  }

  void _showPinSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PinBottomSheet(),
    ).then((_) {
      // Reset selected cashier when sheet is dismissed manually
      // but only if not success (to avoid flash during navigation)
      if (!ref.read(loginViewModelProvider).isSuccess) {
        ref.read(loginViewModelProvider).selectCashier(null);
      }
    });
  }


}
