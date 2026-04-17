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
      appBar: AppBar(
        title: const Text('Pengaturan Printer Bluetooth'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.scanDevices(),
            tooltip: 'Scan Ulang',
          ),
        ],
      ),
      body: btState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bluetooth_disabled, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('\$err', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error)),
              const SizedBox(height: 24),
              AppButton(
                text: 'Coba Lagi',
                onPressed: () => notifier.scanDevices(),
              )
            ],
          ),
        ),
        data: (devices) {
          if (devices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.print_disabled, size: 64, color: AppColors.textMutedDark),
                   const SizedBox(height: 16),
                   Text('Tidak ada printer Bluetooth terpasangkan (Paired) ditemukan.',
                    textAlign: TextAlign.center, 
                    style: Theme.of(context).textTheme.titleMedium,
                   ),
                   const SizedBox(height: 8),
                   const Text('Silakan pairing printer Anda melalui pengaturan Bluetooth sistem perangkat ini terlebih dahulu.',
                    textAlign: TextAlign.center,
                   ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Perangkat Paired Tersedia',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: devices.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.borderDark),
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    final isConnected = device.macAdress == connectedMac;
                    
                    return ListTile(
                      leading: Icon(
                        Icons.print,
                        color: isConnected ? AppColors.success : AppColors.textMutedDark,
                      ),
                      title: Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(device.macAdress),
                      trailing: isConnected 
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => notifier.disconnectPrinter(),
                            child: const Text('Putuskan'),
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              // Tampilkan indikator loading di UI local / blok sementara
                              showDialog(
                                context: context, 
                                barrierDismissible: false,
                                builder: (_) => const Center(child: CircularProgressIndicator())
                              );
                              
                              final success = await notifier.connectToPrinter(device.macAdress);
                              
                              if (context.mounted) {
                                Navigator.pop(context); // remove loading
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success ? 'Terhubung ke \${device.name}' : 'Gagal terhubung ke \${device.name}'),
                                    backgroundColor: success ? AppColors.success : AppColors.error,
                                  ),
                                );
                              }
                            },
                            child: const Text('Hubungkan'),
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
