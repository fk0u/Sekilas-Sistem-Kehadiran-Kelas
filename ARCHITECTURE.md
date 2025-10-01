# 🏗️ Arsitektur Aplikasi Sekilas

Dokumentasi teknis tentang arsitektur dan struktur kode aplikasi Sekilas.

## 📐 Arsitektur Overview

Aplikasi Sekilas menggunakan **Clean Architecture** dengan pembagian layer yang jelas:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI/Screens, Widgets, Controllers)     │
├─────────────────────────────────────────┤
│          Domain Layer                   │
│     (Business Logic, Use Cases)         │
├─────────────────────────────────────────┤
│           Data Layer                    │
│    (Database, Models, Repositories)     │
└─────────────────────────────────────────┘
```

## 📁 Struktur Folder

```
lib/
├── core/                       # Shared/Core functionality
│   ├── database/              # Database configuration & queries
│   │   ├── database.dart     # Drift database definition
│   │   └── database.g.dart   # Generated code
│   ├── router/               # Navigation configuration
│   │   └── app_router.dart   # GoRouter setup
│   └── theme/                # UI Theme & styling
│       └── app_theme.dart    # Material Theme
│
├── features/                  # Feature modules (by user role)
│   ├── onboarding/           # User onboarding flow
│   │   └── screens/
│   │       ├── role_selection_screen.dart
│   │       ├── teacher_onboarding_screen.dart
│   │       └── parent_onboarding_screen.dart
│   │
│   ├── teacher/              # Guru features
│   │   ├── screens/
│   │   ├── widgets/          # (coming soon)
│   │   └── providers/        # (coming soon)
│   │
│   ├── parent/               # Orang Tua features
│   │   ├── screens/
│   │   ├── widgets/          # (coming soon)
│   │   └── providers/        # (coming soon)
│   │
│   └── settings/             # Shared settings
│       └── providers/
│           └── theme_provider.dart
│
└── main.dart                 # App entry point
```

## 🗄️ Database Schema (Drift/SQLite)

### Tables

#### 1. **teachers**
```dart
- id: INT (PK, Auto Increment)
- name: TEXT (1-100 chars)
- className: TEXT (1-20 chars)
- pin: TEXT? (4-6 chars, nullable)
- createdAt: DATETIME
```

#### 2. **students**
```dart
- id: INT (PK, Auto Increment)
- name: TEXT (1-100 chars)
- className: TEXT (1-20 chars)
- photoPath: TEXT? (nullable)
- sortOrder: INT (default: 0)
- createdAt: DATETIME
```

#### 3. **parents**
```dart
- id: INT (PK, Auto Increment)
- studentId: INT (FK → students.id)
- name: TEXT (1-100 chars)
- phone: TEXT? (max 20 chars, nullable)
- pin: TEXT? (4-6 chars, nullable)
- createdAt: DATETIME
```

#### 4. **attendances**
```dart
- id: INT (PK, Auto Increment)
- studentId: INT (FK → students.id)
- date: DATETIME
- status: TEXT (hadir/izin/sakit/alpa)
- notes: TEXT? (nullable)
- permissionId: INT? (FK → permissions.id, nullable)
- createdAt: DATETIME
- updatedAt: DATETIME? (nullable)
```

#### 5. **permissions**
```dart
- id: INT (PK, Auto Increment)
- studentId: INT (FK → students.id)
- parentId: INT (FK → parents.id)
- permissionType: TEXT (izin/sakit)
- startDate: DATETIME
- endDate: DATETIME
- reason: TEXT? (nullable)
- attachmentPath: TEXT? (nullable)
- qrCode: TEXT (unique)
- isUsed: BOOLEAN (default: false)
- createdAt: DATETIME
```

#### 6. **app_settings**
```dart
- id: INT (PK, Auto Increment)
- key: TEXT (unique)
- value: TEXT
- updatedAt: DATETIME
```

### Relasi Antar Tabel

```
teachers ──┐
           │
students ──┼──→ attendances
           │
parents ───┴──→ permissions
```

## 🎯 State Management (Riverpod)

### Provider Hierarchy

```dart
ProviderScope
├── appDatabaseProvider          // Singleton database instance
├── appRouterProvider            // Router configuration
├── themeModeProvider            // Dark/Light mode state
├── teacherProvider              // (coming soon)
├── studentProvider              // (coming soon)
├── attendanceProvider           // (coming soon)
└── permissionProvider           // (coming soon)
```

### Provider Types

- **Provider**: Untuk dependencies yang tidak berubah (Database, Router)
- **StateNotifierProvider**: Untuk state yang complex (Theme, Auth)
- **FutureProvider**: Untuk async data (Database queries)
- **StreamProvider**: Untuk real-time data (Watch queries)

## 🧭 Routing (GoRouter)

### Route Structure

```
/ (root)
├── /role-selection          # Pilih role (Guru/Orang Tua)
├── /teacher-onboarding      # Setup guru
├── /parent-onboarding       # Setup orang tua
│
├── Teacher Routes:
│   ├── /teacher-home        # Dashboard guru
│   ├── /student-management  # Kelola siswa
│   ├── /attendance          # Absensi harian
│   ├── /scan-permission     # Scan QR izin
│   ├── /report              # Laporan & rekap
│   └── /teacher-settings    # Settings guru
│
└── Parent Routes:
    ├── /parent-home         # Dashboard orang tua
    ├── /create-permission   # Buat izin
    ├── /permission-history  # Riwayat izin
    └── /parent-settings     # Settings orang tua
