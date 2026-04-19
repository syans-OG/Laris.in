import 'package:flutter/material.dart';

const _surface = Color(0xFF1C1E26);
const _surfaceActive = Color(0xFF252830);
const _textPrimary = Color(0xFFFFFFFF);
const _textMuted = Color(0xFF84958A);

class CustomNumpad extends StatelessWidget {
  final Function(String) onNumberKey;
  final VoidCallback onBiometricTap;
  final VoidCallback onBackspaceTap;

  const CustomNumpad({
    super.key,
    required this.onNumberKey,
    required this.onBiometricTap,
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
            _buildActionButton(Icons.fingerprint, onBiometricTap),
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
      children: numbers.map((num) => _buildNumberButton(num)).toList(),
    );
  }

  Widget _buildNumberButton(String number) {
    return _NumpadButton(
      onTap: () => onNumberKey(number),
      child: Text(
        number,
        style: const TextStyle(
          fontFamily: 'SpaceMono', // Fallback spacing monospace
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return _NumpadButton(
      onTap: onTap,
      child: Icon(
        icon,
        color: _textMuted,
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
          color: _isPressed ? _surfaceActive : _surface,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}
