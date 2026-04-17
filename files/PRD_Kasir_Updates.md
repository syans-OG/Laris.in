# PRD-003 · Aplikasi Kasir — Feature Updates & Improvements

> **Versi:** 1.0 · **Status:** Draft · **Tipe:** Update PRD
> **Referensi:** PRD-001 (Backend), PRD-002 (UI/Frontend)
> **Tanggal:** Maret 2026

---

## Daftar Isi

1. [Ringkasan Update](#1-ringkasan-update)
2. [UPDATE-01 · Responsive Layout](#2-update-01--responsive-layout)
3. [UPDATE-02 · Inventory Import Massal](#3-update-02--inventory-import-massal)
4. [UPDATE-03 · Digital Struk & Print Flow](#4-update-03--digital-struk--print-flow)
5. [Perubahan Database Schema](#5-perubahan-database-schema)
6. [Perubahan UI Components](#6-perubahan-ui-components)
7. [Sprint Re-planning](#7-sprint-re-planning)
8. [Decision Log](#8-decision-log)

---

## 1. Ringkasan Update

Dokumen ini mencatat semua perubahan fitur hasil sesi brainstorming
yang belum tercakup di PRD-001 dan PRD-002.

| # | Update | Area | Sprint | Prioritas |
|---|---|---|---|---|
| UPDATE-01 | Responsive layout HP portrait + tablet | UI/Frontend | Sprint 1 | P0 |
| UPDATE-02A | Import produk via CSV / Excel | Inventory | Sprint 2 | P0 |
| UPDATE-02B | Batch scan mode — tambah produk massal | Inventory | Sprint 2 | P1 |
| UPDATE-02C | AI foto produk — OCR otomatis | Inventory | Sprint 4 | P2 |
| UPDATE-02D | Barcode public database lookup | Inventory | Sprint 3 | P2 |
| UPDATE-03A | Digital struk screen post-checkout | Print/UX | Sprint 2 | P0 |
| UPDATE-03B | Pisah transaksi simpan vs print | Backend | Sprint 2 | P0 |
| UPDATE-03C | Share struk via WhatsApp | Print/UX | Sprint 3 | P1 |
| UPDATE-03D | Simpan struk sebagai gambar | Print/UX | Sprint 3 | P2 |

---

## 2. UPDATE-01 · Responsive Layout

### 2.1 Latar Belakang

UI awal dari Stitch hanya dioptimalkan untuk tablet landscape.
Kasir yang menggunakan HP portrait membutuhkan layout yang berbeda
karena tidak ada ruang untuk split panel kiri-kanan.

### 2.2 Tiga Breakpoint Wajib

| Breakpoint | Lebar Layar | Layout |
|---|---|---|
| HP Portrait | `< 600dp` | Single column, cart sebagai bottom sheet |
| HP Landscape | `600–840dp` | Split 60/40, bottom nav → NavigationRail |
| Tablet Landscape | `> 840dp` | Split 60/40, NavigationRail permanent (sudah ada) |

### 2.3 Spesifikasi HP Portrait

**Top Bar:**
- Height dikurangi ke 52dp
- Tombol "Tutup Shift" → icon-only (power icon) untuk hemat ruang
- Jam tetap prominent di tengah

**Product Area:**
- Search bar full-width dengan icon scan inline di kanan
- Category chips: horizontal scroll
- Product grid: 2 kolom fixed

**Cart — Persistent Bottom Sheet:**

```
STATE 1 — Cart Kosong:
┌────────────────────────────────┐
│  🛒  Keranjang kosong  [▦scan] │  ← height: 64dp
└────────────────────────────────┘
[TAB] [TAB] [TAB] [TAB]           ← bottom nav

STATE 2 — Ada Item (collapsed):
┌────────────────────────────────┐
│  ──── (drag handle)            │
│  🛒 3 item        Rp 24.500 [BAYAR] │  ← height: 80dp
└────────────────────────────────┘
[TAB] [TAB] [TAB] [TAB]

STATE 3 — Expanded (drag up):
┌────────────────────────────────┐
│  ──── (drag handle)            │
│  KERANJANG              Hapus  │
│  ─────────────────────────     │
│  Es Kopi Susu  2  [-][2][+]    │
│  Nasi Goreng   1  [-][1][+]    │
│  ─────────────────────────     │
│  Subtotal          Rp 35.000   │
│  Diskon            -Rp 10.500  │
│  TOTAL             Rp 24.500   │
│  [Tunai] [QRIS] [Transfer]     │
│  [       BAYAR              ]  │
└────────────────────────────────┘
```

**Implementasi Flutter:**
```dart
DraggableScrollableSheet(
  initialChildSize: 0.12,   // collapsed: ~80dp
  minChildSize: 0.10,        // minimum peek
  maxChildSize: 0.72,        // expanded: 72% layar
  snap: true,
  snapSizes: [0.12, 0.72],  // snap ke dua posisi
)
```

### 2.4 Acceptance Criteria

- [ ] Layout tidak pecah saat rotasi HP portrait ↔ landscape
- [ ] Cart state dipertahankan saat orientasi berubah
- [ ] Bottom sheet bisa di-drag naik dan turun dengan smooth
- [ ] Snap ke dua posisi: collapsed (80dp) dan expanded (72%)
- [ ] Bottom navigation tetap visible saat sheet collapsed
- [ ] Tidak ada overflow pixel di semua breakpoint
- [ ] Test di: HP 5" portrait, HP 6" landscape, Tablet 10" landscape

---

## 3. UPDATE-02 · Inventory Import Massal

### 3.1 Latar Belakang

Input produk satu per satu sangat tidak efisien untuk onboarding
toko baru yang bisa memiliki ratusan hingga ribuan SKU.

**Estimasi waktu input:**

| Metode | Waktu per produk | 500 produk |
|---|---|---|
| Manual (form) | ~3-5 menit | ~25-40 jam |
| Import CSV/Excel | ~0.1 detik | ~1 menit |
| Batch scan | ~30 detik | ~4 jam |
| AI Foto | ~10 detik | ~1.5 jam |

---

### 3.2 UPDATE-02A · Import CSV / Excel (P0)

#### Flow Lengkap

```
1. Admin buka Inventory → tap "Import Produk"
2. Pilih metode: Download Template / Upload File
3. Jika download template: generate CSV kosong dengan header
4. Jika upload: pilih file .csv atau .xlsx dari storage HP
5. App parse file → validasi setiap baris
6. Tampil preview tabel hasil parsing:
   - Baris valid: background hijau muda
   - Baris error: background merah muda + keterangan error
7. Pilih mode import:
   - "Tambah baru saja" → skip baris dengan barcode existing
   - "Update yang ada" → update produk existing, skip yang baru
   - "Tambah + Update" → upsert by barcode (RECOMMENDED)
8. Konfirmasi → proses import → tampil hasil
9. Hasil: "485 berhasil · 3 diperbarui · 2 gagal" + detail error
```

#### Template CSV

```csv
barcode,nama_produk,kategori,harga_jual,harga_beli,stok,satuan
8999999001,Aqua 600ml,Minuman,4000,2500,100,pcs
8999999002,Indomie Goreng,Makanan,3500,2000,200,pcs
8999999003,Tisu Paseo,Lainnya,8000,5000,50,pack
```

**Aturan kolom:**

| Kolom | Tipe | Wajib | Validasi |
|---|---|---|---|
| `barcode` | string | Ya | Unik, max 20 karakter |
| `nama_produk` | string | Ya | Max 100 karakter |
| `kategori` | string | Tidak | Default: "Lainnya" |
| `harga_jual` | integer | Ya | > 0, angka saja |
| `harga_beli` | integer | Tidak | Default: 0 |
| `stok` | integer | Tidak | Default: 0, >= 0 |
| `satuan` | string | Tidak | Default: "pcs" |

**Validasi error yang harus ditampilkan:**

| Kode Error | Pesan ke User |
|---|---|
| `ERR_BARCODE_EMPTY` | Baris X: Barcode tidak boleh kosong |
| `ERR_BARCODE_DUPLICATE_FILE` | Baris X: Barcode duplikat dalam file |
| `ERR_NAME_EMPTY` | Baris X: Nama produk tidak boleh kosong |
| `ERR_PRICE_INVALID` | Baris X: Harga jual harus angka > 0 |
| `ERR_STOCK_NEGATIVE` | Baris X: Stok tidak boleh negatif |

#### Package Flutter

```yaml
dependencies:
  excel: ^4.0.0        # baca .xlsx
  csv: ^6.0.0          # baca .csv
  file_picker: ^8.0.0  # pilih file dari storage
  share_plus: ^10.0.0  # export/download template
```

#### Acceptance Criteria

- [ ] Download template CSV berhasil ke storage HP
- [ ] Upload file .csv dan .xlsx berhasil di-parse
- [ ] File dengan 1000 baris diproses < 3 detik
- [ ] Preview menampilkan max 50 baris pertama + summary
- [ ] Error per baris ditampilkan dengan nomor baris yang jelas
- [ ] Mode upsert: produk existing diupdate, baru ditambah
- [ ] Hasil import menampilkan: berhasil / diperbarui / gagal
- [ ] Import dapat di-cancel sebelum konfirmasi

---

### 3.3 UPDATE-02B · Batch Scan Mode (P1)

Mode khusus untuk kasir yang ingin menambah produk dengan
cara scan fisik barang satu per satu.

#### Flow

```
1. Admin buka Inventory → tap "Scan Massal"
2. Layar masuk mode scan: kamera aktif + counter "0 produk ditambah"
3. Scan barcode produk:
   a. SUDAH ADA di database:
      → toast: "Aqua 600ml — sudah terdaftar"
      → pilihan: [Tambah Stok +1] [Tambah Stok +5] [Edit] [Skip]
   b. BELUM ADA di database:
      → muncul mini-form di bottom sheet:
        · Nama Produk (text, required)
        · Harga Jual  (number, required)
        · Stok Awal   (number, default: 1)
      → Simpan → kembali ke mode scan otomatis
4. Setiap produk tersimpan langsung (tidak perlu konfirmasi batch)
5. Counter terupdate: "12 produk ditambah"
6. Tap "Selesai" → ringkasan: berapa ditambah, berapa diupdate
```

#### Mini-form Spec

```
┌─────────────────────────────────────┐
│  ──── (drag handle)                 │
│  Produk Baru Ditemukan              │
│  Barcode: 8999999015                │
│                                     │
│  Nama Produk *                      │
│  [________________________]         │
│                                     │
│  Harga Jual *          Stok Awal    │
│  Rp [__________]       [-][1][+]    │
│                                     │
│  Kategori                           │
│  [Pilih ▾           ]               │
│                                     │
│  [  Simpan & Scan Berikutnya  ]     │
└─────────────────────────────────────┘
```

**Penting:** Form hanya 3-4 field (bukan form lengkap). Detail lain
bisa dilengkapi nanti via edit produk.

#### Acceptance Criteria

- [ ] Kamera tetap standby setelah simpan produk (tidak perlu re-tap)
- [ ] Mini-form muncul < 200ms setelah barcode terdeteksi
- [ ] Keyboard otomatis fokus ke field Nama Produk
- [ ] Tap di luar mini-form TIDAK menutup form (cegah kehilangan input)
- [ ] Counter produk terupdate real-time di layar scan
- [ ] Ringkasan akhir menampilkan daftar semua produk yang ditambah

---

### 3.4 UPDATE-02C · AI Foto Produk (P2 — Sprint 4)

Foto kemasan / label produk → AI baca otomatis → pre-fill form.

#### Flow

```
1. Di form tambah produk, tap ikon kamera AI (bintang + kamera)
2. Kamera terbuka dalam mode "AI scan"
3. Arahkan ke kemasan / label harga produk → tap foto
4. Request ke Gemini Vision API:
   - Kirim gambar sebagai base64
   - Prompt: ekstrak nama produk, barcode jika ada, harga jika terlihat
5. Response dalam 2-3 detik:
   - Field nama_produk ter-isi otomatis
   - Field barcode ter-isi jika terdeteksi
   - Field harga ter-isi jika terbaca
6. Kasir verifikasi + koreksi jika perlu → simpan
```

#### API Request

```dart
// Gemini Vision API call
final prompt = """
Analisis gambar kemasan/label produk ini.
Ekstrak informasi berikut dalam format JSON:
{
  "nama_produk": "nama lengkap produk",
  "barcode": "nomor barcode jika terlihat, null jika tidak ada",
  "harga": angka harga jika terlihat, null jika tidak ada,
  "merek": "nama merek/brand jika ada"
}
Jika tidak yakin, isi null. Jangan mengarang.
""";
```

**Catatan:** Butuh koneksi internet. Gemini API free tier:
15 request/menit, 1500 request/hari — cukup untuk penggunaan normal.

#### Acceptance Criteria

- [ ] Tombol AI hanya muncul jika internet tersedia
- [ ] Loading indicator selama API call (max 5 detik)
- [ ] Jika API gagal / timeout: fallback ke form kosong biasa
- [ ] Field yang ter-isi otomatis diberi highlight kuning sebagai penanda
- [ ] Kasir bisa edit semua field yang ter-isi AI sebelum simpan

---

### 3.5 UPDATE-02D · Barcode Public Database Lookup (P2 — Sprint 3)

Saat kasir input barcode manual atau scan produk baru, app
cek database publik untuk auto-fill nama produk.

#### API yang Digunakan

- **Open Food Facts** — `https://world.openfoodfacts.org/api/v0/product/{barcode}.json`
- **Fallback:** manual input jika tidak ditemukan

#### Flow

```
Scan / input barcode baru
        ↓
Cek Open Food Facts API (background, tidak blocking)
        ↓ ditemukan              ↓ tidak ditemukan
Field nama ter-isi          Form kosong seperti biasa
"Aqua 600ml (saran AI)"     kasir isi manual
Kasir konfirmasi / edit
```

**Catatan:** Nama produk dari database publik mungkin dalam
bahasa Inggris atau format berbeda. Selalu tampilkan sebagai
"saran" yang bisa diedit, bukan langsung disimpan.

---

## 4. UPDATE-03 · Digital Struk & Print Flow

### 4.1 Latar Belakang

Flow print lama menyebabkan masalah UX serius:

```
MASALAH FLOW LAMA:
Bayar → loading (nyambung printer) → cetak → selesai
         ↑
   Jika printer mati/jauh/error → app stuck / transaksi gagal?
   Pembeli yang tidak mau struk tetap harus tunggu loading printer
   Tidak ada pilihan untuk tidak cetak
```

```
SOLUSI FLOW BARU:
Bayar → SIMPAN INSTAN → Digital Struk Screen → [Cetak] atau [Tidak]
         ↑
   Transaksi SELALU tersimpan, print adalah aksi opsional terpisah
   Tidak ada loading yang memblokir kasir
   Kasir punya kendali penuh
```

**Prinsip utama:** Transaksi tersimpan adalah aksi wajib dan instan.
Print adalah aksi opsional yang TIDAK mempengaruhi data transaksi.

---

### 4.2 UPDATE-03A · Digital Struk Screen (P0)

Screen baru yang muncul setelah konfirmasi pembayaran berhasil.
Ini adalah SCR-07 yang resmi menggantikan flow checkout lama.

#### Layout Screen

```
┌─────────────────────────────────────┐
│                                     │
│            ✓ (animasi 500ms)        │
│       Pembayaran Berhasil!          │
│       INV-20260314-0047             │
│       14:20:45 · Kasir: Budi        │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  ·········KASIRKU PRO········ │  │
│  │    Jl. Sudirman No.1 Jakarta  │  │
│  │  ·····························│  │
│  │  Es Kopi Susu    2x  20.000   │  │
│  │  Nasi Goreng     1x  15.000   │  │
│  │  ·····························│  │
│  │  Subtotal            35.000   │  │
│  │  Diskon             -10.500   │  │
│  │  TOTAL               24.500   │  │
│  │  Tunai               30.000   │  │
│  │  Kembali              5.500   │  │
│  │  ·····························│  │
│  │    Terima kasih sudah belanja! │  │
│  └───────────────────────────────┘  │
│                                     │
│  [🖨 CETAK]  [📲 SHARE]  [✕ TUTUP] │
│                                     │
│  ○○○○○○○○  Lanjut dalam 8 detik... │
│                                     │
└─────────────────────────────────────┘
```

#### Spesifikasi Komponen

**Checkmark animasi:**
- Circle hijau accent scale dari 0 → 1 (300ms, easeOutBack)
- Checkmark draw animation (200ms setelahnya)
- Subtle haptic feedback saat muncul

**Digital struk card:**
- Font: `SpaceMono` untuk semua angka dan garis
- Garis pemisah: karakter `·` berulang (bukan garis solid)
- Background: surface card, rounded 12dp
- Scrollable jika item terlalu banyak (max height 60% layar)

**Tiga tombol aksi:**

| Tombol | Style | Aksi |
|---|---|---|
| CETAK STRUK | Filled, accent green | Kirim ke printer BT, tampil loading hanya di tombol ini |
| SHARE | Outlined, blue | Share sebagai teks/gambar via WhatsApp / app lain |
| TUTUP / ✕ | Text button, muted | Lanjut tanpa cetak |

**Auto-lanjut countdown:**
- Progress bar tipis di bawah tombol, mengosongkan dalam 8 detik
- Jika layar disentuh: countdown berhenti
- Setelah 8 detik tanpa sentuhan: otomatis ke transaksi baru (= tidak cetak)
- Countdown reset jika tombol CETAK ditekan (tunggu print selesai dulu)

#### State Tombol CETAK

```
State 1 — Default:
[🖨 CETAK STRUK]  ← enabled, accent green

State 2 — Sedang print:
[⏳ Mencetak...]  ← loading spinner, disabled sementara
Countdown berhenti selama printing

State 3 — Print sukses:
[✓ Tercetak]  ← hijau, disabled
Toast: "Struk berhasil dicetak"
Countdown resume → lanjut dalam 3 detik

State 4 — Print gagal:
[⚠ Gagal — Coba Lagi]  ← amber, enabled
Toast: "Printer tidak terhubung"
Countdown berhenti — tunggu keputusan kasir
```

#### Acceptance Criteria

- [ ] Screen muncul < 100ms setelah konfirmasi bayar
- [ ] Transaksi sudah tersimpan di SQLite SEBELUM screen ini tampil
- [ ] Checkmark animasi smooth di semua device
- [ ] Countdown 8 detik berjalan dengan progress bar visible
- [ ] Countdown berhenti saat layar disentuh
- [ ] Auto-lanjut ke POS screen setelah countdown habis
- [ ] Tombol CETAK tidak memblokir UI saat loading print
- [ ] Print gagal tidak menghapus atau membatalkan transaksi
- [ ] Scroll struk berfungsi jika item > 5

---

### 4.3 UPDATE-03B · Pisah Transaksi vs Print (P0)

Perubahan arsitektur backend yang mendukung flow baru.

#### Perubahan Use Case

```
SEBELUM (satu use case):
CheckoutUseCase → simpan transaksi + print struk

SESUDAH (dua use case terpisah):
1. ConfirmPaymentUseCase → HANYA simpan transaksi → return invoice data
2. PrintReceiptUseCase   → HANYA print → bisa dipanggil kapan saja
```

```dart
// Use case 1 — wajib, selalu berhasil
class ConfirmPaymentUseCase {
  Future<Transaction> execute(CartState cart) async {
    final tx = await _repository.saveTransaction(cart);
    return tx; // langsung return, tidak tunggu printer
  }
}

// Use case 2 — opsional, bisa gagal tanpa efek ke transaksi
class PrintReceiptUseCase {
  Future<PrintResult> execute(Transaction tx) async {
    return await _printerService.print(tx);
    // PrintResult: success / failed / no_printer
  }
}

// Use case 3 — opsional, share digital
class ShareReceiptUseCase {
  Future<void> execute(Transaction tx, ShareMethod method) async {
    // method: whatsapp / image / text
  }
}
```

#### Perubahan Database Schema

Tambah kolom baru di tabel `transactions`:

```sql
ALTER TABLE transactions ADD COLUMN is_printed     INTEGER DEFAULT 0;
ALTER TABLE transactions ADD COLUMN printed_at     TEXT    DEFAULT NULL;
ALTER TABLE transactions ADD COLUMN print_method   TEXT    DEFAULT NULL;
-- print_method: 'bluetooth' | 'wifi' | null
ALTER TABLE transactions ADD COLUMN share_method   TEXT    DEFAULT NULL;
-- share_method: 'whatsapp' | 'image' | 'none' | null
```

**Kegunaan kolom baru:**
- `is_printed`: filter laporan "transaksi tanpa struk" untuk audit
- `printed_at`: analitik berapa lama kasir cetak struk
- `share_method`: tracking preferensi pelanggan (cetak vs digital)

#### Acceptance Criteria

- [ ] `ConfirmPaymentUseCase` selesai < 200ms
- [ ] `ConfirmPaymentUseCase` tidak pernah throw karena printer
- [ ] `PrintReceiptUseCase` bisa dipanggil ulang dari riwayat transaksi
- [ ] Kolom `is_printed` terupdate setelah print sukses
- [ ] Transaksi dengan `is_printed = 0` tetap masuk laporan normal

---

### 4.4 UPDATE-03C · Share Struk via WhatsApp (P1 — Sprint 3)

#### Format Struk Teks untuk WhatsApp

```
*KASIRKU PRO*
Jl. Sudirman No.1, Jakarta

No: INV-20260314-0047
Tgl: 14/03/2026 14:20 | Kasir: Budi
----------------------------
Es Kopi Susu  2x  Rp 20.000
Nasi Goreng   1x  Rp 15.000
----------------------------
Subtotal         Rp 35.000
Diskon          -Rp 10.500
*TOTAL           Rp 24.500*
Tunai            Rp 30.000
Kembali          Rp  5.500
----------------------------
Terima kasih sudah belanja! 🙏
```

#### Implementasi Flutter

```dart
// Gunakan share_plus package
import 'package:share_plus/share_plus.dart';

// Share sebagai teks (WhatsApp, Telegram, dll)
await Share.share(receiptText, subject: 'Struk KasirKu Pro');

// Share sebagai gambar (screenshot widget)
final image = await _captureReceiptWidget();
await Share.shareXFiles([XFile(image.path)]);
```

#### Acceptance Criteria

- [ ] Tap SHARE membuka system share sheet Android
- [ ] Format teks menggunakan bold markdown (`*teks*`) untuk WhatsApp
- [ ] Opsi share image: struk di-render sebagai PNG lalu dibagikan
- [ ] Share berhasil tidak menutup digital struk screen

---

### 4.5 UPDATE-03D · Simpan Struk sebagai Gambar (P2 — Sprint 3)

```dart
// Render widget ke gambar menggunakan RepaintBoundary
final boundary = _receiptKey.currentContext!
    .findRenderObject() as RenderRepaintBoundary;
final image = await boundary.toImage(pixelRatio: 2.0);
final bytes = await image.toByteData(format: ImageByteFormat.png);

// Simpan ke galeri
await ImageGallerySaver.saveImage(bytes!.buffer.asUint8List());
```

---

## 5. Perubahan Database Schema

Ringkasan semua perubahan schema dari update ini:

### 5.1 Tabel `transactions` — kolom baru

```sql
-- Sudah ada di PRD-001:
id, invoice_no, total, discount, tax, payment_method,
paid_amount, change, cashier_id, created_at

-- TAMBAH (UPDATE-03B):
is_printed   INTEGER NOT NULL DEFAULT 0,
printed_at   TEXT    DEFAULT NULL,
print_method TEXT    DEFAULT NULL,
share_method TEXT    DEFAULT NULL
```

### 5.2 Tabel `import_logs` — tabel baru

Untuk tracking riwayat import produk (UPDATE-02A):

```sql
CREATE TABLE import_logs (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  filename    TEXT    NOT NULL,
  total_rows  INTEGER NOT NULL DEFAULT 0,
  success     INTEGER NOT NULL DEFAULT 0,
  updated     INTEGER NOT NULL DEFAULT 0,
  failed      INTEGER NOT NULL DEFAULT 0,
  errors_json TEXT    DEFAULT NULL,  -- JSON array of error messages
  imported_by INTEGER NOT NULL,      -- user_id
  created_at  TEXT    NOT NULL
);
```

### 5.3 Migration Script

```dart
// lib/data/database/migrations/migration_v2.dart
class MigrationV2 extends Migration {
  @override
  Future<void> up(Migrator m) async {
    // Tambah kolom ke transactions
    await m.addColumn(transactions, transactions.isPrinted);
    await m.addColumn(transactions, transactions.printedAt);
    await m.addColumn(transactions, transactions.printMethod);
    await m.addColumn(transactions, transactions.shareMethod);

    // Buat tabel baru
    await m.createTable(importLogs);
  }
}
```

---

## 6. Perubahan UI Components

### 6.1 Komponen Baru

| Komponen | Digunakan di | Keterangan |
|---|---|---|
| `DigitalReceiptCard` | SCR-07 | Widget struk digital dengan font monospace |
| `ReceiptActionButtons` | SCR-07 | Row 3 tombol: Cetak, Share, Tutup |
| `CountdownProgressBar` | SCR-07 | Progress bar tipis dengan countdown 8 detik |
| `AnimatedCheckmark` | SCR-07 | Circle + checkmark dengan animasi |
| `ImportPreviewTable` | SCR-04 | Tabel preview hasil parsing CSV/Excel |
| `ImportResultBanner` | SCR-04 | Banner hasil: X berhasil, Y gagal |
| `BatchScanCounter` | SCR-04 | Counter floating saat batch scan mode |
| `MiniProductForm` | SCR-04 | Bottom sheet mini-form saat scan massal |
| `CartBottomSheet` | SCR-02 (HP) | DraggableScrollableSheet untuk cart di HP |

### 6.2 Komponen yang Dimodifikasi

| Komponen | Perubahan |
|---|---|
| `CheckoutButton` (BAYAR) | Tidak lagi trigger print. Hanya trigger ConfirmPaymentUseCase |
| `TopBar` | Tambah breakpoint: icon-only mode untuk HP portrait |
| `ProductGrid` | Breakpoint 2 kolom untuk HP portrait |
| `InventoryScreen` | Tambah FAB menu: Manual / Import / Scan Massal |

### 6.3 Navigasi Baru

```
Setelah BAYAR:
CartScreen → DigitalReceiptScreen (push, no back button)

Setelah TUTUP / countdown habis / print selesai:
DigitalReceiptScreen → POSScreen (popUntil root, clear stack)
```

**Penting:** Back button dinonaktifkan di DigitalReceiptScreen.
Kasir harus memilih aksi secara eksplisit (cetak/share/tutup).

---

## 7. Sprint Re-planning

Berdasarkan semua update, berikut revisi sprint plan:

| Sprint | Fitur Lama (PRD-001) | Fitur Tambahan (PRD-003) |
|---|---|---|
| Sprint 1 | F-01 Scan, F-02 Produk, F-03 Cart, F-04 Bayar Tunai | UPDATE-01 Responsive layout |
| Sprint 2 | F-05 Print, F-06 History, F-07 Diskon | UPDATE-02A Import CSV, UPDATE-02B Batch Scan, UPDATE-03A Digital Struk, UPDATE-03B Pisah transaksi vs print |
| Sprint 3 | F-08 QRIS, F-09 Laporan, F-10 Stok | UPDATE-02D Barcode lookup, UPDATE-03C Share WA, UPDATE-03D Simpan gambar |
| Sprint 4 | F-11 Multi Kasir, F-12 Cloud Sync, F-13 Export | UPDATE-02C AI Foto produk |
| Sprint 5 | Bug fix, performance, Play Store | — |

---

## 8. Decision Log

Semua keputusan desain dan teknis yang diambil selama sesi diskusi:

| ID | Keputusan | Alasan | Tanggal |
|---|---|---|---|
| DEC-001 | Default Admin ID:1 untuk Sprint 1-2, no login screen | Tidak mau Sprint 1-2 terhambat fitur auth Sprint 4 | Mar 2026 |
| DEC-002 | Field diskon tampil tapi disabled Sprint 1, nilai = 0 | UI Stitch sudah bagus, sayang dihilangkan | Mar 2026 |
| DEC-003 | Tax disembunyikan dari UI seluruh MVP | Toko kecil Indonesia mayoritas bukan PKP | Mar 2026 |
| DEC-004 | Flutter untuk Windows version, bukan rewrite | Satu codebase, 70% kode tidak berubah | Mar 2026 |
| DEC-005 | HP sebagai barcode scanner untuk Windows via WiFi WebSocket | Paling fleksibel, tidak butuh kabel | Mar 2026 |
| DEC-006 | Transaksi simpan DULU, print TERPISAH | Print tidak boleh memblokir atau membatalkan transaksi | Mar 2026 |
| DEC-007 | Auto-lanjut 8 detik di digital struk screen | Antrian tidak terhambat jika kasir lupa tap | Mar 2026 |
| DEC-008 | Import CSV + Batch Scan di Sprint 2 (bukan Sprint 3) | Onboarding toko baru adalah blocker utama adoption | Mar 2026 |

---

*PRD-003 · Kasir App — Feature Updates · Versi 1.0 · Maret 2026*
*Referensi: PRD-001 (Backend) · PRD-002 (UI/Frontend)*
