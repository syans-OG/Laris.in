import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/usb_barcode_scanner_service.dart';

final usbBarcodeScannerProvider = Provider<UsbBarcodeScannerService>((ref) {
  final service = UsbBarcodeScannerService.instance;
  // Initialize the singleton when first read
  service.init();
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

// A stream provider to listen to barcodes easily from widgets or other notifiers
final barcodeStreamProvider = StreamProvider<String>((ref) {
  final scanner = ref.watch(usbBarcodeScannerProvider);
  return scanner.onBarcodeScanned;
});
