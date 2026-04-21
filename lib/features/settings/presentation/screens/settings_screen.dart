import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../../core/theme/app_theme.dart';
import '../../../../features/settings/data/settings_repository.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../../../core/services/system/backup_service.dart';
import '../../../pos/domain/usecases/test_print_usecase.dart';
import 'manage_cashiers_screen.dart';
import 'printer_settings_screen.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../../core/di/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // States are now managed by ref.watch(providers)


  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur segera hadir'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // 1. Copy file ke folder internal aplikasi
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(image.path);
      final savedImage = await File(image.path).copy('${appDir.path}/$fileName');

      // 2. Simpan pathnya
      await ref.read(settingsRepositoryProvider).setLogoPath(savedImage.path);
      ref.read(logoPathProvider.notifier).state = savedImage.path;
    }
  }

  Future<void> _removeLogo() async {
    await ref.read(settingsRepositoryProvider).setLogoPath(null);
    ref.read(logoPathProvider.notifier).state = null;
  }

  Future<void> _showEditDialog({
    required String title,
    required String initialValue,
    StateProvider<String>? provider,
    required Future<void> Function(String) onSave,
    bool isNumeric = false,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Masukkan $title',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result != null) {
      await onSave(result);
      if (mounted && provider != null) {
        ref.read(provider.notifier).state = result;
      }
    }
  }

  Future<bool> _verifyAdminPIN() async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Verifikasi Admin'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Masukkan PIN Admin'),
          keyboardType: TextInputType.number,
          obscureText: true,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              final repo = ref.read(authRepositoryProvider);
              final cashiers = await repo.getActiveCashiers();
              final isAdmin = cashiers.any((c) => c.role == 'admin' && c.pin == controller.text);
              Navigator.pop(context, isAdmin);
            }, 
            child: const Text('Verifikasi'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _handleLogout() async {
    await ref.read(authRepositoryProvider).logout();
    ref.read(sessionProvider.notifier).state = null;
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _testPrint() async {
    final success = await ref.read(testPrintUseCaseProvider).execute();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Test print berhasil dikirim' : 'Gagal mencetak. Cek koneksi printer.'),
          backgroundColor: success ? AppColors.primary : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: AppColors.surfaceDark,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('INFORMASI TOKO'),
          Consumer(builder: (context, ref, _) {
            final name = ref.watch(storeNameProvider);
            return ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Nama Toko'),
              subtitle: Text(name, style: const TextStyle(color: AppColors.textMutedDark)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showEditDialog(
                title: 'Nama Toko',
                initialValue: name,
                provider: storeNameProvider,
                onSave: (val) => ref.read(settingsRepositoryProvider).setStoreName(val),
              ),
            );
          }),
          Consumer(builder: (context, ref, _) {
            final address = ref.watch(storeAddressProvider);
            return ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Alamat'),
              subtitle: Text(address, style: const TextStyle(color: AppColors.textMutedDark)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showEditDialog(
                title: 'Alamat',
                initialValue: address,
                provider: storeAddressProvider,
                onSave: (val) => ref.read(settingsRepositoryProvider).setStoreAddress(val),
              ),
            );
          }),
          Consumer(builder: (context, ref, _) {
            final phone = ref.watch(storePhoneProvider);
            return ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Nomor HP'),
              subtitle: Text(phone, style: const TextStyle(color: AppColors.textMutedDark)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showEditDialog(
                title: 'Nomor HP',
                initialValue: phone,
                provider: storePhoneProvider,
                onSave: (val) => ref.read(settingsRepositoryProvider).setStorePhone(val),
                isNumeric: true,
              ),
            );
          }),
          const Divider(height: 1, color: AppColors.borderDark),

          _buildSectionHeader('PRINTER STRUK'),
          ListTile(
            leading: const Icon(Icons.print),
            title: const Text('Printer Aktif'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrinterSettingsScreen()),
              );
            },
          ),
          Consumer(builder: (context, ref, _) {
            final size = ref.watch(paperSizeProvider);
            return ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Lebar Kertas'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${size}mm', style: const TextStyle(color: AppColors.textMutedDark)),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () async {
                final result = await showDialog<int>(
                  context: context,
                  builder: (_) => SimpleDialog(
                    title: const Text('Pilih Lebar Kertas'),
                    children: [
                      SimpleDialogOption(onPressed: () => Navigator.pop(context, 58), child: const Text('58mm (Kecil)')),
                      SimpleDialogOption(onPressed: () => Navigator.pop(context, 80), child: const Text('80mm (Besar)')),
                    ],
                  ),
                );
                if (result != null) {
                  await ref.read(settingsRepositoryProvider).setPaperSize(result);
                  ref.read(paperSizeProvider.notifier).state = result;
                }
              },
            );
          }),
          ListTile(
            leading: const Icon(Icons.grading),
            title: const Text('Test Print'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _testPrint,
          ),
          const Divider(height: 1, color: AppColors.borderDark),

          _buildSectionHeader('TAMPILAN STRUK'),
          Consumer(builder: (context, ref, _) {
            final enabled = ref.watch(showStoreNameProvider);
            return SwitchListTile(
              secondary: const Icon(Icons.storefront),
              title: const Text('Nama Toko (Header)'),
              value: enabled,
              activeThumbColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
              onChanged: (val) async {
                await ref.read(settingsRepositoryProvider).setShowStoreName(val);
                ref.read(showStoreNameProvider.notifier).state = val;
              },
            );
          }),
          Consumer(builder: (context, ref, _) {
            final enabled = ref.watch(showAddressProvider);
            return SwitchListTile(
              secondary: const Icon(Icons.place),
              title: const Text('Alamat & HP (Header)'),
              value: enabled,
              activeThumbColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
              onChanged: (val) async {
                await ref.read(settingsRepositoryProvider).setShowAddress(val);
                ref.read(showAddressProvider.notifier).state = val;
              },
            );
          }),
          Consumer(builder: (context, ref, _) {
            final enabled = ref.watch(showLogoProvider);
            final logoPath = ref.watch(logoPathProvider);
            return Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.image),
                  title: const Text('Logo'),
                  value: enabled,
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                  onChanged: (val) async {
                    await ref.read(settingsRepositoryProvider).setShowLogo(val);
                    ref.read(showLogoProvider.notifier).state = val;
                  },
                ),
                if (enabled) 
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListTile(
                      title: const Text('File Logo', style: TextStyle(fontSize: 14)),
                      subtitle: logoPath != null 
                        ? Text(path.basename(logoPath), overflow: TextOverflow.ellipsis) 
                        : const Text('Belum ada logo dipilih', style: TextStyle(color: AppColors.error)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (logoPath != null)
                            IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error), onPressed: _removeLogo),
                          IconButton(icon: const Icon(Icons.upload_file), onPressed: _pickLogo),
                        ],
                      ),
                      leading: logoPath != null 
                        ? Image.file(File(logoPath), width: 32, height: 32, fit: BoxFit.cover)
                        : const Icon(Icons.image_not_supported, size: 32),
                    ),
                  ),
              ],
            );
          }),
          Consumer(builder: (context, ref, _) {
            final footer = ref.watch(storeFooterProvider);
            return ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Pesan Kaki (Footer)'),
              subtitle: Text(footer, style: const TextStyle(color: AppColors.textMutedDark)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showEditDialog(
                title: 'Pesan Kaki',
                initialValue: footer,
                provider: storeFooterProvider,
                onSave: (val) => ref.read(settingsRepositoryProvider).setStoreFooter(val),
              ),
            );
          }),
          const Divider(height: 1, color: AppColors.borderDark),

          // ── TRANSAKSI ─────────────────────────────────────────
          _buildSectionHeader('TRANSAKSI'),

          // Toggle Pajak
          Consumer(
            builder: (context, ref, _) {
              final enabled = ref.watch(taxEnabledProvider);
              return SwitchListTile(
                secondary: const Icon(Icons.receipt_long),
                title: const Text('Aktifkan Pajak'),
                subtitle: const Text('Pajak ditambahkan ke total belanja'),
                value: enabled,
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                onChanged: (val) async {
                  await ref.read(settingsRepositoryProvider).setTaxEnabled(val);
                  ref.read(taxEnabledProvider.notifier).state = val;
                },
              );
            },
          ),

          // Input % Pajak
          Consumer(
            builder: (context, ref, _) {
              final taxEnabled = ref.watch(taxEnabledProvider);
              final taxRate = ref.watch(taxRateProvider);
              if (!taxEnabled) return const SizedBox.shrink();
              return ListTile(
                leading: const Icon(Icons.percent),
                title: const Text('Persentase Pajak'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${taxRate.toStringAsFixed(0)}%',
                        style:
                            const TextStyle(color: AppColors.textMutedDark)),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => _showTaxRateDialog(context, ref, taxRate),
              );
            },
          ),

          // Toggle Diskon
          Consumer(
            builder: (context, ref, _) {
              final enabled = ref.watch(discountEnabledProvider);
              return SwitchListTile(
                secondary: const Icon(Icons.local_offer_outlined),
                title: const Text('Aktifkan Diskon'),
                subtitle: const Text('Kasir bisa memberi diskon per transaksi'),
                value: enabled,
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                onChanged: (val) async {
                  await ref
                      .read(settingsRepositoryProvider)
                      .setDiscountEnabled(val);
                  ref.read(discountEnabledProvider.notifier).state = val;
                },
              );
            },
          ),
          const Divider(height: 1, color: AppColors.borderDark),

          _buildSectionHeader('KASIR & AKUN'),
          Consumer(builder: (context, ref, _) {
            final cashiersCount = ref.watch(cashierListProvider);
            return ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Kelola Kasir'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  cashiersCount.when(
                    data: (list) => Text('${list.length} aktif', style: const TextStyle(color: AppColors.textMutedDark)),
                    loading: () => const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                    error: (_, __) => const Icon(Icons.error_outline, size: 14, color: AppColors.error),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageCashiersScreen()));
              },
            );
          }),
          ListTile(
            leading: const Icon(Icons.pin),
            title: const Text('Ganti PIN'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final user = ref.read(sessionProvider);
              if (user == null) return;
              _showEditDialog(
                title: 'PIN Baru',
                initialValue: '',
                onSave: (val) async {
                  if (val.length == 4) {
                    await ref.read(cashierManagementProvider).updatePin(user.id, val);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN berhasil diubah')));
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN harus 4 digit'), backgroundColor: AppColors.error));
                    }
                  }
                },
                isNumeric: true,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Tema'),
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Gelap', style: TextStyle(color: AppColors.textMutedDark)),
                SizedBox(width: 8),
                Icon(Icons.chevron_right),
              ],
            ),
            onTap: () => _showComingSoon(context),
          ),
          const Divider(height: 1, color: AppColors.borderDark),

          _buildSectionHeader('DATA & SISTEM'),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup Database'),
            subtitle: const Text('Simpan data ke storage luar'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final success = await BackupService.backupDatabase();
              if (mounted && !success) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal melakukan backup'), backgroundColor: AppColors.error));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_backup_restore),
            title: const Text('Restore Database'),
            subtitle: const Text('Ganti data dengan file backup'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final isAdmin = await _verifyAdminPIN();
              if (!isAdmin) return;

              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Peringatan Restore!'),
                  content: const Text('RESTORE akan MENGHAPUS SEMUA DATA SAAT INI dan menggantinya dengan data dari file backup. Lanjutkan?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya, Ganti Data', style: TextStyle(color: AppColors.error))),
                  ],
                ),
              );

              if (confirm == true) {
                final success = await BackupService.restoreDatabase();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(success ? 'Restore Berhasil. Restart aplikasi untuk memuat data baru.' : 'Gagal memulihkan database'),
                    backgroundColor: success ? AppColors.primary : AppColors.error,
                  ));
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppColors.error),
            title: const Text('Hapus Data Transaksi', style: TextStyle(color: AppColors.error)),
            subtitle: const Text('Hapus semua riwayat penjualan'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final isAdmin = await _verifyAdminPIN();
              if (!isAdmin) return;

              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Hapus Seluruh Transaksi?'),
                  content: const Text('Tindakan ini tidak bisa dibatalkan. Riwayat penjualan Anda akan dikosongkan.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                    TextButton(
                      onPressed: () {
                        ref.read(transactionRepositoryProvider).deleteAllTransactions();
                        Navigator.pop(context, true);
                      }, 
                      child: const Text('Hapus Semua', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );

              if (mounted && confirm == true) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua data transaksi telah dihapus')));
              }
            },
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Versi App'),
            trailing: Text('v1.0.0', style: TextStyle(color: AppColors.textMutedDark)),
          ),
          const Divider(height: 1, color: AppColors.borderDark),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: FilledButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout),
              label: const Text('LOGOUT / TUTUP SESI', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textMutedDark,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Future<void> _showTaxRateDialog(
      BuildContext context, WidgetRef ref, double current) async {
    final controller =
        TextEditingController(text: current.toStringAsFixed(0));
    final result = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Persentase Pajak'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            suffixText: '%',
            hintText: 'Contoh: 11',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val >= 0 && val <= 100) {
                Navigator.pop(context, val);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (result != null) {
      await ref.read(settingsRepositoryProvider).setTaxRate(result);
      if (mounted) {
        ref.read(taxRateProvider.notifier).state = result;
      }
    }
  }
}
