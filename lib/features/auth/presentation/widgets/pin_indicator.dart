import 'package:flutter/material.dart';

const _accent = Color(0xFF00E5A0);
const _textMuted = Color(0xFF84958A);

class PinIndicator extends StatelessWidget {
  final int pinLength;
  final bool isError;

  const PinIndicator({
    super.key,
    required this.pinLength,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isFilled = index < pinLength;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled 
                ? (isError ? const Color(0xFFFFB4AB) : _accent) 
                : Colors.transparent,
            border: Border.all(
              color: isFilled 
                  ? (isError ? const Color(0xFFFFB4AB) : _accent) 
                  : _textMuted.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: isFilled && !isError
                ? [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
