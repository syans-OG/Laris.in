import 'package:flutter/material.dart';

class TutorialPage extends StatelessWidget {
  const TutorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tutorial',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TutorialSectionCard(
              title: 'Membuat Akun',
              imagePath: 'assets/tutorial/create_account.png',
              steps: const [
                'Buka aplikasi Laris.in',
                'Tekan tombol "Daftar" pada halaman login',
                'Isi nama lengkap Anda',
                'Masukkan email yang valid',
                'Buat password yang kuat',
                'Tekan tombol "Daftar" untuk menyelesaikan',
              ],
            ),
            const SizedBox(height: 16),
            TutorialSectionCard(
              title: 'Menambahkan Produk',
              imagePath: 'assets/tutorial/add_product.png',
              steps: const [
                'Buka menu Inventory dari navigation bar',
                'Tekan tombol tambah produk (+) di pojok kanan bawah',
                'Isi nama produk dengan jelas',
                'Masukkan harga jual produk',
                'Tambahkan stok awal (opsional)',
                'Masukkan kode SKU atau barcode',
                'Tekan tombol "Simpan" untuk menyimpan produk',
              ],
            ),
            const SizedBox(height: 16),
            TutorialSectionCard(
              title: 'Mengedit Produk',
              imagePath: 'assets/tutorial/edit_product.png',
              steps: const [
                'Buka menu Inventory',
                'Cari produk yang ingin diedit',
                'Tekan pada kartu produk atau tombol edit',
                'Ubah informasi yang diperlukan',
                'Tekan tombol "Simpan" untuk menyimpan perubahan',
              ],
            ),
            const SizedBox(height: 16),
            TutorialSectionCard(
              title: 'Menghapus Produk',
              imagePath: 'assets/tutorial/delete_product.png',
              steps: const [
                'Buka menu Inventory',
                'Cari produk yang ingin dihapus',
                'Tekan pada kartu produk',
                'Pilih opsi "Hapus" dari menu',
                'Konfirmasi penghapusan',
                'Produk akan dihapus dari sistem',
              ],
            ),
            const SizedBox(height: 16),
            TutorialSectionCard(
              title: 'Mengelola Inventory',
              imagePath: 'assets/tutorial/inventory.png',
              steps: const [
                'Buka menu Inventory',
                'Lihat daftar semua produk Anda',
                'Gunakan fitur pencarian untuk menemukan produk',
                'Filter produk berdasarkan kategori',
                'Periksa stok produk secara berkala',
                'Update stok saat melakukan restock',
                'Monitor produk yang hampir habis',
              ],
            ),
            const SizedBox(height: 16),
            TutorialSectionCard(
              title: 'Menggunakan Register/Kasir',
              imagePath: 'assets/tutorial/register.png',
              steps: const [
                'Buka menu Register dari navigation bar',
                'Cari produk menggunakan search bar atau scan barcode',
                'Tekan produk untuk menambahkan ke keranjang',
                'Atur jumlah produk jika perlu',
                'Periksa total belanja di bagian bawah',
                'Tekan tombol "BAYAR" untuk checkout',
                'Pilih metode pembayaran (Cash, QRIS, dll)',
                'Selesaikan transaksi dan cetak struk',
              ],
            ),
            const SizedBox(height: 16),
            TutorialSectionCard(
              title: 'Melihat Laporan',
              imagePath: 'assets/tutorial/report.png',
              steps: const [
                'Buka menu Laporan dari navigation bar',
                'Pilih periode laporan (hari ini, minggu ini, bulan ini)',
                'Lihat total penjualan dan pendapatan',
                'Periksa grafik penjualan',
                'Lihat produk terlaris',
                'Export laporan ke PDF atau Excel (jika tersedia)',
                'Analisis performa bisnis Anda',
              ],
            ),
            const SizedBox(height: 16),
            TutorialSectionCard(
              title: 'Pengaturan Aplikasi',
              imagePath: 'assets/tutorial/settings.png',
              steps: const [
                'Buka menu Settings dari navigation bar',
                'Atur profil bisnis Anda',
                'Konfigurasi printer untuk cetak struk',
                'Pilih tema aplikasi (Light/Dark)',
                'Atur preferensi mata uang',
                'Kelola metode pembayaran',
                'Atur notifikasi aplikasi',
              ],
            ),
            const SizedBox(height: 16),
            TutorialSectionCard(
              title: 'Backup & Restore Data',
              imagePath: 'assets/tutorial/backup_restore.png',
              steps: const [
                'Buka menu Settings',
                'Pilih opsi "Backup & Restore"',
                'Untuk backup: tekan "Backup Data Sekarang"',
                'Pilih lokasi penyimpanan backup',
                'Tunggu proses backup selesai',
                'Untuk restore: tekan "Restore Data"',
                'Pilih file backup yang ingin direstore',
                'Konfirmasi dan tunggu proses selesai',
              ],
            ),
            const SizedBox(height: 16),
            TutorialSectionCard(
              title: 'FAQ',
              imagePath: 'assets/tutorial/faq.png',
              steps: const [
                'Q: Bagaimana cara menghubungkan printer?',
                'A: Buka Settings > Printer, lalu pilih printer Bluetooth atau USB',
                '',
                'Q: Apakah data aman?',
                'A: Ya, semua data disimpan secara lokal dan dapat di-backup',
                '',
                'Q: Bisakah digunakan offline?',
                'A: Ya, aplikasi berfungsi penuh tanpa koneksi internet',
                '',
                'Q: Bagaimana menghubungi support?',
                'A: Email ke support@laris.in atau WhatsApp di Settings',
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class TutorialSectionCard extends StatefulWidget {
  final String title;
  final String imagePath;
  final List<String> steps;

  const TutorialSectionCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.steps,
  });

  @override
  State<TutorialSectionCard> createState() => _TutorialSectionCardState();
}

class _TutorialSectionCardState extends State<TutorialSectionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = theme.colorScheme.outline.withOpacity(
      isDark ? 0.35 : 0.22,
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color.fromRGBO(0, 0, 0, 0.18)
                : const Color.fromRGBO(0, 33, 20, 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        color: Color(0xFF059669),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            if (_isExpanded) ...[
              Divider(height: 1, thickness: 1, color: borderColor),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image placeholder
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 4.0,
                          child: Image.asset(
                            widget.imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Langkah-langkah:',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.steps.asMap().entries.map((entry) {
                      final index = entry.key;
                      final step = entry.value;

                      // Handle empty strings for spacing in FAQ
                      if (step.isEmpty) {
                        return const SizedBox(height: 12);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!step.startsWith('Q:') &&
                                !step.startsWith('A:'))
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF059669,
                                  ).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                ),
                              ),
                            if (!step.startsWith('Q:') &&
                                !step.startsWith('A:'))
                              const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                step,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: step.startsWith('Q:')
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: step.startsWith('Q:')
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
