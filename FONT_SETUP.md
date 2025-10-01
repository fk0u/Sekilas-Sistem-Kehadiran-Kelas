# Instruksi Download Font Poppins

Aplikasi Sekilas menggunakan font **Poppins** dari Google Fonts. Berikut cara mendapatkan font tersebut:

## Download Otomatis (Disarankan)

Font Poppins akan otomatis di-download oleh package `google_fonts` saat aplikasi pertama kali dijalankan.

## Download Manual (Opsional)

Jika Anda ingin menyimpan font secara lokal:

### Cara 1: Dari Google Fonts Website

1. Kunjungi: https://fonts.google.com/specimen/Poppins
2. Klik tombol "Download family"
3. Extract file ZIP yang di-download
4. Copy file-file berikut ke folder `assets/fonts/`:
   - `Poppins-Regular.ttf`
   - `Poppins-Medium.ttf`
   - `Poppins-SemiBold.ttf`
   - `Poppins-Bold.ttf`

### Cara 2: Menggunakan Command Line (Linux/Mac)

```bash
cd "c:\Users\HP VICTUS\Documents\GitHub\Sekilas (Sistem Kehadiran Kelas)\assets\fonts"

# Download langsung dari Google Fonts
curl -o Poppins.zip "https://fonts.google.com/download?family=Poppins"
unzip Poppins.zip
```

### Cara 3: Menggunakan PowerShell (Windows)

```powershell
# Buka PowerShell dan jalankan:
cd "c:\Users\HP VICTUS\Documents\GitHub\Sekilas (Sistem Kehadiran Kelas)\assets\fonts"

# Download menggunakan Invoke-WebRequest
Invoke-WebRequest -Uri "https://fonts.google.com/download?family=Poppins" -OutFile "Poppins.zip"

# Extract
Expand-Archive -Path "Poppins.zip" -DestinationPath "."
```

## Verifikasi

Pastikan struktur folder seperti ini:

```
assets/
└── fonts/
    ├── Poppins-Regular.ttf
    ├── Poppins-Medium.ttf
    ├── Poppins-SemiBold.ttf
    └── Poppins-Bold.ttf
```

## Catatan

- Jika folder `assets/fonts/` belum ada, buat terlebih dahulu
- Font sudah dikonfigurasi di `pubspec.yaml`
- Aplikasi akan tetap berjalan tanpa font lokal karena menggunakan `google_fonts` package
