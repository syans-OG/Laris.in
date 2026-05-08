import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../../core/theme/app_theme.dart';
import '../../../../features/settings/data/settings_repository.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, color: Color(0xFF191C1D))),
        content: TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Masukkan $title',
            hintStyle: const TextStyle(color: Color(0xFF8A9A90)),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF6D7A72), fontWeight: FontWeight.bold)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF006948),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
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
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Verifikasi Admin', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, color: Color(0xFF191C1D))),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Masukkan PIN Admin',
            hintStyle: const TextStyle(color: Color(0xFF8A9A90)),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          keyboardType: TextInputType.number,
          obscureText: true,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: const Text('Batal', style: TextStyle(color: Color(0xFF6D7A72), fontWeight: FontWeight.bold))
          ),
          FilledButton(
            onPressed: () async {
              final repo = ref.read(authRepositoryProvider);
              final cashiers = await repo.getActiveCashiers();
              final isAdmin = cashiers.any((c) => c.role == 'admin' && c.pin == controller.text);
              Navigator.pop(context, isAdmin);
            }, 
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF006948),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Verifikasi', style: TextStyle(fontWeight: FontWeight.bold)),
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            color: Color(0xFF191C1D),
          ),
        ),
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF191C1D)),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          _buildSectionHeader('INFORMASI TOKO'),
          _buildSectionCard([
            Consumer(builder: (context, ref, _) {
              final name = ref.watch(storeNameProvider);
              return _buildListTile(
                icon: Icons.store,
                title: 'Nama Toko',
                subtitle: name,
                onTap: () => _showEditDialog(
                  title: 'Nama Toko',
                  initialValue: name,
                  provider: storeNameProvider,
                  onSave: (val) => ref.read(settingsRepositoryProvider).setStoreName(val),
                ),
              );
            }),
            const Divider(height: 1, color: Color(0xFFEDEEEF)),
            Consumer(builder: (context, ref, _) {
              final address = ref.watch(storeAddressProvider);
              return _buildListTile(
                icon: Icons.location_on,
                title: 'Alamat',
                subtitle: address,
                onTap: () => _showEditDialog(
                  title: 'Alamat',
                  initialValue: address,
                  provider: storeAddressProvider,
                  onSave: (val) => ref.read(settingsRepositoryProvider).setStoreAddress(val),
                ),
              );
            }),
            const Divider(height: 1, color: Color(0xFFEDEEEF)),
            Consumer(builder: (context, ref, _) {
              final phone = ref.watch(storePhoneProvider);
              return _buildListTile(
                icon: Icons.phone,
                title: 'Nomor HP',
                subtitle: phone,
                isNumeric: true,
                onTap: () => _showEditDialog(
                  title: 'Nomor HP',
                  initialValue: phone,
                  provider: storePhoneProvider,
                  onSave: (val) => ref.read(settingsRepositoryProvider).setStorePhone(val),
                  isNumeric: true,
                ),
              );
            }),
          ]),

          _buildSectionHeader('PRINTER STRUK'),
          _buildSectionCard([
            _buildListTile(
              icon: Icons.print,
              title: 'Printer Aktif',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrinterSettingsScreen()),
                );
              },
            ),
            const Divider(height: 1, color: Color(0xFFEDEEEF)),
            Consumer(builder: (context, ref, _) {
              final size = ref.watch(paperSizeProvider);
              return _buildListTile(
                icon: Icons.receipt_long,
                title: 'Lebar Kertas',
                trailingText: '${size}mm',
                onTap: () async {
                  final result = await showDialog<int>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text('Pilih Lebar Kertas', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, color: Color(0xFF191C1D))),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('58mm (Kecil)', style: TextStyle(fontFamily: 'Plus Jakarta Sans')),
                            onTap: () => Navigator.pop(context, 58),
                          ),
                          ListTile(
                            title: const Text('80mm (Besar)', style: TextStyle(fontFamily: 'Plus Jakarta Sans')),
                            onTap: () => Navigator.pop(context, 80),
                          ),
                        ],
                      ),
                    ),
                  );
                  if (result != null) {
                    await ref.read(settingsRepositoryProvider).setPaperSize(result);
                    ref.read(paperSizeProvider.notifier).state = result;
                  }
                },
              );
            }),
            const Divider(height: 1, color: Color(0xFFEDEEEF)),
            _buildListTile(
              icon: Icons.grading,
              title: 'Test Print',
              onTap: _testPrint,
            ),
          ]),

          _buildSectionHeader('TAMPILAN STRUK'),
          _buildSectionCard([
            Consumer(builder: (context, ref, _) {
              final enabled = ref.watch(showStoreNameProvider);
              return _buildSwitchTile(
                icon: Icons.storefront,
                title: 'Nama Toko (Header)',
                value: enabled,
                onChanged: (val) async {
                  await ref.read(settingsRepositoryProvider).setShowStoreName(val);
                  ref.read(showStoreNameProvider.notifier).state = val;
                },
              );
            }),
            const Divider(height: 1, color: Color(0xFFEDEEEF)),
            Consumer(builder: (context, ref, _) {
              final enabled = ref.watch(showAddressProvider);
              return _buildSwitchTile(
                icon: Icons.place,
                title: 'Alamat & HP (Header)',
                value: enabled,
                onChanged: (val) async {
                  await ref.read(settingsRepositoryProvider).setShowAddress(val);
                  ref.read(showAddressProvider.notifier).state = val;
                },
              );
            }),
            const Divider(height: 1, color: Color(0xFFEDEEEF)),
            Consumer(builder: (context, ref, _) {
              final enabled = ref.watch(showLogoProvider);
              final logoPath = ref.watch(logoPathProvider);
              return Column(
                children: [
                  _buildSwitchTile(
                    icon: Icons.image,
                    title: 'Logo',
                    value: enabled,
                    onChanged: (val) async {
                      await ref.read(settingsRepositoryProvider).setShowLogo(val);
                      ref.read(showLogoProvider.notifier).state = val;
                    },
                  ),
                  if (enabled) ...[
                    const Divider(height: 1, color: Color(0xFFEDEEEF)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          logoPath != null 
                            ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(logoPath), width: 40, height: 40, fit: BoxFit.cover))
                            : Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image_not_supported, color: Color(0xFFBCCAC0))),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('File Logo', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF191C1D))),
                                logoPath != null 
                                  ? Text(path.basename(logoPath), style: const TextStyle(fontFamily: 'Space Mono', fontSize: 12, color: Color(0xFF6D7A72)), overflow: TextOverflow.ellipsis) 
                                  : const Text('Belum ada logo', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: Color(0xFFBA1A1A))),
                              ],
                            ),
                          ),
                          if (logoPath != null)
                            IconButton(icon: const Icon(Icons.delete_outline, color: Color(0xFFBA1A1A)), onPressed: _removeLogo),
                          IconButton(icon: const Icon(Icons.upload_file, color: Color(0xFF006948)), onPressed: _pickLogo),
                        ],
                      ),
                    ),
                  ]
                ],
              );
            }),
            const Divider(height: 1, color: Color(0xFFEDEEEF)),
            Consumer(builder: (context, ref, _) {
              final footer = ref.watch(storeFooterProvider);
              return _buildListTile(
                icon: Icons.text_fields,
                title: 'Pesan Kaki (Footer)',
                subtitle: footer,
                onTap: () => _showEditDialog(
                  title: 'Pesan Kaki',
                  initialValue: footer,
                  provider: storeFooterProvider,
                  onSave: (val) => ref.read(settingsRepositoryProvider).setStoreFooter(val),
                ),
              );
            }),
          ]),

          _buildSectionHeader('TRANSAKSI'),
          _buildSectionCard([
            Consumer(
              builder: (context, ref, _) {
                final enabled = ref.watch(taxEnabledProvider);
                return _buildSwitchTile(
                  icon: Icons.receipt_long,
                  title: 'Aktifkan Pajak',
                  subtitle: 'Pajak ditambahkan ke total belanja',
                  value: enabled,
                  onChanged: (val) async {
                    await ref.read(settingsRepositoryProvider).setTaxEnabled(val);
                    ref.read(taxEnabledProvider.notifier).state = val;
                  },
                );
              },
            ),
            Consumer(
              builder: (context, ref, _) {
                final taxEnabled = ref.watch(taxEnabledProvider);
                final taxRate = ref.watch(taxRateProvider);
                if (!taxEnabled) return const SizedBox.shrink();
                return Column(
                  children: [
                    const Divider(height: 1, color: Color(0xFFEDEEEF)),
                    _buildListTile(
                      icon: Icons.percent,
                      title: 'Persentase Pajak',
                      trailingText: '${taxRate.toStringAsFixed(0)}%',
                      onTap: () => _showTaxRateDialog(context, ref, taxRate),
                    ),
                  ],
                );
              },
            ),
            const Divider(height: 1, color: Color(0xFFEDEEEF)),
            Consumer(
              builder: (context, ref, _) {
                final enabled = ref.watch(discountEnabledProvider);
                return _buildSwitchTile(
                  icon: Icons.local_offer_outlined,
                  title: 'Aktifkan Diskon',
                  subtitle: 'Kasir bisa memberi diskon per transaksi',
                  value: enabled,
                  onChanged: (val) async {
                    await ref.read(settingsRepositoryProvider).setDiscountEnabled(val);
                    ref.read(discountEnabledProvider.notifier).state = val;
                  },
                );
              },
            ),
          ]),

          _buildSectionHeader('KASIR & AKUN'),
          _buildSectionCard([
            Consumer(builder: (context, ref, _) {
              final cashiersCount = ref.watch(cashierListProvider);
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.people, color: Color(0xFF6D7A72)),
                ),
                title: const Text('Kelola Kasir', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF191C1D))),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    cashiersCount.when(
                      data: (list) => Text('${list.length} aktif', style: const TextStyle(fontFamily: 'Space Mono', color: Color(0xFF6D7A72), fontSize: 12)),
                      loading: () => const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF006948))),
                      error: (_, __) => const Icon(Icons.error_outline, size: 14, color: Color(0xFFBA1A1A)),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: Color(0xFFBCCAC0)),
                  ],
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageCashiersScreen()));
                },
              );
            }),
            const Divider(height: 1, color: Color(0xFFEDEEEF)),
            _buildListTile(
              icon: Icons.pin,
              title: 'Ganti PIN',
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
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN harus 4 digit'), backgroundColor: Color(0xFFBA1A1A)));
                      }
                    }
                  },
                  isNumeric: true,
                );
              },
            ),
            const Divider(height: 1, color: Color(0xFFEDEEEF)),
            _buildListTile(
              icon: Icons.palette,
              title: 'Tema',
              trailingText: 'Gelap',
              onTap: () => _showComingSoon(context),
            ),
          ]),

          _buildSectionHeader('DATA & SISTEM'),
          _buildSectionCard([
            _buildListTile(
              icon: Icons.backup,
              title: 'Backup Database',
              subtitle: 'Simpan data ke storage luar',
              onTap: () async {
                final success = await BackupService.backupDatabase();
                if (mounted && !success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal melakukan backup'), backgroundColor: Color(0xFFBA1A1A)));
                }
              },
            ),
            const Divider(height: 1, color: Color(0xFFEDEEEF)),
            _buildListTile(
              icon: Icons.settings_backup_restore,
              title: 'Restore Database',
              subtitle: 'Ganti data dengan file backup',
              onTap: () async {
                final isAdmin = await _verifyAdminPIN();
                if (!isAdmin) return;

                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Peringatan Restore!', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, color: Color(0xFFBA1A1A))),
                    content: const Text('RESTORE akan MENGHAPUS SEMUA DATA SAAT INI dan menggantinya dengan data dari file backup. Lanjutkan?', style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: Color(0xFF3D4A42))),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal', style: TextStyle(color: Color(0xFF6D7A72), fontWeight: FontWeight.bold))),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFFBA1A1A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () => Navigator.pop(context, true), 
                        child: const Text('Ya, Ganti Data', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  final success = await BackupService.restoreDatabase();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(success ? 'Restore Berhasil. Restart aplikasi untuk memuat data baru.' : 'Gagal memulihkan database'),
                      backgroundColor: success ? const Color(0xFF006948) : const Color(0xFFBA1A1A),
                    ));
                  }
                }
              },
            ),
            const Divider(height: 1, color: Color(0xFFEDEEEF)),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF9EAEB), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.delete_forever, color: Color(0xFFBA1A1A)),
              ),
              title: const Text('Hapus Data Transaksi', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFBA1A1A))),
              subtitle: const Text('Hapus semua riwayat penjualan', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: Color(0xFFBA1A1A))),
              trailing: const Icon(Icons.chevron_right, color: Color(0xFFBCCAC0)),
              onTap: () async {
                final isAdmin = await _verifyAdminPIN();
                if (!isAdmin) return;

                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Hapus Seluruh Transaksi?', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, color: Color(0xFFBA1A1A))),
                    content: const Text('Tindakan ini tidak bisa dibatalkan. Riwayat penjualan Anda akan dikosongkan.', style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: Color(0xFF3D4A42))),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal', style: TextStyle(color: Color(0xFF6D7A72), fontWeight: FontWeight.bold))),
                      FilledButton(
                        onPressed: () {
                          ref.read(transactionRepositoryProvider).deleteAllTransactions();
                          Navigator.pop(context, true);
                        }, 
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFFBA1A1A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('Hapus Semua', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );

                if (mounted && confirm == true) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua data transaksi telah dihapus')));
                }
              },
            ),
            const Divider(height: 1, color: Color(0xFFEDEEEF)),
            _buildListTile(
              icon: Icons.info,
              title: 'Versi App',
              trailingText: 'v1.0.0',
            ),
          ]),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: FilledButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout),
              label: const Text('LOGOUT / TUTUP SESI', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFBA1A1A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
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
      padding: const EdgeInsets.fromLTRB(32, 24, 24, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          color: Color(0xFF6D7A72),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFEDEEEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingText,
    VoidCallback? onTap,
    bool isNumeric = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: const Color(0xFF6D7A72)),
      ),
      title: Text(title, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF191C1D))),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontFamily: isNumeric ? 'Space Mono' : 'Plus Jakarta Sans', fontSize: 12, color: const Color(0xFF6D7A72))) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText, style: const TextStyle(fontFamily: 'Space Mono', color: Color(0xFF6D7A72), fontSize: 12)),
          if (trailingText != null) const SizedBox(width: 8),
          if (onTap != null) const Icon(Icons.chevron_right, color: Color(0xFFBCCAC0)),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: const Color(0xFF6D7A72)),
      ),
      title: Text(title, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF191C1D))),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: Color(0xFF6D7A72))) : null,
      value: value,
      activeThumbColor: Colors.white,
      activeTrackColor: const Color(0xFF006948),
      inactiveThumbColor: const Color(0xFF8A9A90),
      inactiveTrackColor: const Color(0xFFEDEEEF),
      onChanged: onChanged,
    );
  }

  Future<void> _showTaxRateDialog(BuildContext context, WidgetRef ref, double current) async {
    final controller = TextEditingController(text: current.toStringAsFixed(0));
    final result = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Persentase Pajak', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, color: Color(0xFF191C1D))),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            suffixText: '%',
            hintText: 'Contoh: 11',
            hintStyle: const TextStyle(color: Color(0xFF8A9A90)),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF6D7A72), fontWeight: FontWeight.bold)),
          ),
          FilledButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val >= 0 && val <= 100) {
                Navigator.pop(context, val);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF006948),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
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
