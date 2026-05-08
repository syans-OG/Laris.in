import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PinIndicator extends StatelessWidget {
  final int pinLength;
  final bool isError;
  final int maxLen; // Make it configurable, default to 4

  const PinIndicator({
    super.key,
    required this.pinLength,
    this.isError = false,
    this.maxLen = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxLen, (index) {
        final isFilled = index < pinLength;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled 
                ? (isError ? AppColors.error : AppColors.primary) 
                : AppColors.surface2Light,
          ),
        );
      }),
    );
  }
}
