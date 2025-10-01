# 🎯 Quick Start Guide - Test Aplikasi Sekilas

## 📱 Yang Sudah Bisa Dicoba

### 1. Flow Guru (Teacher)

#### Onboarding
1. Buka app → Pilih "Saya Guru"
2. Masukkan nama dan kelas (contoh: "Bu Ani", "5A")
3. Klik "Mulai"

#### Kelola Siswa
1. Dari home, tap "Kelola Siswa"
2. Tap tombol FAB "Tambah Siswa" (bawah kanan)
3. Masukkan nama siswa (contoh: "Budi Santoso")
4. Klik "Tambah"
5. **Test Edit:** Tap menu ⋮ → Edit → Ubah nama → Simpan
6. **Test Hapus:** Tap menu ⋮ → Hapus → Konfirmasi
7. **Test Search:** Gunakan search bar untuk cari siswa

#### Absensi Harian
1. Dari home, tap "Absensi Harian"
2. Tap icon kalender untuk pilih tanggal
3. **One-Tap Status:** Tap pada card siswa untuk cycle status:
   - None → Hadir (hijau)
   - Hadir → Izin (kuning)
   - Izin → Sakit (merah)  
   - Sakit → Alpa (abu)
   - Alpa → None
4. **Quick Action:** Tap "Tandai Semua Hadir" untuk mark all
5. Tap FAB "Simpan Absensi"

---

### 2. Flow Orang Tua (Parent)

#### Onboarding
1. Buka app → Pilih "Saya Orang Tua"
2. Masukkan nama (contoh: "Pak Bambang")
3. Pilih kelas dari dropdown
4. Pilih nama siswa dari dropdown
5. Klik "Mulai"

#### Buat Izin
1. Dari home, tap "Ajukan Izin"
2. Pilih jenis: Izin atau Sakit (radio button)
3. Tap "Tanggal Mulai" → Pilih tanggal
4. Tap "Tanggal Selesai" → Pilih tanggal
5. Isi alasan (min 10 karakter)
6. Tap "Buat Izin"

#### Riwayat Izin
1. Dari home, tap "Riwayat Izin"
2. Lihat list semua izin yang pernah dibuat
3. Badge "Aktif" (orange) atau "Terpakai" (hijau)

---

## 🎨 UI Features to Notice

### Visual Feedback:
- ✅ Cards dengan shadow dan rounded corners
- ✅ Ripple effects pada tap
- ✅ Color-coded status indicators
- ✅ Toast notifications (SnackBar)
- ✅ Loading states
- ✅ Empty states dengan ilustrasi

### Interactions:
- ✅ Smooth transitions
- ✅ Dialog forms
- ✅ Date pickers
- ✅ Search functionality
- ✅ Menu actions (PopupMenu)

---

## 🐛 Known Limitations (Not Implemented Yet)

### Guru:
- ❌ Import siswa dari text/OCR
- ❌ Scan QR izin
- ❌ Reports & statistik
- ❌ Export PDF/Excel
- ❌ Settings (PIN, dark mode)

### Orang Tua:
- ❌ Generate & tampilkan QR code
- ❌ Detail permission dengan QR
- ❌ Settings (PIN, dark mode)

---

## 💡 Testing Tips

### Test Data Persistence:
1. Tambah beberapa siswa
2. Close app (force stop)
3. Buka lagi → Data tetap ada ✅

### Test Real-time Updates:
1. Buka Student Management
2. Tambah siswa
3. Siswa langsung muncul di list (no refresh)

### Test Form Validation:
1. Try submit form kosong
2. Try nama siswa < 3 karakter
3. Try alasan izin < 10 karakter
4. Should show error messages

### Test Navigation:
1. Back button works
2. Home navigation works
3. Bottom tabs work

---

## 📋 Test Checklist

### Student Management:
- [ ] Add student
- [ ] Edit student name
- [ ] Delete student with confirmation
- [ ] Search student by name
- [ ] Empty state when no students
- [ ] Toast notifications appear

### Attendance:
- [ ] Select different dates
- [ ] Toggle student status (tap multiple times)
- [ ] Mark all present button works
- [ ] Save attendance (check toast)
- [ ] Date displays in Indonesian format
- [ ] Legend shows correct colors

### Parent Permission:
- [ ] Choose permission type (izin/sakit)
- [ ] Pick start date
- [ ] Pick end date (must be >= start date)
- [ ] Fill reason (min 10 chars)
- [ ] Submit creates new permission
- [ ] Permission appears in history
- [ ] Badge shows correct status

---

## 🎯 Expected Behavior

### Successful Operations:
- ✅ Green SnackBar dengan message
- ✅ Auto-close dialog
- ✅ Data appears in list immediately

### Failed Operations:
- ❌ Red SnackBar dengan error message
- ❌ Form shows validation errors

### Loading States:
- ⏳ Circular progress indicator
- ⏳ "Memuat..." message

---

## 🚀 Next Steps After Testing

1. Collect feedback pada UI/UX
2. Note any bugs or issues
3. Suggest improvements
4. Priority features to add next:
   - QR Code system
   - Import students
   - Reports

---

**Happy Testing!** 🎉
