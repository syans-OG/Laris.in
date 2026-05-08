import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'custom_numpad.dart';
import 'pin_indicator.dart';

class PinBottomSheet extends ConsumerWidget {
  const PinBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(loginViewModelProvider);
    final cashier = viewModel.selectedCashier;
    final theme = Theme.of(context);

    // Listen for success to automatically close the bottom sheet
    ref.listen(loginViewModelProvider, (previous, next) {
      if (next.isSuccess) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    });

    if (cashier == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          
          // PIN Indicator Title
          Text(
            'Masukkan PIN untuk ${cashier.name}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          PinIndicator(
            pinLength: viewModel.currentPin.length,
            isError: viewModel.errorMessage != null,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 20,
            child: viewModel.errorMessage != null
                ? Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),

          // Custom Numpad
          CustomNumpad(
            onNumberKey: (n) => ref.read(loginViewModelProvider).addPinDigit(n),
            onBackspaceTap: () => ref.read(loginViewModelProvider).removePinDigit(),
            onBiometricTap: null, // Removed for cleaner UI if not needed yet
          ),
          const SizedBox(height: 32),
          
          // Footer
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Lupa PIN?',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
