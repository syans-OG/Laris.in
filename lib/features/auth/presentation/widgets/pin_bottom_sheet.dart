import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import 'custom_numpad.dart';
import 'pin_indicator.dart';

const _surface2 = Color(0xFF191B22);
const _textPrimary = Color(0xFFFFFFFF);
const _textSecondary = Color(0xFFBACBBF);
const _textMuted = Color(0xFF84958A);
const _accent = Color(0xFF00E5A0);
const _error = Color(0xFFFFB4AB);

class PinBottomSheet extends ConsumerWidget {
  const PinBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(loginViewModelProvider);
    final cashier = viewModel.selectedCashier;

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
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: _surface2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Profil Kasir Mini
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: cashier.avatarUrl != null 
                      ? DecorationImage(image: AssetImage(cashier.avatarUrl!)) // fallback
                      : const DecorationImage(image: AssetImage('assets/images/avatar_placeholder.png')),
                ),
                child: cashier.avatarUrl == null
                    ? const Center(child: Icon(Icons.person, size: 16, color: _textSecondary))
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cashier.name,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    cashier.role.toUpperCase(),
                    style: const TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // PIN Indicator
          const Text(
            'MASUKKAN PIN',
            style: TextStyle(
              color: _textMuted,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
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
                      color: _error,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),

          // Custom Numpad
          CustomNumpad(
            onNumberKey: (num) => ref.read(loginViewModelProvider).addPinDigit(num),
            onBackspaceTap: () => ref.read(loginViewModelProvider).removePinDigit(),
            onBiometricTap: () {
              // TODO: Implement biometric auth
            },
          ),
          const SizedBox(height: 32),
          
          // Footer
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Lupa PIN? Hubungi Admin',
                style: TextStyle(
                  color: _textMuted,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                  decorationColor: _textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
