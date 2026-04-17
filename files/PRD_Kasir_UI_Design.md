# PRD-002 · Aplikasi Kasir — UI / Frontend Design

> **Versi:** 1.0 · **Status:** Draft · **Platform:** Flutter · **Tanggal:** Maret 2026

---

## Daftar Isi

1. [Prinsip Desain](#1-prinsip-desain)
2. [Design System — Warna](#2-design-system--warna)
3. [Design System — Tipografi](#3-design-system--tipografi)
4. [Design System — Komponen UI](#4-design-system--komponen-ui)
5. [Layout & Navigation](#5-layout--navigation)
6. [Spesifikasi Layar](#6-spesifikasi-layar-screen-specifications)
7. [Animasi & Motion](#7-animasi--motion)
8. [Aksesibilitas](#8-aksesibilitas)
9. [Assets & Icon](#9-assets--icon)
10. [Design Handoff](#10-design-handoff--deliverables)

---

## 1. Prinsip Desain

UI Kasir dirancang untuk **kecepatan dan kejelasan** dalam situasi kerja nyata: pencahayaan toko yang bervariasi, kasir yang bekerja sambil melayani pelanggan, dan layar yang bisa basah atau kotor. Setiap keputusan desain harus melewati filter: *"apakah ini mempercepat transaksi?"*

| Prinsip | Definisi | Implementasi |
|---|---|---|
| **Speed First** | Aksi terpenting harus bisa dilakukan dalam 1-2 tap | Tombol SCAN besar di tengah, produk bisa ditambah langsung dari grid |
| **Clarity** | Informasi kritis selalu terlihat tanpa scroll | Total tagihan always-visible di panel kanan, tidak tersembunyi |
| **Forgiveness** | Mudah undo kesalahan, tidak ada aksi destruktif permanen | Tombol −qty sebelum tombol hapus, konfirmasi sebelum clear cart |
| **Contrast** | Teks harus terbaca di cahaya terang maupun redup | Minimum contrast ratio 4.5:1 untuk semua teks pada background |
| **Touch-Friendly** | Target sentuh minimal 48×48dp sesuai Material guidelines | Semua tombol interaktif minimal 48dp, padding ekstra di area jempol |

---

## 2. Design System — Warna

### 2.1 Dark Theme (Default)

Dark theme dipilih sebagai default karena mengurangi glare di toko, lebih hemat baterai (AMOLED), dan tampak lebih profesional.

#### Background & Surface

| Token | Hex | Penggunaan |
|---|---|---|
| `colorBackground` | `#0F1117` | Layar utama app |
| `colorSurface` | `#181C27` | Card, panel |
| `colorSurface2` | `#1E2335` | Input, modal |
| `colorBorder` | `#2A2F45` | Garis pemisah |
| `colorTextPrimary` | `#E8EAF0` | Teks utama |
| `colorTextMuted` | `#6B7280` | Label, hint |

#### Accent & Semantic

| Token | Hex | Penggunaan |
|---|---|---|
| `colorAccent` | `#00E5A0` | CTA utama, total, sukses |
| `colorInfo` | `#4F8CFF` | Info, metode bayar aktif |
| `colorWarning` | `#FFB347` | Stok rendah, diskon |
| `colorDanger` | `#FF5C6C` | Error, hapus, stok habis |
| `colorQRIS` | `#A855F7` | Badge QRIS |

### 2.2 Light Theme (Opsional)

| Token | Hex | Penggunaan |
|---|---|---|
| `colorBackground` | `#F8F9FA` | Layar utama |
| `colorSurface` | `#FFFFFF` | Card, panel |
| `colorSurface2` | `#F1F3F4` | Input field |
| `colorBorder` | `#DEE2E6` | Garis pemisah |
| `colorTextPrimary` | `#1A1A2E` | Teks utama |
| `colorTextMuted` | `#6C757D` | Label, hint |

### 2.3 Semantic Color Tokens

| Token | Dark | Light | Penggunaan |
|---|---|---|---|
| `colorSuccess` | `#00E5A0` | `#198754` | Transaksi berhasil, stok cukup |
| `colorWarning` | `#FFB347` | `#FD7E14` | Stok rendah (< 5), diskon aktif |
| `colorError` | `#FF5C6C` | `#DC3545` | Stok habis, error, hapus |
| `colorPrimary` | `#00E5A0` | `#198754` | Tombol CTA utama |

---

## 3. Design System — Tipografi

### 3.1 Font Family

| Role | Font | Weight | Penggunaan |
|---|---|---|---|
| Display | Space Mono | 700 Bold | Angka total, harga besar, invoice number |
| Body | DM Sans | 400 Regular | Teks deskripsi, label, body copy |
| Body Bold | DM Sans | 600 SemiBold | Nama produk, heading sekunder |
| Caption | DM Sans | 400 Regular | Hint, placeholder, timestamp |

> **Alasan:** Space Mono dipilih untuk angka karena monospace memastikan digit selalu rata —
> sangat penting untuk harga dan total agar mudah dibaca sekilas oleh kasir.

### 3.2 Type Scale (Flutter TextStyle)

| Token | Size | Line Height | Weight | Penggunaan |
|---|---|---|---|---|
| `displayLarge` | 36sp | 1.1 | 700 | Total tagihan di checkout modal |
| `displayMedium` | 22sp | 1.2 | 700 | Harga produk di cart |
| `headlineMedium` | 18sp | 1.3 | 600 | Judul section, nama halaman |
| `titleMedium` | 15sp | 1.4 | 600 | Nama produk di card |
| `bodyMedium` | 14sp | 1.5 | 400 | Deskripsi, label tabel |
| `bodySmall` | 12sp | 1.5 | 400 | Caption, timestamp, hint text |
| `labelMedium` | 12sp | 1.2 | 600 | Badge, status chip, kategori |

---

## 4. Design System — Komponen UI

### 4.1 Buttons

| Variant | Gunakan untuk | Specs |
|---|---|---|
| **Primary (Filled)** | CTA utama: BAYAR, KONFIRMASI | BG: `colorAccent`, text: hitam, height: 52dp, radius: 12dp, font: Space Mono 700 |
| **Secondary (Outlined)** | Aksi sekunder: Batal, Cetak Ulang | Border: `colorBorder`, text: `colorMuted`, height: 44dp, radius: 10dp |
| **Danger (Outlined)** | Aksi destruktif: Hapus, Clear Cart | Border/text: `colorError`, hanya muncul setelah konfirmasi |
| **Icon Button** | Aksi contextual: +/− qty, filter | Size: 44×44dp minimum, bg: surface2 |
| **FAB Scan** | Aksi scan barcode (selalu visible) | Size: 56dp, BG: `colorAccent`, icon: barcode, bottom-right |

### 4.2 Cards

| Komponen | Specs | State |
|---|---|---|
| **Product Card** | BG: surface, radius: 12dp, padding: 14dp | Default / Hover (border accent) / Out-of-stock (opacity 40%) |
| **Cart Item Row** | Full-width, padding: 10dp 20dp, border-bottom: 1px surface2 | Default / Hover (bg surface2) |
| **Transaction Card** | BG: surface, radius: 10dp, left border accent 3dp | Default / Expanded (show items) |
| **Summary Card** | BG: surface2, radius: 10dp, padding: 12dp | Static — menampilkan total |

### 4.3 Input Fields

| Field | Specs | Validasi |
|---|---|---|
| Search Produk | Height: 44dp, radius: 10dp, icon kiri: search | Real-time filter, debounce 300ms |
| Barcode Manual | Height: 44dp, font: Space Mono, text-align: center | Enter/submit trigger lookup |
| Diskon (Rp/%) | Height: 40dp, keyboardType: number | Max: tidak boleh > subtotal |
| Nominal Bayar | Height: 52dp, font: Space Mono 22sp, text-align: right | Real-time hitung kembalian |
| PIN Login | Height: 52dp, obscureText, font: Space Mono | 4-6 digit, auto-submit saat lengkap |

### 4.4 Feedback & Notifikasi

| Komponen | Trigger | Durasi / Aksi |
|---|---|---|
| SnackBar Success | Item ditambahkan ke cart | 2.2 detik, auto-dismiss, hijau |
| SnackBar Error | Barcode tidak ditemukan, stok habis | 3 detik, merah, action: "Tambah Produk" |
| AlertDialog | Clear cart, hapus produk, tutup shift | Modal, tombol Batal + Konfirmasi |
| Bottom Sheet | Pilih printer, pilih metode bayar | Dismissible, drag handle |
| Loading Overlay | Saat print, saat sync cloud | Spinner + pesan, tidak blokir back |
| Badge notif | Stok produk < 5 unit | Badge merah di icon produk |

---

## 5. Layout & Navigation

### 5.1 Responsive Breakpoints

| Device | Breakpoint | Layout |
|---|---|---|
| HP Portrait | `< 600dp` | Single panel. Bottom nav. Cart slide-up dari bawah (DraggableScrollableSheet) |
| HP Landscape | `600–840dp` | Split 60/40. Kiri: produk grid. Kanan: cart. Mode optimal untuk HP kasir |
| Tablet Portrait | `840–1200dp` | Split 55/45. Kiri: produk + search. Kanan: cart + summary lengkap |
| Tablet Landscape | `> 1200dp` | Split 60/40 dengan sidebar navigasi permanent di kiri |

### 5.2 Navigasi Utama

App menggunakan `NavigationRail` (tablet) atau `BottomNavigationBar` (HP) dengan 4 destinasi:

| # | Destinasi | Icon | Role Akses |
|---|---|---|---|
| 1 | POS / Kasir | `point_of_sale` | Kasir + Admin |
| 2 | Produk | `inventory_2` | Admin only |
| 3 | Transaksi | `receipt_long` | Kasir + Admin |
| 4 | Laporan | `bar_chart` | Admin only |

> **Kasir vs Admin Mode:**
> - Kasir: tab Produk dan Laporan disembunyikan
> - Admin: semua tab tersedia + menu Settings di top-right
> - Role ditentukan saat buat user, tidak bisa diubah saat shift berlangsung

---

## 6. Spesifikasi Layar (Screen Specifications)

### SCR-01 · Login Screen

**Deskripsi:** Layar pertama saat app dibuka. Kasir pilih nama dari daftar lalu masukkan PIN.

**Komponen:**
- Logo app (tengah atas)
- Daftar kasir sebagai ListTile dengan avatar
- NumPad PIN (4×3 grid)
- Tombol backspace
- Indikator PIN (dot `●●●●`)

**State:** `Idle` → `PIN Active` → `Loading` → `Error` → `Locked`

**Interaksi:**
- Tap kasir → aktif
- Masukkan PIN → auto-submit saat 4/6 digit terisi
- Jika salah: shake animation + clear PIN
- Jika 5× salah: lockout 5 menit

---

### SCR-02 · POS Screen *(Layar Kasir Utama)*

**Deskripsi:** Layar paling sering digunakan. Harus zero-friction. Split layout kiri-kanan di tablet/landscape.

#### Panel Kiri — Produk

- TopBar: Logo + nama shift + jam + tombol tutup shift
- Search bar: full-width, icon kiri, tombol **SCAN** di kanan (accent green, font mono)
- Category chips: horizontal scroll, pill shape, satu aktif = accent blue
- Product grid: 2-4 kolom tergantung lebar layar
- Product card:
  - Emoji/foto produk
  - Nama + harga + stok
  - State: `Default` / `Hover` (border hijau, icon +) / `Out-of-stock` (opacity 40%)

#### Panel Kanan — Cart

- Header: "KERANJANG" + badge jumlah item + tombol "Kosongkan"
- Cart items: scrollable list — nama + harga satuan / qty control (−, angka, +) / subtotal
- Summary: subtotal → input diskon → **TOTAL** (Space Mono besar, accent green)
- Payment method: 3 toggle chips (Tunai / QRIS / Transfer)
- CTA: tombol **BAYAR** full-width, disabled jika cart kosong

#### State Penting

| State | Tampilan |
|---|---|
| Cart kosong | Ilustrasi keranjang + teks panduan |
| Scan overlay | Full-screen gelap + frame scan + line animasi + input manual |
| Checkout modal | Total besar + input nominal + kembalian real-time + konfirmasi |

---

### SCR-03 · Manajemen Produk

**Deskripsi:** Hanya admin. List + CRUD produk.

**Komponen:**
- Search + filter kategori
- ListView produk
- FAB "+" tambah produk
- Swipe-to-edit / swipe-to-delete

**Form Tambah/Edit:**

```
Nama Produk    : [________________]
Barcode        : [____________] [📷]
Kategori       : [Pilih ▾        ]
Harga Jual     : Rp [____________]
Harga Beli     : Rp [____________]
Stok           : [-] [  24  ] [+]
Foto           : [  📷 Ambil Foto  ]
```

**Validasi:**
- Barcode harus unik
- Harga tidak boleh 0
- Stok tidak boleh negatif

---

### SCR-04 · Riwayat Transaksi

**Deskripsi:** List semua transaksi dengan filter tanggal. Kasir hanya lihat transaksi shift aktif.

**Komponen:**
- `DateRangePicker` di top
- List transaksi: invoice + waktu + total + metode bayar + kasir
- Search by invoice number

**Detail Transaksi** (modal/bottom sheet):
- List item dengan harga dan diskon
- Total tagihan
- Tombol **Cetak Ulang**
- Admin: bisa **Void** transaksi dengan konfirmasi + alasan

---

### SCR-05 · Laporan

**Deskripsi:** Dashboard pemilik toko. Chart dan angka ringkasan.

**Komponen:**
- Period selector: Hari ini / 7 hari / 30 hari / Custom
- Summary cards: total omset, jumlah transaksi, item terjual
- Bar chart: omset harian (`fl_chart`)
- Top 5 produk terlaris
- Tombol export PDF / Excel (top-right)

---

### SCR-06 · Settings

**Deskripsi:** Pengaturan app. Admin only.

**Section:**

```
INFORMASI TOKO
  Nama Toko        →
  Alamat           →
  Nomor HP         →

PRINTER STRUK
  Printer Aktif    → [Xprinter XP-58 ●]
  Lebar Kertas     → [58mm] [80mm]
  Test Print       →

TAMPILAN STRUK
  Nama Toko        ◉ ON
  Alamat           ◉ ON
  Logo             ○ OFF
  Pesan Kaki       →

KASIR & AKUN
  Kelola Kasir     → 3 aktif
  Ganti PIN        →
  Tema             → [Gelap] [Terang]

DATA & BACKUP
  Ekspor Data      →
  Backup Database  → last: 14 Mar 2026
  Versi App        → v1.0.0

──────────────────
  Logout / Tutup Sesi  (merah)
```

---

## 7. Animasi & Motion

| Momen | Animasi | Durasi | Easing |
|---|---|---|---|
| Item ditambahkan ke cart | Cart badge scale bounce + SnackBar slide-up | 300ms | easeOutBack |
| Scan berhasil | Flash overlay hijau + haptic feedback | 200ms | easeOut |
| Scan gagal | Shake horizontal pada frame scanner | 400ms | easeInOut (3 cycles) |
| Checkout modal muncul | Slide up + fade in | 250ms | easeOutCubic |
| Transaksi selesai | Checkmark animasi + SnackBar | 500ms | easeOut |
| Screen transition | Slide horizontal (Material page route) | 300ms | easeInOut |
| Stok berubah di card | Text crossfade angka stok | 150ms | linear |

> **Aturan Animasi:**
> - Semua animasi harus bisa dinonaktifkan via `MediaQuery.reduceMotion`
> - Tidak ada animasi yang memblokir input user (semua async/overlay)
> - Durasi maksimum untuk aksi transaksional: **500ms**
> - Haptic feedback wajib di: scan berhasil, konfirmasi bayar, tambah item

---

## 8. Aksesibilitas

| Kategori | Requirement |
|---|---|
| Contrast | Semua teks body min. **4.5:1**, teks besar min. **3:1** (WCAG AA) |
| Touch Targets | Minimum **48×48dp** untuk semua elemen interaktif |
| Semantics | Semua widget custom harus punya `Semantics()` label untuk screen reader |
| Font Scaling | UI tidak pecah saat `textScaleFactor` 1.3x |
| Color Blindness | Tidak menggunakan warna sebagai satu-satunya pembeda informasi |
| Keyboard | Semua aksi bisa dilakukan via keyboard eksternal (tablet + keyboard) |

---

## 9. Assets & Icon

### 9.1 Icon Library

Gunakan **Material Symbols** (outlined variant) sebagai icon utama.

| Icon | Material Symbol | Digunakan di |
|---|---|---|
| Scan Barcode | `barcode_scanner` | Tombol SCAN, FAB |
| Kasir / POS | `point_of_sale` | Tab navigasi |
| Produk | `inventory_2` | Tab navigasi, form produk |
| Transaksi | `receipt_long` | Tab navigasi |
| Laporan | `bar_chart` | Tab navigasi |
| Print | `print` | Tombol cetak struk |
| Hapus | `delete_outline` | Swipe delete |
| Edit | `edit_outlined` | Swipe edit |
| Tambah | `add_circle_outline` | FAB, inline add |
| Pengaturan | `settings` | Top app bar |

### 9.2 App Icon

- Master: **1024×1024px**, generate semua density dengan `flutter_launcher_icons`
- Konsep: ikon barcode + tanda centang hijau
- Background: solid dark `#0F1117`
- Adaptive icon: foreground layer + background layer

### 9.3 Splash Screen

- Durasi: **1.5 detik** (waktu inisialisasi database)
- Konten: logo app center + progress bar tipis di bawah
- Package: `flutter_native_splash`

---

## 10. Design Handoff & Deliverables

| Deliverable | Format | Keterangan |
|---|---|---|
| Design Mockup | Figma | Semua screen dalam dark + light theme |
| Design Tokens | `.dart` file | Warna, spacing, typography sebagai konstanta Dart |
| Component Library | Flutter package | Shared widgets: AppButton, AppCard, AppInput |
| Prototype | Figma interactive | Flow: login → scan → checkout → print struk |
| Asset Export | SVG + PNG | Icon custom, ilustrasi empty state, logo |

### Design Token — Implementasi Dart

```dart
// lib/core/theme/app_colors.dart

class AppColors {
  // Background
  static const background = Color(0xFF0F1117);
  static const surface    = Color(0xFF181C27);
  static const surface2   = Color(0xFF1E2335);
  static const border     = Color(0xFF2A2F45);

  // Text
  static const textPrimary = Color(0xFFE8EAF0);
  static const textMuted   = Color(0xFF6B7280);

  // Accent
  static const accent   = Color(0xFF00E5A0);
  static const info     = Color(0xFF4F8CFF);
  static const warning  = Color(0xFFFFB347);
  static const danger   = Color(0xFFFF5C6C);
}
```

```dart
// lib/core/theme/app_text_styles.dart

class AppTextStyles {
  static const displayLarge = TextStyle(
    fontFamily: 'SpaceMono',
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );

  static const bodyMedium = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
}
```

---

*PRD-002 · Kasir App — UI / Frontend Design · Versi 1.0 · Maret 2026*
