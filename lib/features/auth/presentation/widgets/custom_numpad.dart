import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CustomNumpad extends StatelessWidget {
  final Function(String) onNumberKey;
  final VoidCallback? onBiometricTap;
  final VoidCallback onBackspaceTap;

  const CustomNumpad({
    super.key,
    required this.onNumberKey,
    this.onBiometricTap,
    required this.onBackspaceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 16),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 16),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (onBiometricTap != null)
              _buildActionButton(Icons.fingerprint, onBiometricTap!)
            else
              const SizedBox(width: 80, height: 80),
            _buildNumberButton('0'),
            _buildActionButton(Icons.backspace_outlined, onBackspaceTap),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((n) => _buildNumberButton(n)).toList(),
    );
  }

  Widget _buildNumberButton(String number) {
    return _NumpadButton(
      onTap: () => onNumberKey(number),
      child: Text(
        number,
        style: AppTypography.displayLarge.copyWith(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w400, // Thinner for elegance
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return _NumpadButton(
      onTap: onTap,
      child: Icon(
        icon,
        color: AppColors.textPrimaryLight,
        size: 28,
      ),
    );
  }
}

class _NumpadButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _NumpadButton({
    required this.child,
    required this.onTap,
  });

  @override
  State<_NumpadButton> createState() => _NumpadButtonState();
}

class _NumpadButtonState extends State<_NumpadButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: _isPressed ? AppColors.surface2Light : Colors.transparent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}
