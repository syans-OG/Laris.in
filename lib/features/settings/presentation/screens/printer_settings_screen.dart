import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../providers/printer_provider.dart';

class PrinterSettingsScreen extends ConsumerWidget {
  const PrinterSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final btState = ref.watch(bluetoothStateProvider);
    final connectedMac = ref.watch(connectedPrinterProvider);
    final notifier = ref.read(bluetoothStateProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Pengaturan Printer',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            color: Color(0xFF191C1D),
          ),
        ),
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF191C1D)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF191C1D)),
            onPressed: () => notifier.scanDevices(),
            tooltip: 'Scan Ulang',
          ),
        ],
      ),
      body: btState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF006948))),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bluetooth_disabled, size: 48, color: Color(0xFFBA1A1A)),
              const SizedBox(height: 16),
              Text('$err', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFBA1A1A), fontFamily: 'Plus Jakarta Sans')),
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF006948),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => notifier.scanDevices(),
                child: const Text('Coba Lagi', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
        data: (devices) {
          if (devices.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     const Icon(Icons.print_disabled, size: 64, color: Color(0xFFBCCAC0)),
                     const SizedBox(height: 16),
                     const Text(
                      'Tidak ada printer Bluetooth terpasangkan ditemukan.',
                      textAlign: TextAlign.center, 
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF191C1D)
                      ),
                     ),
                     const SizedBox(height: 8),
                     const Text(
                      'Silakan pairing printer Anda melalui pengaturan Bluetooth sistem perangkat ini terlebih dahulu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF6D7A72), fontSize: 14),
                     ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Text(
                  'PERANGKAT PAIRED TERSEDIA',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: Color(0xFF6D7A72),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: devices.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    final isConnected = device.macAdress == connectedMac;
                    
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isConnected ? const Color(0xFF006948) : const Color(0xFFEDEEEF), width: isConnected ? 2 : 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.03),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)),
                          child: Icon(
                            Icons.print,
                            color: isConnected ? const Color(0xFF006948) : const Color(0xFF6D7A72),
                          ),
                        ),
                        title: Text(device.name, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, color: Color(0xFF191C1D))),
                        subtitle: Text(device.macAdress, style: const TextStyle(fontFamily: 'Space Mono', fontSize: 12, color: Color(0xFF6D7A72))),
                        trailing: isConnected 
                          ? FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFF9EAEB),
                                foregroundColor: const Color(0xFFBA1A1A),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: () => notifier.disconnectPrinter(),
                              child: const Text('Putuskan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            )
                          : FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF006948),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: () async {
                                showDialog(
                                  context: context, 
                                  barrierDismissible: false,
                                  builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF006948)))
                                );
                                
                                final success = await notifier.connectToPrinter(device.macAdress);
                                
                                if (context.mounted) {
                                  Navigator.pop(context); // remove loading
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(success ? 'Terhubung ke ${device.name}' : 'Gagal terhubung ke ${device.name}'),
                                      backgroundColor: success ? const Color(0xFF006948) : const Color(0xFFBA1A1A),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Hubungkan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
