import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'printer_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Mock states for UI
  bool _showStoreName = true;
  bool _showAddress = true;
  bool _showLogo = false;

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur segera hadir'),
        duration: Duration(seconds: 1),
      ),
    );
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
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Nama Toko'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showComingSoon(context),
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Alamat'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showComingSoon(context),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Nomor HP'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showComingSoon(context),
          ),
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
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Lebar Kertas'),
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('58mm', style: TextStyle(color: AppColors.textMutedDark)),
                SizedBox(width: 8),
                Icon(Icons.chevron_right),
              ],
            ),
            onTap: () => _showComingSoon(context),
          ),
          ListTile(
            leading: const Icon(Icons.grading),
            title: const Text('Test Print'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showComingSoon(context),
          ),
          const Divider(height: 1, color: AppColors.borderDark),

          _buildSectionHeader('TAMPILAN STRUK'),
          SwitchListTile(
            secondary: const Icon(Icons.storefront),
            title: const Text('Nama Toko'),
            value: _showStoreName,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
            onChanged: (val) => setState(() => _showStoreName = val),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.place),
            title: const Text('Alamat'),
            value: _showAddress,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
            onChanged: (val) => setState(() => _showAddress = val),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.image),
            title: const Text('Logo'),
            value: _showLogo,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
            onChanged: (val) => setState(() => _showLogo = val),
          ),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Pesan Kaki'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showComingSoon(context),
          ),
          const Divider(height: 1, color: AppColors.borderDark),

          _buildSectionHeader('KASIR & AKUN'),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Kelola Kasir'),
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('1 aktif', style: TextStyle(color: AppColors.textMutedDark)),
                SizedBox(width: 8),
                Icon(Icons.chevron_right),
              ],
            ),
            onTap: () => _showComingSoon(context),
          ),
          ListTile(
            leading: const Icon(Icons.pin),
            title: const Text('Ganti PIN'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showComingSoon(context),
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

          _buildSectionHeader('DATA & BACKUP'),
          ListTile(
            leading: const Icon(Icons.import_export),
            title: const Text('Ekspor Data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showComingSoon(context),
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup Database'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showComingSoon(context),
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
              onPressed: () => _showComingSoon(context),
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
}
