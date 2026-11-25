# Product Requirements Document (PRD) — Aplikasi Mobile "Harianku"

| Informasi Dokumen | Detail |
| :--- | :--- |
| **Nama Produk** | Harianku — Personal Finance & Daily Expense Tracker |
| **Platform** | Mobile (Android / iOS) menggunakan Flutter (Dart) |
| **Arsitektur Data** | 100% Local-First & Offline-Capable dengan **SQLite (`sqflite`)** |
| **Integrasi AI** | **AI Quick-Entry** menggunakan **Google Gemini API** (`gemini-2.5-flash` / `gemini-2.5-flash-lite`) |
| **Referensi UI/UX** | `DESIGN.md` & prototipe layar pada folder `stitch_harianku_finance_tracker_ui/` |

---

## 1. Ringkasan Produk & Tujuan (Product Overview)

**Harianku** adalah aplikasi pencatatan keuangan pribadi (*single-user*) yang dirancang tanpa proses *login* dan tanpa ketergantungan server *backend*. Seluruh catatan keuangan disimpan secara permanen di penyimpanan lokal perangkat menggunakan database relasional terstruktur (**SQLite**), sehingga data tetap aman dan tidak hilang saat aplikasi ditutup atau perangkat dimatikan.

### Tujuan Utama
1. **Zero-Friction Recording:** Mempercepat pencatatan transaksi harian melalui fitur **AI Quick-Entry** (input kalimat alami seperti mengobrol) sekaligus tetap menyediakan formulir input manual yang terstruktur.
2. **Data Persistence & Keandalan:** Menyimpan seluruh transaksi, kategori, dan batas anggaran secara lokal dengan integritas data yang kuat menggunakan SQLite.
3. **Visibilitas Finansial Instan:** Memberikan ringkasan saldo bersih, arus kas (*cashflow*), riwayat transaksi, dan pengawasan anggaran (*budgeting*) secara *real-time*.

---

## 2. Arsitektur Teknis & Tech Stack

* **Framework:** Flutter (Dart SDK terbaru)
* **Local Database:** `sqflite` + `path` (Database lokal SQLite di perangkat pengguna)
* **AI Service:** Google Gemini API (`gemini-2.5-flash` atau `gemini-2.5-flash-lite`) dengan *Structured JSON Output*
* **Environment Management:** `flutter_dotenv` untuk memuat `GEMINI_API_KEY` dari file `.env`
* **State Management:** `provider` atau `flutter_riverpod` (untuk sinkronisasi reaktif antar layar saat database lokal berubah)
* **Charting & UI:** `fl_chart` (untuk grafik Cashflow), `intl` (untuk pemformatan mata uang Rupiah `Rp` dan tanggal lokal Indonesia `id_ID`)

### Struktur Folder Proyek yang Direkomendasikan
```text
lib/
├── main.dart
├── core/
│   ├── constants/        # Warna, tipografi, dan konstanta dari DESIGN.md
│   ├── database/         # DatabaseHelper (SQLite init, tables, seed data)
│   └── utils/            # Currency & Date formatter
├── models/               # TransactionModel, CategoryModel, BudgetModel
├── services/             # AiTransactionService (Gemini API integration)
├── providers/            # FinanceProvider (State management & CRUD bridge)
├── screens/              # 5 layar utama sesuai desain UI
│   ├── beranda/
│   ├── riwayat/
│   ├── catat_transaksi/
│   ├── cashflow/
│   └── budget/
└── widgets/              # Reusable cards, bottom nav bar, AI Quick-Entry sheet
```

---

## 3. Skema Database Lokal (SQLite)

Database lokal bernama `harianku.db` dijalankan sepenuhnya di perangkat pengguna. Saat aplikasi pertama kali dibuka (*first launch*), sistem otomatis membuat 3 tabel utama dan mengisi data kategori bawaan (*default seed*).

### 3.1. Tabel `categories`
Menyimpan daftar kategori pemasukan dan pengeluaran.
* `id` (`TEXT PRIMARY KEY`): Identifier unik (misal: `'cat_food'`, `'cat_salary'`).
* `name` (`TEXT NOT NULL`): Nama kategori (misal: `'Makanan & Minuman'`).
* `icon_name` (`TEXT NOT NULL`): Nama referensi ikon.
* `color_hex` (`TEXT NOT NULL`): Kode warna aksen kategori sesuai `DESIGN.md`.
* `type` (`TEXT NOT NULL`): `'income'` atau `'expense'`.

