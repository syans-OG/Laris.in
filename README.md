<div align="center">
  <h1>🚀 Laris.in (POS System)</h1>
  <p>Aplikasi Kasir (Point of Sales) Modern, Cepat, dan Berjalan Secara Offline.</p>
</div>

---

**Laris.in** adalah aplikasi Point of Sales (POS) berbasis mobile yang dibangun menggunakan **Flutter**. Aplikasi ini dirancang untuk memudahkan para pemilik Usaha Mikro, Kecil, dan Menengah (UMKM) dalam mengelola transaksi kasir, inventaris produk, hingga mencetak struk secara bluetooth. Aplikasi ini mendukung fungsionalitas **Offline-first**, sehingga Anda tetap bisa melakukan penjualan walau tidak ada koneksi internet.

## ✨ Fitur Utama

- 🛒 **Manajemen Kasir (POS)**: Sistem keranjang, checkout pembayaran yang cepat, dan antarmuka yang bersih.
- 📦 **Manajemen Produk**: Tambah, ubah, atau hapus produk dan kategori barang.
- 📸 **Scanner Barcode & QR Code**: Mendukung pemindaian barcode langsung menggunakan kamera perangkat (`mobile_scanner`).
- 🖨️ **Integrasi Printer Thermal**: Mendukung pencetakan struk transaksi, baik lewat Bluetooth atau USB thermal printer.
- 📂 **Import/Export Data**: Fitur memasukkan banyak produk sekaligus menggunakan file `CSV`.
- 📊 **Riwayat Transaksi**: Lacak dan pantau data histori penjualan.
- 💾 **Offline-first Database**: Seluruh data disimpan dan dapat diakses dengan cepat berkat integrasi SQLite lokal.
- 🌓 **Tema Custom**: Mendukung mode gelap (*Dark Mode*) dengan manajemen tema yang rapi.

## 🛠️ Tech Stack & Library

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [Riverpod](https://riverpod.dev/) (`flutter_riverpod`, `riverpod_annotation`)
- **Dependency Injection**: [GetIt](https://pub.dev/packages/get_it) & [Injectable](https://pub.dev/packages/injectable)
- **Local Database**: [SQLite3](https://pub.dev/packages/sqlite3)
- **Printer & Bluetooth**: `print_bluetooth_thermal`, `flutter_thermal_printer`, `esc_pos_utils_plus`
- **Networking**: `dio`, `retrofit` (Untuk keperluan integrasi online/sinkronisasi jika dibutuhkan)
- **Architecture**: Domain-Driven Design (DDD) atau Modular Feature-based Architecture.

## 📂 Struktur Folder Proyek

```text
lib/
├── core/             # Konfigurasi, routing, network, storage, theme
├── features/         # Modul fungsional (Domain, Data, Presentation)
│   ├── history/      # Fitur riwayat transaksi
│   ├── pos/          # Fitur Point of Sales (mesin kasir)
│   ├── products/     # Fitur pengelolaan produk dan kategori
│   ├── settings/     # Fitur pengaturan (termasuk printer)
│   └── transactions/ # Domain core untuk entitas & operasi transaksi
├── shared/           # Widget global dan layout yang dipakai bersama
└── main.dart         # Entry point aplikasi
```

## 🚀 Cara Menjalankan Project

1. **Pastikan prasyarat sudah terinstall**
   - Flutter SDK (`>= 3.10.1`)
   - Dart SDK
   - Android Studio / Xcode

2. **Clone repositori ini**
   ```bash
   git clone https://github.com/syans-OG/Laris.in.git
   cd Laris.in
   ```

3. **Install *Dependencies***
   ```bash
   flutter pub get
   ```

4. **Jalankan *Code Generation* (Riverpod & Injectable)**
   Jika Anda mengubah *providers* atau struktur database, pastikan menjalankan Build Runner:
   ```bash
   dart run build_runner build -d
   ```

5. **Jalankan Aplikasi**
   ```bash
   flutter run
   ```

---
Dibuat dengan ❤️ untuk kemajuan UMKM.
