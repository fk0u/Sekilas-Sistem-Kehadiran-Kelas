# Sekilas - Sistem Kehadiran Kelas

> **Status:** 🚧 Dalam Pengembangan - MVP (Minimum Viable Product)

Aplikasi absensi sekolah offline untuk Guru dan Orang Tua dengan desain minimalis dan modern. Semua data disimpan lokal, tanpa internet/server.

## ✨ Fitur yang Sudah Dibuat

### ✅ Arsitektur & Foundation
- [x] Setup proyek Flutter multiplatform
- [x] Database lokal dengan Drift (SQLite)
- [x] State management dengan Riverpod
- [x] Routing dengan GoRouter
- [x] Theme system (Light & Dark Mode)
- [x] Struktur folder yang terorganisir

### ✅ Onboarding
- [x] Role selection screen (Guru/Orang Tua)
- [x] Teacher onboarding
- [x] Parent onboarding

### ✅ Teacher Features (Basic)
- [x] Home screen dengan bottom navigation
- [x] Student management placeholder
- [x] Attendance placeholder
- [x] QR Scanner placeholder
- [x] Report placeholder
- [x] Settings placeholder

### ✅ Parent Features (Basic)
- [x] Home screen dengan bottom navigation
- [x] Create permission placeholder
- [x] Permission history placeholder
- [x] Settings placeholder

## 🚧 Fitur yang Perlu Dikembangkan

### 📱 Untuk Guru
- [ ] **Manajemen Siswa Lengkap**
  - [ ] Tambah siswa manual
  - [ ] Import dari teks/paste
  - [ ] OCR dari foto daftar nama
  - [ ] Edit & hapus siswa
  - [ ] Sorting A-Z otomatis

- [ ] **Absensi Harian Interaktif**
  - [ ] Grid view siswa dengan foto
  - [ ] One-tap status change (Hadir/Izin/Sakit/Alpa)
  - [ ] Bulk action "Tandai Semua Hadir"
  - [ ] Catatan per siswa
  - [ ] Kalender view

- [ ] **QR Scanner**
  - [ ] Scan dari kamera
  - [ ] Scan dari galeri
  - [ ] Parse data izin
  - [ ] Auto-fill absensi

- [ ] **Rekap & Laporan**
  - [ ] Filter periode (1/3/6/12 bulan)
  - [ ] Tabel rekap per siswa
  - [ ] Grafik absensi
  - [ ] Detail per siswa

- [ ] **Export**
  - [ ] PDF (siap cetak)
  - [ ] Excel spreadsheet

- [ ] **Settings**
  - [ ] Edit profil & kelas
  - [ ] Backup/Restore database
  - [ ] PIN security
  - [ ] Dark mode toggle

### 👨‍👩‍👧 Untuk Orang Tua
- [ ] **Ajukan Izin/Sakit**
  - [ ] Form lengkap (jenis, tanggal, keterangan)
  - [ ] Single date picker
  - [ ] Date range picker
  - [ ] Upload foto lampiran
  - [ ] Generate QR code

- [ ] **QR Code Display**
  - [ ] Show QR on screen
  - [ ] Save to gallery
  - [ ] Share via WhatsApp/etc

- [ ] **Riwayat**
  - [ ] List semua izin
  - [ ] Detail izin
  - [ ] Status (terpakai/belum)

- [ ] **Settings**
  - [ ] Edit profil anak
  - [ ] PIN security
  - [ ] Dark mode toggle

## 🎨 Design System

### Warna
- Primary: `#4A90E2` (Biru)
- Secondary: `#7ED321` (Hijau)
- Status Hadir: `#4CAF50` (Hijau)
- Status Izin: `#FFC107` (Kuning)
- Status Sakit: `#E91E63` (Pink)
- Status Alpa: `#F44336` (Merah)

### Font
- Family: Poppins
- Weights: Regular (400), Medium (500), SemiBold (600), Bold (700)

## 🚀 Quick Start

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate database code
dart run build_runner build --delete-conflicting-outputs

# 3. Run app
flutter run

# 4. Build APK
flutter build apk --release
```

## 📁 Struktur Proyek

```
lib/
├── core/
│   ├── database/       # Drift database & queries
│   ├── router/         # GoRouter configuration
│   └── theme/          # Theme & styling
├── features/
│   ├── onboarding/     # Role selection & setup
│   ├── teacher/        # Fitur untuk guru
│   ├── parent/         # Fitur untuk orang tua
│   └── settings/       # Shared settings
└── main.dart
```

## 📦 Dependencies Utama

| Package | Fungsi |
|---------|--------|
| flutter_riverpod | State management |
| drift | Database lokal |
| go_router | Navigation |
| google_fonts | Font Poppins |
| qr_flutter | Generate QR |
| mobile_scanner | Scan QR |
| google_mlkit_text_recognition | OCR |
| pdf, printing | Export PDF |
| excel | Export Excel |
| fl_chart | Grafik |

## 🎯 Prioritas Pengembangan

### Phase 1: MVP Core Features (Prioritas Tinggi)
1. ✅ Database & routing setup
2. ✅ Onboarding flow
3. 🚧 Manajemen siswa (CRUD)
4. 🚧 Absensi harian dasar
5. 🚧 QR code generation (orang tua)
6. 🚧 QR scanner (guru)

### Phase 2: Essential Features
7. Rekap & statistik
8. Dark mode implementation
9. Export PDF/Excel
10. Backup & restore

### Phase 3: Advanced Features
11. OCR import siswa
12. PIN security
13. Grafik detail
14. Advanced filters

## 🐛 Known Issues

1. Font Poppins perlu di-download manual atau akan auto-download oleh google_fonts
2. Belum ada splash screen
3. Belum ada app icon custom
4. Database migration strategy belum diimplementasi

## 📝 TODO Next

- [ ] Implementasi CRUD siswa
- [ ] Buat UI absensi grid interaktif
- [ ] Implementasi QR generator
- [ ] Implementasi QR scanner
- [ ] Tambah date picker untuk absensi
- [ ] Buat provider untuk attendance state
- [ ] Implementasi dark mode toggle
- [ ] Add app icon & splash screen

## 🤝 Kontribusi

Proyek ini masih dalam tahap pengembangan. Kontribusi sangat diterima!

## 📄 License

MIT License

---

**Built with ❤️ using Flutter**
