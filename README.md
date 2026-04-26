# Hotel Reservasi — Flutter Mobile App
**Grand Mugarsari Hotel Reservation System**

Aplikasi mobile Flutter yang terintegrasi dengan REST API Next.js untuk sistem manajemen reservasi hotel.

---

## Deskripsi Proyek

Aplikasi ini merupakan implementasi **Tugas 2 Individu** mata kuliah Pengembangan Aplikasi Berbasis Platform. Dibangun menggunakan **Flutter** dengan arsitektur berlapis (layered architecture) dan terintegrasi penuh dengan backend REST API Next.js yang menggunakan autentikasi **JWT**.

---

## Arsitektur Aplikasi

```
lib/
├── main.dart                          # Entry point + Provider setup + Routes
├── models/
│   ├── app_constants.dart             # Konstanta: tipe kamar, status, harga
│   ├── user_model.dart                # Model User (id, username, email)
│   ├── reservation_model.dart         # Model Reservation (seluruh field DB)
│   └── api_response.dart              # Generic API response wrapper
├── services/
│   ├── auth_service.dart              # Login, Register, Logout, Token storage
│   └── reservation_service.dart       # CRUD Reservasi dengan JWT Bearer
├── providers/
│   ├── auth_provider.dart             # State auth (loading/error/idle)
│   └── reservation_provider.dart      # State reservasi (loading/error/loaded)
├── screens/
│   ├── splash_screen.dart             # Animasi splash + cek sesi JWT
│   ├── login_screen.dart              # Form login + validasi
│   ├── register_screen.dart           # Form registrasi akun baru
│   ├── dashboard_screen.dart          # Dashboard: statistik + reservasi terbaru
│   ├── reservations_screen.dart       # Daftar reservasi + search + filter
│   ├── reservation_detail_screen.dart # Detail lengkap satu reservasi
│   ├── reservation_form_screen.dart   # Form tambah/edit reservasi
│   └── profile_screen.dart            # Profil user + logout
└── widgets/
    ├── app_theme.dart                 # Tema warna, font, komponen
    ├── common_widgets.dart            # LoadingWidget, ErrorWidget, EmptyWidget
    ├── reservation_card.dart          # Card reservasi untuk list
    └── (StatusBadge di common_widgets)
```

---

## Fitur Apps

| Fitur | Status | Keterangan |
|-------|--------|------------|
| Flutter Framework | ✅ | Target Android |
| REST API Integration | ✅ | HTTP + JSON Parsing |
| JWT Authentication | ✅ | Login → simpan token → kirim di setiap request |
| Provider State Management | ✅ | AuthProvider + ReservationProvider |
| Three-State UI | ✅ | Loading / Error / Data |
| Layered Architecture | ✅ | Models / Services / Providers / Screens / Widgets |
| Navigasi Antar Halaman | ✅ | Named Routes |


| Fitur | Status | Keterangan |
|-------|--------|------------|
| CRUD Lengkap | ✅ | Tambah, Edit, Hapus via API |
| Pencarian Data | ✅ | Filter by nama, email, jenis kamar |
| Filter Status | ✅ | Semua / Booking / Dikonfirmasi / Check-In / Check-Out |
| Kalkulasi Harga Otomatis | ✅ | Real-time saat form diisi |
| Animasi & Transisi | ✅ | Splash, fade, slide |
| Responsive UI | ✅ | Material Design 3 |
| Statistics Dashboard | ✅ | Count per status + total pendapatan |

---

## Cara Menjalankan

### Prasyarat
- Flutter SDK ≥ 3.0.0
- Android Studio / VS Code dengan Flutter extension
- Backend Next.js berjalan

### Langkah

1. **Clone / extract project ini**
   ```bash
   cd hotel_reservasi_flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Jalankan backend Next.js**
   ```bash
   # Di folder reservasi-hotel
   npm install
   npm run dev
   # Backend berjalan di http://localhost:3000
   ```

4. **Konfigurasi URL API**

   Buka `lib/models/app_constants.dart`:
   ```dart
   // Untuk Android Emulator (localhost)
   const String kBaseUrl = 'http://10.0.2.2:3000';

   // Untuk device fisik, ganti dengan IP lokal:
   const String kBaseUrl = 'http://192.168.1.XXX:3000';
   ```

5. **Buat folder assets** (opsional)
   ```bash
   mkdir -p assets/images
   ```

6. **Jalankan aplikasi**
   ```bash
   # Emulator
   flutter run

   # Atau build APK
   flutter build apk --debug
   ```

---

## Alur Autentikasi JWT

```
User Login (email + password)
        ↓
POST /api/auth/login
        ↓
Response: { accessToken, user }
        ↓
Simpan token di SharedPreferences
        ↓
Setiap request API:
  Header: Authorization: Bearer <token>
        ↓
Backend verifikasi JWT → proses request
        ↓
Logout: hapus token dari SharedPreferences
```

---

## Halaman Aplikasi

| Route | Screen | Deskripsi |
|-------|--------|-----------|
| `/` | SplashScreen | Animasi logo + cek sesi |
| `/login` | LoginScreen | Form login JWT |
| `/register` | RegisterScreen | Form registrasi akun |
| `/dashboard` | DashboardScreen | Statistik & reservasi terbaru |
| `/reservations` | ReservationsScreen | Daftar + search + filter |
| `/reservations/detail` | DetailScreen | Detail satu reservasi |
| `/reservations/add` | FormScreen | Tambah reservasi baru |
| `/reservations/edit` | FormScreen | Edit reservasi (reuse form) |
| `/profile` | ProfileScreen | Info user + logout |

---

## Teknologi

| Layer | Teknologi |
|-------|-----------|
| Framework | Flutter 3.x |
| State Management | Provider 6.x |
| HTTP Client | http 1.x |
| Token Storage | shared_preferences 2.x |
| Backend | Next.js + SQLite + JWT |

---

## 📡 API Endpoints yang Digunakan

| Method | Endpoint | Deskripsi | Auth |
|--------|----------|-----------|------|
| POST | `/api/auth/register` | Daftar akun | ❌ |
| POST | `/api/auth/login` | Login, dapat token | ❌ |
| POST | `/api/auth/logout` | Logout | ✅ |
| GET | `/api/reservations` | Ambil semua reservasi | ✅ |
| POST | `/api/reservations` | Tambah reservasi | ✅ |
| GET | `/api/reservations/:id` | Detail reservasi | ✅ |
| PUT | `/api/reservations/:id` | Update reservasi | ✅ |
| DELETE | `/api/reservations/:id` | Hapus reservasi | ✅ |

---

## 👤 Informasi Tugas

- **Mata Kuliah**: Pengembangan Aplikasi Berbasis Platform
- **Tugas**: Tugas 2 Individu
- **Framework**: Flutter (Android)
- **Backend**: REST API Next.js
