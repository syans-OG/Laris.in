import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Riverpod Provider for Printer Service
final printerServiceProvider = Provider<PrinterService>((ref) {
  return PrinterService();
});

class PrinterService {
  Future<bool> get isBluetoothEnabled async {
    return await PrintBluetoothThermal.bluetoothEnabled;
  }

  Future<List<BluetoothInfo>> getPairedDevices() async {
    final List<BluetoothInfo> listResult = await PrintBluetoothThermal.pairedBluetooths;
    return listResult;
  }

  Future<bool> connect(String macAddress) async {
    return await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
  }

  Future<bool> get isConnected async {
    return await PrintBluetoothThermal.connectionStatus;
  }

  Future<bool> disconnect() async {
    return await PrintBluetoothThermal.disconnect;
  }

  Future<bool> printBytes(List<int> bytes) async {
    final connected = await isConnected;
    if (!connected) return false;

    // Send the ESC/POS bytes to the thermal printer
    return await PrintBluetoothThermal.writeBytes(bytes);
  }
}
