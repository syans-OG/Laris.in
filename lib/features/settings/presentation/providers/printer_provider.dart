import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../../../../core/services/printer/printer_service.dart';

final bluetoothStateProvider = StateNotifierProvider<BluetoothStateNotifier, AsyncValue<List<BluetoothInfo>>>((ref) {
  return BluetoothStateNotifier(ref);
});

// Holds the currently connected device mac address
final connectedPrinterProvider = StateProvider<String?>((ref) => null);

class BluetoothStateNotifier extends StateNotifier<AsyncValue<List<BluetoothInfo>>> {
  final Ref _ref;

  BluetoothStateNotifier(this._ref) : super(const AsyncValue.loading()) {
    scanDevices();
  }

  Future<void> scanDevices() async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(printerServiceProvider);
      final isEnabled = await service.isBluetoothEnabled;
      
      if (!isEnabled) {
        state = AsyncValue.error('Bluetooth tidak aktif. Silakan nyalakan Bluetooth Anda.', StackTrace.current);
        return;
      }

      final devices = await service.getPairedDevices();
      state = AsyncValue.data(devices);
      
      // Auto-check connection status on load
      final isConnected = await service.isConnected;
      if (!isConnected) {
        _ref.read(connectedPrinterProvider.notifier).state = null;
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> connectToPrinter(String macAddress) async {
    try {
      final service = _ref.read(printerServiceProvider);
      
      // Attempt to disconnect previous if any
      if (await service.isConnected) {
        await service.disconnect();
      }

      final success = await service.connect(macAddress);
      if (success) {
        _ref.read(connectedPrinterProvider.notifier).state = macAddress;
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<void> disconnectPrinter() async {
    final service = _ref.read(printerServiceProvider);
    await service.disconnect();
    _ref.read(connectedPrinterProvider.notifier).state = null;
  }
}
