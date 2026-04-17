# PRD-001 · Aplikasi Kasir — Fitur & Backend

> **Versi:** 1.0 · **Status:** Draft · **Platform:** Flutter · **Tanggal:** Maret 2026

---

## Daftar Isi

1. [Overview & Tujuan Produk](#1-overview--tujuan-produk)
2. [Scope & Batasan](#2-scope--batasan)
3. [Arsitektur Teknis](#3-arsitektur-teknis)
4. [Skema Database](#4-skema-database)
5. [Spesifikasi Fitur Detail](#5-spesifikasi-fitur-detail)
6. [API Specification](#6-api-specification-cloud-sync--phase-2)
7. [Non-Functional Requirements](#7-non-functional-requirements)
8. [Development Roadmap](#8-development-roadmap)

---

## 1. Overview & Tujuan Produk

Aplikasi Kasir adalah sistem **point-of-sale (POS)** berbasis Flutter yang dirancang untuk toko retail kecil-menengah di Indonesia. Aplikasi berjalan di Android tablet dan smartphone, mendukung scan barcode fisik maupun kamera, serta dapat mencetak struk langsung ke thermal printer Bluetooth/WiFi.

### 1.1 Problem Statement

- Kasir manual (tulis tangan / Excel) lambat dan rawan kesalahan hitung
- Solusi POS berbayar terlalu mahal untuk toko kecil
- Aplikasi yang ada tidak support printer Bluetooth lokal Indonesia
- Tidak ada laporan penjualan otomatis yang mudah dipahami pemilik toko

### 1.2 Target Pengguna

| Persona | Peran | Kebutuhan Utama |
|---|---|---|
| Kasir | Operator harian | Scan cepat, tambah item, proses bayar, cetak struk |
| Pemilik Toko | Admin / owner | Kelola produk, lihat laporan, atur harga & diskon |
| Supervisor | Manager shift | Buka/tutup shift, rekap transaksi harian |

### 1.3 Sasaran Bisnis

- Proses transaksi **< 30 detik** per pelanggan
- **Zero downtime** saat internet mati (full offline mode)
- Support minimal **10.000 SKU** produk tanpa lag
- Print struk **< 3 detik** setelah konfirmasi bayar

---

## 2. Scope & Batasan

### 2.1 In Scope — MVP

| # | Fitur | Prioritas | Sprint |
|---|---|---|---|
| F-01 | Scan barcode (kamera + USB HID) | P0 - Must Have | Sprint 1 |
| F-02 | Manajemen produk (CRUD + import CSV) | P0 - Must Have | Sprint 1 |
| F-03 | Keranjang belanja & hitung total | P0 - Must Have | Sprint 1 |
| F-04 | Proses pembayaran tunai + kembalian | P0 - Must Have | Sprint 1 |
| F-05 | Print struk Bluetooth thermal printer | P0 - Must Have | Sprint 2 |
| F-06 | Riwayat transaksi harian | P0 - Must Have | Sprint 2 |
| F-07 | Diskon per item / per transaksi | P1 - Should Have | Sprint 2 |
| F-08 | Pembayaran QRIS (static QR) | P1 - Should Have | Sprint 3 |
| F-09 | Laporan penjualan harian / mingguan | P1 - Should Have | Sprint 3 |
| F-10 | Manajemen stok & notif stok rendah | P1 - Should Have | Sprint 3 |
| F-11 | Multi kasir (login per user) | P2 - Nice to Have | Sprint 4 |
| F-12 | Sinkronisasi data ke cloud | P2 - Nice to Have | Sprint 4 |
| F-13 | Export laporan ke PDF / Excel | P2 - Nice to Have | Sprint 4 |

### 2.2 Out of Scope

- Integrasi payment gateway (GoPay, OVO, Dana) — fase berikutnya
- E-commerce / online store integration
- Akuntansi & laporan pajak otomatis
- Multi-cabang dengan server terpusat
- iOS (Apple) — tidak dalam MVP

---

## 3. Arsitektur Teknis

### 3.1 Tech Stack

| Layer | Teknologi | Keterangan |
|---|---|---|
| Frontend / UI | Flutter 3.x (Dart) | Cross-platform, Android tablet + HP |
| State Management | Riverpod 2.x | Provider pattern, testable |
| Local Database | SQLite via drift | ORM typed, migrasi otomatis |
| Barcode Scanner | mobile_scanner 5.x | ZXing engine, kamera + USB HID |
| Bluetooth Print | flutter_thermal_printer | Support ESC/POS, Xprinter, Epson |
| HTTP Client | Dio + Retrofit | REST API, interceptors, error handling |
| Local Storage | Hive / SharedPreferences | Settings, cache ringan |
| Dependency Inject | get_it + injectable | Service locator pattern |
| Testing | flutter_test + mocktail | Unit + widget + integration test |

### 3.2 Arsitektur — Clean Architecture

Aplikasi menggunakan **Clean Architecture** dengan 3 layer utama:

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│   Flutter Widgets · Riverpod Providers  │
│           Screen / Page files           │
├─────────────────────────────────────────┤
│             Domain Layer                │
│  Use Cases · Entities · Repo interfaces │
│       (pure Dart, no Flutter dep)       │
├─────────────────────────────────────────┤
│              Data Layer                 │
│  Repository impl · Local DS (SQLite)    │
│         Remote DS (REST API)            │
└─────────────────────────────────────────┘
```

> **Prinsip:** Dependency hanya mengalir dari luar ke dalam (UI → Domain ← Data).
> Domain layer tidak boleh import Flutter atau package eksternal apapun.

### 3.3 Struktur Folder

```
lib/
├── core/                 # constants, errors, utils, theme
├── features/
│   ├── pos/              # scan, cart, checkout (F-01..F-05)
│   ├── products/         # CRUD produk, import CSV (F-02)
│   ├── transactions/     # riwayat, detail struk (F-06)
│   ├── reports/          # laporan harian/mingguan (F-09)
│   └── auth/             # login kasir, session (F-11)
└── shared/
    ├── widgets/          # komponen UI reusable
    └── services/         # printer, barcode, storage
```

---

## 4. Skema Database (SQLite / Drift)

### 4.1 Tabel Utama

| Tabel | Kolom Utama | Relasi |
|---|---|---|
| `products` | id, barcode, name, price, cost_price, stock, category_id, image_url, is_active | → categories, → transaction_items |
| `categories` | id, name, color, icon, sort_order | ← products |
| `transactions` | id, invoice_no, total, discount, tax, payment_method, paid_amount, change, cashier_id, created_at | → transaction_items, → users |
| `transaction_items` | id, transaction_id, product_id, qty, unit_price, discount, subtotal | ← transactions, → products |
| `users` | id, name, pin, role (cashier/admin), is_active, last_login | ← transactions |
| `settings` | key, value | — singleton key-value |
| `stock_adjustments` | id, product_id, delta, reason, user_id, created_at | → products, → users |

### 4.2 Indeks Penting

```sql
CREATE UNIQUE INDEX idx_products_barcode  ON products(barcode);
CREATE INDEX idx_transactions_created_at  ON transactions(created_at);
CREATE INDEX idx_items_transaction_id     ON transaction_items(transaction_id);
CREATE INDEX idx_products_category_id     ON products(category_id);
```

> **Offline-First Strategy:** Semua data disimpan lokal di SQLite. Jika fitur cloud sync aktif,
> data dikirim ke server secara background (queue + retry). Transaksi tidak pernah tertunda karena koneksi.

---

## 5. Spesifikasi Fitur Detail

### F-01 · Scan Barcode

#### Use Cases

- **UC-01.1** Kasir tap tombol SCAN → kamera aktif → arahkan ke barcode → produk otomatis masuk cart
- **UC-01.2** USB HID barcode gun dihubungkan → scan langsung input ke field aktif tanpa tombol
- **UC-01.3** Barcode tidak ditemukan → tampil dialog *"Produk belum ada, tambah sekarang?"*

#### Acceptance Criteria

- [ ] Scan-to-cart **< 1 detik** setelah barcode terbaca
- [ ] Support format: EAN-13, EAN-8, QR Code, Code 128, Code 39
- [ ] Kamera auto-focus dan auto-torch saat pencahayaan rendah
- [ ] Multiple scan mode: satu item atau continuous scan

#### Package

```yaml
# pubspec.yaml
dependencies:
  mobile_scanner: ^5.1.0
```

---

### F-05 · Print Struk Bluetooth

#### Use Cases

- **UC-05.1** Setelah konfirmasi bayar → app auto-connect ke printer terakhir → print struk ESC/POS
- **UC-05.2** Kasir bisa pilih printer dari daftar Bluetooth device yang ter-paired
- **UC-05.3** Print ulang struk dari riwayat transaksi

#### Format Struk (ESC/POS)

```
================================
        TOKO MAJU JAYA
  Jl. Sudirman No. 1, Jakarta
================================
No  : INV-20260314-0001
Kasir: Budi    14/03/2026 09:30
--------------------------------
Aqua 600ml       2 x   4.000
                         8.000
Indomie Goreng   1 x   3.500
                         3.500
--------------------------------
Subtotal                11.500
Diskon (10%)            -1.150
TOTAL                   10.350
Tunai                   15.000
Kembali                  4.650
================================
   Terima kasih sudah belanja!
================================
```

#### Acceptance Criteria

- [ ] Auto-reconnect jika printer Bluetooth terputus
- [ ] Print dalam **< 3 detik**
- [ ] Support paper width: **58mm** dan **80mm** (setting di app)
- [ ] Fallback: jika print gagal, tampil preview struk di layar untuk screenshot

---

### F-09 · Laporan Penjualan

| Laporan | Periode | Data Ditampilkan |
|---|---|---|
| Ringkasan Harian | Per hari | Total transaksi, total omset, item terjual terbanyak |
| Detail Transaksi | Per hari / range | Daftar semua transaksi dengan detail item |
| Performa Produk | Mingguan / bulanan | Ranking produk by qty terjual & revenue |
| Laporan Stok | Real-time | Stok saat ini, produk hampir habis (< 5 unit) |
| Rekap Shift | Per shift | Transaksi per kasir, total kas masuk |

---

## 6. API Specification (Cloud Sync — Phase 2)

### 6.1 Base Config

```
Base URL : https://api.kasir-app.id/v1
Auth     : Bearer Token (JWT) — header Authorization
Response : { "success": bool, "data": any, "message": string }
```

### 6.2 Endpoints

| Method | Endpoint | Deskripsi | Auth |
|---|---|---|---|
| `POST` | `/auth/login` | Login kasir dengan PIN | No |
| `GET` | `/products` | List produk (pagination, filter) | Yes |
| `POST` | `/products` | Tambah produk baru | Yes (admin) |
| `PUT` | `/products/:id` | Update produk | Yes (admin) |
| `GET` | `/products/barcode/:code` | Lookup by barcode | Yes |
| `POST` | `/transactions` | Simpan transaksi baru | Yes |
| `GET` | `/transactions` | List transaksi (filter date) | Yes |
| `GET` | `/reports/daily` | Laporan harian | Yes (admin) |
| `POST` | `/sync/push` | Push data offline ke server | Yes |
| `GET` | `/sync/pull` | Ambil update dari server | Yes |

---

## 7. Non-Functional Requirements

| Kategori | Requirement | Target |
|---|---|---|
| Performance | Waktu load app pertama | < 3 detik (cold start) |
| Performance | Lookup barcode di database | < 200ms untuk 10.000 SKU |
| Performance | Render daftar produk | < 16ms per frame (60fps) |
| Availability | Operasi offline | 100% fitur core tanpa internet |
| Security | Data transaksi | Enkripsi SQLite dengan SQLCipher |
| Security | Login kasir | PIN 4-6 digit, lockout setelah 5x salah |
| Reliability | Crash rate | < 0.1% dari total sesi |
| Compatibility | Android version | Android 8.0 (API 26) ke atas |
| Compatibility | Screen size | Tablet 7"-12" dan HP 5"-7" |

---

## 8. Development Roadmap

### Sprint Plan (2 minggu per sprint)

| Sprint | Durasi | Deliverable | Fitur |
|---|---|---|---|
| Sprint 1 | 2 minggu | Alpha Internal | F-01 Scan Barcode, F-02 Manajemen Produk, F-03 Keranjang, F-04 Bayar Tunai |
| Sprint 2 | 2 minggu | Beta Kasir | F-05 Print Struk BT, F-06 Riwayat Transaksi, F-07 Diskon |
| Sprint 3 | 2 minggu | Beta Pemilik | F-08 QRIS, F-09 Laporan, F-10 Manajemen Stok |
| Sprint 4 | 2 minggu | Release Candidate | F-11 Multi Kasir, F-12 Cloud Sync, F-13 Export |
| Sprint 5 | 2 minggu | v1.0 Production | Bug fix, performance tuning, Play Store submission |

### Definition of Done — Setiap Fitur

- [ ] Unit test coverage > 80% pada domain & data layer
- [ ] Widget test untuk screen utama
- [ ] Tested di Android tablet (10") dan HP (6")
- [ ] Offline mode verified (airplane mode test)
- [ ] Performance: tidak ada jank (< 16ms frame time)

---

*PRD-001 · Kasir App — Fitur & Backend · Versi 1.0 · Maret 2026*