```

## 🎨 Theme System

### Color Palette

```dart
Primary Colors:
- primaryBlue:      #4A90E2
- secondaryGreen:   #7ED321
- accentGreen:      #50C878

Status Colors:
- statusHadir:      #4CAF50  (✅ Hijau)
- statusIzin:       #FFC107  (🟡 Kuning)
- statusSakit:      #E91E63  (❤️ Pink)
- statusAlpa:       #F44336  (❌ Merah)

Light Theme:
- backgroundColor:  #FAFAFA
- cardColor:        #FFFFFF
- textPrimary:      #2C3E50
- textSecondary:    #7F8C8D

Dark Theme:
- darkBackground:   #121212
- darkSurface:      #1E1E1E
- darkCard:         #2C2C2C
- darkTextPrimary:  #E0E0E0
- darkTextSecondary: #B0B0B0
```

### Typography (Poppins)

```dart
displayLarge:   32px, Bold
displayMedium:  28px, SemiBold
displaySmall:   24px, SemiBold
headlineMedium: 20px, SemiBold
headlineSmall:  18px, Medium
titleLarge:     16px, Medium
bodyLarge:      16px, Regular
bodyMedium:     14px, Regular
bodySmall:      12px, Regular
```

## 🔄 Data Flow

### Teacher Flow: Membuat Absensi

```
1. User Input (UI)
      ↓
2. State Update (Provider)
      ↓
3. Database Write (Drift)
      ↓
4. UI Rebuild (Riverpod)
```

### Parent Flow: Membuat Izin

```
1. Fill Form (UI)
      ↓
2. Generate QR Code
      ↓
3. Save to Database
      ↓
4. Display/Share QR
```

### Teacher Flow: Scan QR

```
1. Scan QR Code
      ↓
2. Parse Data
      ↓
3. Validate Permission
      ↓
4. Update Attendance
      ↓
5. Mark Permission as Used
```

## 📦 Dependencies Overview

### Core Dependencies

| Package | Purpose | Version |
|---------|---------|---------|
| flutter_riverpod | State management | ^2.4.9 |
| drift | Local database | ^2.14.1 |
| go_router | Navigation | ^13.0.0 |
| google_fonts | Typography | ^6.1.0 |

### Feature Dependencies

| Package | Purpose | Version |
|---------|---------|---------|
| qr_flutter | Generate QR | ^4.1.0 |
| mobile_scanner | Scan QR | ^3.5.5 |
| google_mlkit_text_recognition | OCR | ^0.11.0 |
| pdf | PDF generation | ^3.10.7 |
| excel | Excel export | ^4.0.2 |
| fl_chart | Charts | ^0.66.0 |

### Utility Dependencies

| Package | Purpose | Version |
|---------|---------|---------|
| path_provider | File paths | ^2.1.1 |
| image_picker | Image selection | ^1.0.7 |
| share_plus | Share functionality | ^7.2.1 |
| file_picker | File selection | ^6.1.1 |

## 🔐 Security Considerations

1. **PIN Storage**: Menggunakan `flutter_secure_storage`
2. **Database**: SQLite dengan encryption (optional)
3. **QR Code**: Contains encrypted data
4. **Backup Files**: Encrypted `.abs` format

## 🚀 Performance Optimization

1. **Lazy Loading**: Screens loaded on-demand
2. **Database Indexing**: Indexed queries untuk performance
3. **Image Caching**: Cached student photos
4. **Pagination**: Large lists paginated
5. **Stream Queries**: Real-time updates dengan minimal rebuild

## 📱 Platform Specific

### Android
- Min SDK: 21 (Android 5.0)
- Target SDK: 33 (Android 13)

### iOS
- Min iOS: 11.0

### Web
- PWA capable
- Offline mode dengan service workers

## 🧪 Testing Strategy (Coming Soon)

```
tests/
├── unit/              # Unit tests
├── widget/            # Widget tests
└── integration/       # E2E tests
```

## 📝 Best Practices

1. **Separation of Concerns**: UI, Logic, Data terpisah
2. **Immutability**: Use immutable data structures
3. **Error Handling**: Try-catch dengan user-friendly messages
4. **Logging**: Debug logs untuk development
5. **Documentation**: Inline comments untuk complex logic

---

**Last Updated**: October 2025
