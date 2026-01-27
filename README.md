# 📚 Ruang Les

Aplikasi mobile untuk manajemen les privat dengan 3 role pengguna: **Siswa**, **Orang Tua**, dan **Pengajar**.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?logo=firebase)
![License](https://img.shields.io/badge/License-MIT-green)

## 📱 Screenshots

| Siswa | Orang Tua | Pengajar |
|:-----:|:---------:|:--------:|
| Beranda, Kuis, Materi | Monitoring Anak, Pembayaran | Kelola Kelas, Absensi |

## ✨ Fitur Utama

### 👨‍🎓 Siswa
- Dashboard dengan progress belajar
- Mengerjakan kuis interaktif
- Melihat materi pelajaran
- Sistem reward & achievement
- Profil dan pengaturan

### 👨‍👩‍👧 Orang Tua
- **Monitoring anak** (nilai, kehadiran, progress)
- **Pembayaran** tagihan les
- **Laporan belajar** detail
- **Tambah anak** (buat profil atau tautkan akun)

### 👨‍🏫 Pengajar
- Manajemen kelas & siswa
- Buat dan kelola kuis
- Upload materi pembelajaran (PDF, DOC, PPT)
- Rekap absensi & laporan
- Verifikasi pembayaran

## 🏗️ Arsitektur

```
lib/
├── core/               # Shared utilities
│   ├── models/         # Data models (UserModel, StudentModel, dll)
│   └── utils/          # Colors, Routes, Constants
├── data/
│   └── repositories/   # Firebase data access layer
├── features/
│   ├── auth/           # Login & Register
│   ├── student/        # Fitur Siswa
│   ├── parent/         # Fitur Orang Tua
│   ├── teacher/        # Fitur Pengajar
│   └── general/        # Shared services
└── main.dart           # Entry point dengan Provider setup
```

## 🔧 Tech Stack

| Kategori | Teknologi |
|----------|-----------|
| Framework | Flutter 3.0+ |
| Backend | Firebase (Auth, Firestore, Storage) |
| State Management | Provider |
| File Upload | Firebase Storage + file_picker |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Firebase Project
- Android Studio / VS Code

### Installation

1. **Clone repository**
   ```bash
   git clone https://github.com/chocochips-wq/ruang_les.git
   cd ruang_les
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase**
   - Buat project di [Firebase Console](https://console.firebase.google.com)
   - Download `google-services.json` (Android) dan `GoogleService-Info.plist` (iOS)
   - Letakkan di folder `android/app/` dan `ios/Runner/`

4. **Buat Firestore Indexes** (jika ada error)
   - Lihat file `FIRESTORE_INDEXES.md` untuk daftar index yang diperlukan

5. **Run aplikasi**
   ```bash
   flutter run
   ```
   
   Untuk web:
   ```bash
   flutter run -d chrome
   ```

## 📂 Dokumentasi Tambahan

| File | Deskripsi |
|------|-----------|
| `FIRESTORE_INDEXES.md` | Daftar composite index Firestore |
| `REGISTRATION_FLOW.md` | Alur pendaftaran pengguna |
| `STUDENT_FEATURES.md` | Dokumentasi fitur siswa |
| `PARENT_STUDENT_PAYMENT.md` | Sistem pembayaran |
| `LAPORAN_PROYEK.md` | Laporan pengembangan proyek |

## 👥 Role & Akses

| Role | Email Pattern | Dashboard |
|------|---------------|-----------|
| Siswa | `*@student.com` | `/student/home` |
| Orang Tua | `*@parent.com` | `/parent/home` |
| Pengajar | `*@teacher.com` | `/teacher/home` |

## 🔐 Firebase Security Rules

Pastikan Firestore rules sudah dikonfigurasi untuk:
- Siswa hanya bisa akses data sendiri
- Orang tua bisa akses data anak yang terhubung
- Pengajar bisa akses data kelas yang diajar

## 📄 License

MIT License - Lihat [LICENSE](LICENSE) untuk detail.

## 👨‍💻 Contributors

- **Isma** - Developer Utama

---

<p align="center">
  Made with ❤️ using Flutter & Firebase
</p>