### 3.2. Tabel `transactions`
Menyimpan seluruh catatan pemasukan dan pengeluaran pengguna.
* `id` (`TEXT PRIMARY KEY`): UUID / timestamp unik.
* `title` (`TEXT NOT NULL`): Nama/judul transaksi (misal: `'Kopi Kenangan'`).
* `amount` (`REAL NOT NULL`): Nominal transaksi dalam Rupiah ($> 0$).
* `type` (`TEXT NOT NULL`): `'income'` atau `'expense'`.
* `category_id` (`TEXT NOT NULL`): Foreign Key ke `categories(id)`.
* `date` (`TEXT NOT NULL`): Format ISO-8601 (`YYYY-MM-DDTHH:mm:ss`).
* `note` (`TEXT`): Catatan tambahan opsional.
* `source` (`TEXT NOT NULL`): `'manual'` atau `'ai'` (penanda sumber pencatatan).
* `created_at` (`TEXT NOT NULL`): Timestamp pembuatan data.

### 3.3. Tabel `budgets`
Menyimpan target batas anggaran bulanan per kategori pengeluaran.
* `id` (`TEXT PRIMARY KEY`): Identifier unik.
* `category_id` (`TEXT NOT NULL`): Foreign Key ke `categories(id)`.
* `limit_amount` (`REAL NOT NULL`): Batas maksimal anggaran.
* `month` (`INTEGER NOT NULL`): Bulan ($1 - 12$).
* `year` (`INTEGER NOT NULL`): Tahun (misal: `2026`).

> **Catatan Arsitektur Budget:** Nilai terpakai (`spent_amount`) **tidak disimpan sebagai kolom statis**, melainkan dihitung secara dinamis melalui query SQL `COALESCE(SUM(amount), 0)` dari tabel `transactions` berdasarkan `category_id`, `type = 'expense'`, serta bulan dan tahun berjalan. Pendekatan ini menjamin angka *budget* selalu akurat meskipun pengguna mengedit atau menghapus transaksi lama.

---

## 4. Spesifikasi Fungsional & User Stories

### 4.1. Modul 1: Dashboard / Beranda (`beranda_harianku`)
* **Ringkasan Saldo Utama:** Menampilkan Saldo Bersih dengan rumus:
  $$\text{Saldo Bersih} = \sum \text{Pemasukan} - \sum \text{Pengeluaran}$$
* **Kartu Ringkasan Periode:** Menampilkan total Pemasukan (aksen Emerald Green) dan total Pengeluaran (aksen Coral Red) bulan berjalan.
* **AI Quick-Entry Shortcut Bar:** Widget input cepat di area utama Beranda bertuliskan *"Ceritakan transaksimu hari ini..."* untuk memicu *Bottom Sheet* AI.
* **Ringkasan Budget:** Menampilkan status keseluruhan anggaran bulan berjalan dan pintasan ke halaman Budget.
* **Transaksi Terbaru:** Menampilkan 5 transaksi terakhir dari SQLite dengan opsi *"Lihat Semua"* menuju halaman Riwayat.

### 4.2. Modul 2: AI Quick-Entry (Natural Language Input)
Fitur *shortcut* berbasis kecerdasan buatan yang memungkinkan pengguna mencatat satu atau beberapa transaksi sekaligus dalam satu kalimat.

* **Alur Kerja (User Flow):**
  1. Pengguna menekan *AI Quick-Entry Bar* di Beranda.
  2. Muncul *Modal Bottom Sheet* dengan kolom teks bebas dan tombol mikrofon/kirim (contoh input: *"Beli makan siang 35rb, isi bensin 50rb, dan dapat transferan freelance 750rb"*).
  3. Pengguna menekan tombol **Proses AI** (tombol masuk ke state `isLoading` dan dinonaktifkan sementara untuk mencegah *spam request* dan menjaga batas RPM API).
  4. `AiTransactionService` mengirim teks pengguna beserta daftar `categories` yang ada di SQLite ke **Gemini API**.
  5. Model AI mengembalikan array JSON terstruktur.
  6. Aplikasi menampilkan **Kartu Pratinjau (Preview Confirmation)** berisi daftar transaksi yang terdeteksi (Judul, Nominal, Tipe, Kategori, Tanggal). Pengguna dapat menghapus item yang salah atau mengedit nominal/kategori sebelum menyimpan.
  7. Pengguna menekan **Simpan Semua** $\rightarrow$ data dimasukkan ke tabel `transactions` SQLite secara *batch* $\rightarrow$ UI Beranda, Cashflow, dan Budget diperbarui otomatis.

