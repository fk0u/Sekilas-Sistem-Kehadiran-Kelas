# 🚀 Getting Started - Sekilas App

Panduan lengkap untuk menjalankan aplikasi Sekilas di komputer Anda.

## ✅ Prerequisites

Pastikan sudah terinstall:

- **Flutter SDK** (3.0.0 atau lebih tinggi)
  - Download: https://flutter.dev/docs/get-started/install
- **Android Studio** atau **VS Code** (untuk development)
- **Android SDK** (untuk build Android)
- **Dart SDK** (included dengan Flutter)

### Cek Instalasi Flutter

Jalankan perintah berikut untuk memastikan Flutter sudah terinstall dengan benar:

```bash
flutter doctor
```

Pastikan tidak ada error (⚠️ warning boleh diabaikan).

## 📦 Instalasi

### 1. Clone Repository

```bash
cd "C:\Users\HP VICTUS\Documents\GitHub"
git clone https://github.com/fk0u/Sekilas-Sistem-Kehadiran-Kelas.git
cd "Sekilas (Sistem Kehadiran Kelas)"
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Database Code

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. (Opsional) Setup Font Lokal

Font Poppins akan otomatis di-download oleh `google_fonts` package. Jika ingin setup manual, lihat file `FONT_SETUP.md`.

## ▶️ Menjalankan Aplikasi

### Android/iOS (Emulator atau Device)

```bash
# Jalankan di device/emulator yang terhubung
flutter run

# Atau pilih device tertentu
flutter devices          # Lihat daftar device
flutter run -d <device>  # Jalankan di device tertentu
```

### Web (Browser)

```bash
flutter run -d chrome
# atau
flutter run -d edge
```

### Desktop (Windows)

```bash
flutter run -d windows
```

## 🔨 Build APK untuk Android

### Debug APK (untuk testing)

```bash
flutter build apk --debug
```

File APK ada di: `build\app\outputs\flutter-apk\app-debug.apk`

### Release APK (untuk distribusi)

```bash
flutter build apk --release
```

File APK ada di: `build\app\outputs\flutter-apk\app-release.apk`

### Split APK per ABI (ukuran lebih kecil)

```bash
flutter build apk --split-per-abi --release
```

File APK ada di:
- `app-armeabi-v7a-release.apk` (untuk device lama)
- `app-arm64-v8a-release.apk` (untuk device modern)
- `app-x86_64-release.apk` (untuk emulator/tablet Intel)

## 🌐 Build Web (PWA)

```bash
flutter build web --release
```

Output ada di folder: `build\web\`

Untuk test hasil build web:

```bash
cd build\web
python -m http.server 8000
# Buka browser: http://localhost:8000
```

## 📱 Install APK ke Device

### Via USB

1. Enable **Developer Options** di Android:
   - Settings → About Phone → Tap "Build Number" 7x
   - Settings → Developer Options → Enable "USB Debugging"

2. Connect device ke komputer

3. Install APK:

```bash
flutter install
# atau manual
adb install build\app\outputs\flutter-apk\app-release.apk
```

### Via File Manager

1. Copy file APK ke ponsel
2. Buka file manager
3. Tap file APK
4. Allow "Install from Unknown Sources" jika diminta
5. Tap "Install"

## 🔧 Troubleshooting

### Error: "Gradle build failed"

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Error: "Waiting for another flutter command to release startup lock"

```bash
# Hapus file lock
rm "$FLUTTER_ROOT/bin/cache/lockfile"
# atau di Windows:
del "%LOCALAPPDATA%\Pub\Cache\.flutter-plugins-dependencies"
```

### Error: Database schema

```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Hot Reload tidak bekerja

Restart aplikasi dengan:
- Press `R` di terminal (hot restart)
- Press `r` di terminal (hot reload)

## 📊 Development Mode

### Debug dengan DevTools

```bash
flutter run
# Kemudian tekan 'v' untuk membuka DevTools di browser
```

### View Log

```bash
flutter logs
# atau
adb logcat | grep flutter
```

### Analyze Code

```bash
flutter analyze
```

### Format Code

```bash
dart format .
```

## 🎯 Quick Commands Cheat Sheet

| Perintah | Fungsi |
|----------|--------|
| `flutter run` | Jalankan app di device |
| `r` | Hot reload |
| `R` | Hot restart |
| `q` | Quit/stop app |
| `flutter clean` | Bersihkan build cache |
| `flutter pub get` | Install dependencies |
| `flutter build apk` | Build APK |
| `flutter devices` | Lihat daftar device |
| `flutter doctor` | Cek setup Flutter |

## 📝 Tips

1. **Gunakan Hot Reload**: Save file (Ctrl+S) untuk instant reload
2. **Debug Layout**: Tekan `p` saat app running untuk toggle debug paint
3. **Performance**: Tekan `P` untuk performance overlay
4. **Inspector**: Tekan `i` untuk widget inspector

## 🆘 Butuh Bantuan?

- 📖 Dokumentasi: Lihat `PROJECT_STATUS.md` untuk status proyek
- 🐛 Bug Report: Buat issue di GitHub
- 💬 Diskusi: Buka discussion di GitHub repository

---

**Selamat coding! 🎉**
