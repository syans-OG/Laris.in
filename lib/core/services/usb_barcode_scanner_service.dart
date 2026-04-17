import 'dart:async';
import 'package:flutter/services.dart';

class UsbBarcodeScannerService {
  static final UsbBarcodeScannerService instance = UsbBarcodeScannerService._init();

  final _barcodeStreamController = StreamController<String>.broadcast();
  Stream<String> get onBarcodeScanned => _barcodeStreamController.stream;

  String _buffer = '';
  DateTime? _lastKeyPressTime;
  
  // Throttle time between keystrokes to differentiate hardware scanner vs human typing
  static const int _thresholdMs = 50; 
  static const int _minBarcodeLength = 4;

  UsbBarcodeScannerService._init();

  void init() {
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _barcodeStreamController.close();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final now = DateTime.now();
      
      // Reset buffer if time between keys is too large (likely human typing)
      if (_lastKeyPressTime != null && now.difference(_lastKeyPressTime!).inMilliseconds > _thresholdMs) {
        _buffer = '';
      }
      
      _lastKeyPressTime = now;

      // Handle Enter key for submit (Scanner usually ends with Enter/Return)
      if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter) {
        if (_buffer.length >= _minBarcodeLength) {
          _barcodeStreamController.add(_buffer);
          _buffer = '';
          return true; // Consume the enter key so it doesn't trigger other UI forms unnecessarily
        }
        _buffer = '';
        return false;
      }

      // Append character to buffer
      if (event.character != null && event.character!.isNotEmpty) {
        // Exclude control characters
        if (!event.character!.codeUnits.any((c) => c < 32 || c == 127)) {
          _buffer += event.character!;
        }
      }
    }
    return false; // Don't consume characters, let them cascade to active TextFields if any
  }
}