* **Penanganan Kondisi Khusus (Edge Cases):**
  * **Offline / Tanpa Internet:** Jika perangkat tidak terhubung ke internet, tampilkan pesan ramah bahwa fitur AI membutuhkan koneksi internet, disertai tombol pintasan langsung menuju **Input Manual** agar pengguna tetap bisa mencatat transaksi.
  * **Input Tidak Relevan:** Jika pengguna memasukkan teks yang bukan transaksi keuangan (misal: *"Halo apa kabar"*), AI mengembalikan array kosong `[]` dan UI meminta pengguna menjelaskan nominal serta jenis transaksinya.

### 4.3. Modul 3: Pencatatan Transaksi Manual (`catat_transaksi_harianku`)
Tetap tersedia penuh melalui tombol tengah **FAB (`+`)** pada *Bottom Navigation Bar*.
* **Komponen Form:**
  * *Segmented Toggle* di bagian atas untuk memilih **Pengeluaran** atau **Pemasukan**.
  * Input nominal angka besar dengan pemisah ribuan otomatis (`Rp`).
  * Grid pemilih kategori (4 kolom) yang dinamis menyesuaikan tipe transaksi (`income` vs `expense`).
  * Pemilih tanggal (*Date Picker*, default hari ini) dan kolom catatan opsional.
* **Validasi:** Nominal wajib $> 0$ dan kategori wajib dipilih sebelum tombol **Simpan Transaksi** aktif.

### 4.4. Modul 4: Riwayat Transaksi (`riwayat_transaksi_harianku`)
* **Pengelompokan Kronologis:** Daftar transaksi dikelompokkan berdasarkan tanggal (misal: *Hari Ini*, *Kemarin*, atau format tanggal lengkap).
* **Pencarian & Filter:**
  * *Search Bar* untuk mencari berdasarkan judul atau catatan transaksi secara *real-time*.
  * *Filter Chips* berdasarkan tipe (`Semua`, `Pemasukan`, `Pengeluaran`), kategori tertentu, atau rentang tanggal/bulan.
* **Edit & Hapus Transaksi:** Mengetuk item transaksi membuka opsi detail untuk mengubah data atau menghapus transaksi (dengan dialog konfirmasi). Perubahan langsung memperbarui SQLite dan menghitung ulang saldo serta budget.

### 4.5. Modul 5: Cashflow & Analisis (`cashflow_harianku`)
* **Filter Rentang Waktu:** Segmented control untuk melihat analisis **Harian**, **Mingguan**, atau **Bulanan**.
* **Visualisasi Grafik:** Grafik perbandingan Pemasukan vs Pengeluaran (*Bar Chart* atau *Area Chart*) menggunakan `fl_chart`.
* **Rincian Pengeluaran per Kategori:** Daftar peringkat kategori dengan pengeluaran terbesar lengkap dengan nominal, persentase kontribusi terhadap total pengeluaran, dan *progress bar* berwarna.

### 4.6. Modul 6: Manajemen Budget (`budget_saya_harianku`)
* **Daftar Anggaran Kategori:** Menampilkan setiap kategori yang memiliki alokasi budget pada bulan berjalan beserta informasi `Terpakai / Batas Limit` dan sisa anggaran.
* **Tambah / Ubah Limit Budget:** Pengguna dapat mengatur batas anggaran baru atau mengubah nominal limit yang sudah ada melalui dialog/bottom sheet.
* **Indikator Status Visual (Sesuai `DESIGN.md`):**
  * **Aman (Hijau `#10B981`):** Pemakaian $< 75\%$ dari limit.
  * **Waspada (Amber `#F59E0B`):** Pemakaian antara $75\% - 95\%$ dari limit.
  * **Kritis / Over Budget (Merah `#EF4444`):** Pemakaian $> 95\%$ hingga $\ge 100\%$ dari limit.

---

## 5. Kontrak Integrasi Gemini API (`AiTransactionService`)

Untuk memastikan keluaran AI selalu konsisten dan aman diproses ke SQLite, panggilan API ke endpoint `gemini-2.5-flash` (atau `gemini-2.5-flash-lite`) wajib menggunakan konfigurasi **Structured Output (`application/json`)**.

### 5.1. Konfigurasi Keamanan API Key
* API Key disimpan pada file `.env` di root proyek:
  ```env
  GEMINI_API_KEY=AIzaSy_YOUR_API_KEY_HERE
  ```
* File `.env` wajib ditambahkan ke `.gitignore`.

### 5.2. Skema Output JSON yang Diharapkan dari Model AI
```json
{
  "transactions": [
    {
      "title": "Nasi Padang",
      "amount": 30000,
      "type": "expense",
      "category_id": "cat_food",
      "date": "2026-11-25",
      "note": "Makan siang"
    }
  ]
}
```

### 5.3. Instruksi Sistem (System Prompt) untuk Gemini
> *"Kamu adalah asisten pencatat keuangan pribadi untuk aplikasi Harianku. Tugasmu mengekstrak teks bahasa Indonesia menjadi daftar transaksi terstruktur dalam format JSON. Konversi singkatan nominal Indonesia dengan akurat ('rb'/'k' = x1.000, 'jt' = x1.000.000). Petakan setiap transaksi ke salah satu `category_id` yang tersedia di daftar kategori pengguna. Gunakan tanggal hari ini jika pengguna tidak menyebutkan waktu spesifik. Jika teks tidak mengandung informasi transaksi keuangan, kembalikan array `transactions` kosong."*

---

## 6. Kebutuhan Non-Fungsional (Non-Functional Requirements)

1. **Performa Database:** Gunakan *index* SQLite pada kolom `date` dan `category_id` di tabel `transactions` agar proses filter riwayat dan agregasi *cashflow* tetap instan meskipun data mencapai ribuan baris.
2. **Keamanan & Privasi Data:** Tidak ada pengiriman data database ke server eksternal. Koneksi jaringan hanya digunakan saat pengguna secara eksplisit menekan tombol proses pada fitur **AI Quick-Entry**.
3. **Kontrol Kuota API:** Terapkan penguncian tombol (*debounce / loading state*) selama permintaan ke Gemini API berlangsung agar pengguna tidak melakukan klik ganda yang dapat memicu batas *Requests Per Minute* (RPM) pada *Free Tier*.
4. **Konsistensi Visual:** Seluruh komponen UI wajib mengikuti palet warna, radius sudut (`16px-20px` untuk kartu utama), tipografi, dan ikonografi yang tercantum pada file `DESIGN.md`.

---

## 7. Panduan Eksekusi Bertahap untuk AI Coding Agent

Gunakan urutan langkah berikut saat menginstruksikan AI Agent di text editor Anda:

1. **Setup Dependensi:** Tambahkan `sqflite`, `path`, `provider` (atau `flutter_riverpod`), `flutter_dotenv`, `fl_chart`, `intl`, dan `google_generative_ai` (atau `http`) ke `pubspec.yaml`.
2. **Implementasi Tema & Desain:** Buat konfigurasi tema aplikasi berdasarkan `DESIGN.md`.
3. **Bangun Lapisan Database Lokal:** Implementasikan model data dan `DatabaseHelper` (SQLite) lengkap dengan skema 3 tabel dan *seed data* kategori awal.
4. **Bangun State Management:** Hubungkan `DatabaseHelper` dengan `FinanceProvider` untuk operasi CRUD transaksi, perhitungan saldo otomatis, agregasi *cashflow*, dan kalkulasi *budget*.
5. **Implementasi Layanan AI:** Buat `AiTransactionService` yang membaca `GEMINI_API_KEY` dari `.env` dan melakukan *parsing* teks alami ke daftar `TransactionModel`.
6. **Bangun Antarmuka 5 Layar Utama:** Implementasikan layar Beranda (termasuk *AI Quick-Entry Bottom Sheet*), Riwayat, Catat Transaksi Manual, Cashflow, dan Budget Saya sesuai prototipe UI.