# Panduan Fitur Student Role - Ruang Les

## Ringkasan Perubahan dan Penambahan

Fitur-fitur berikut telah ditambahkan/diperbaiki untuk meningkatkan pengalaman belajar siswa:

### ✅ 1. Login Halaman Student (Sederhana & Ramah Anak)
**File**: `lib/features/student/pages/student_login.dart`

Halaman login khusus untuk siswa dengan:
- Desain yang ceria dan mudah dipahami anak-anak
- Animasi emoji selamat datang
- Validasi input yang user-friendly
- Error message yang jelas dan ramah
- Link ke halaman register dan forgot password
- Tips penggunaan

**Cara Penggunaan:**
```dart
Navigator.of(context).pushNamed(AppRoutes.studentLogin);
```

### ✅ 2. Progress Belajar Realtime
**File**: 
- `lib/core/models/progress_model.dart` - Model data
- `lib/data/repositories/progress_repository.dart` - Repository dengan Firestore integration
- `lib/features/student/widgets/student_progress_widget.dart` - UI Widget

Fitur ini menampilkan:
- **Progress Bar dengan XP**: Menunjukkan progres siswa menuju level berikutnya
- **Level System**: Siswa naik level seiring mengumpulkan XP
- **Statistics**: Jumlah topik dan aktivitas yang sudah diselesaikan
- **Real-time Updates**: Data diupdate otomatis dari Firestore menggunakan streams

**Struktur Data Progress:**
```dart
StudentProgressModel {
  studentId: String,
  currentLevel: int,        // Level saat ini (1-10)
  experiencePoints: int,    // XP saat ini
  maxExperiencePoints: int, // XP untuk level up
  completedTopics: List<String>,
  completedActivities: List<String>,
}
```

### ✅ 3. Achievement & Badges System
**File**:
- `lib/core/models/progress_model.dart` - AchievementModel
- `lib/features/student/widgets/student_progress_widget.dart` - UI Badge Display
- `lib/features/student/widgets/reward_widget.dart` - Reward Dialog & Animations

Pencapaian yang tersedia:
- 🌟 **Permulaan Gemilang** - Menyelesaikan 5 aktivitas pertama
- 🧮 **Jenius Matematika** - 10 soal matematika berturut-turut benar
- 📚 **Pembaca Setia** - 3 topik Bahasa Indonesia
- 🔬 **Scientis Muda** - Semua eksperimen IPA
- 🌍 **Polyglot Cilik** - 50 kosakata Bahasa Inggris
- 🗺️ **Petualang Peta** - 5 negara di IPS
- 👑 **Legenda Ruang Les** - Mencapai level 10
- 🔥 **Giat Belajar** - 7 hari belajar berturut-turut

**Reward Widgets:**
- `RewardDialog` - Dialog animasi dengan celebrasi
- `RewardSnackBar` - Notifikasi slide dari atas
- `MotivationalMessage` - Pesan motivasi otomatis

### ✅ 4. Quiz System dengan Dummy Data
**Files**:
- `lib/core/models/quiz_model.dart` - QuizModel & QuizQuestion
- `lib/data/repositories/quiz_repository.dart` - Quiz Firestore operations
- `lib/features/student/pages/quiz_list.dart` - Halaman daftar kuis
- `lib/core/utils/quiz_seeding.dart` - Dummy quiz data seeding

**5 Quiz Dummy yang Tersedia:**
1. 🧮 **Matematika Dasar** - 3 soal (35 poin)
2. 🇬🇧 **Bahasa Inggris Dasar** - 3 soal (35 poin)
3. 🌱 **IPA - Tumbuhan** - 3 soal (40 poin)
4. 🗺️ **IPS - Benua Dunia** - 3 soal (40 poin)
5. 📖 **Bahasa Indonesia - Tata Bahasa** - 3 soal (40 poin)

**Fitur Quiz:**
- 📋 List kuis dengan status (Belum/Selesai)
- ⏳ Menampilkan jumlah soal dan total poin
- ✅ Menampilkan skor dan persentase jika sudah selesai
- 🔄 Real-time stream dari Firestore
- 🎯 Button untuk mulai/lihat ulang kuis

### ✅ 5. Profil Student yang Lengkap
**File**: `lib/features/student/pages/student_profile.dart`

Menampilkan:
- 📸 Avatar dengan opsi ubah
- 👤 Nama panggilan (nickname) dan nama lengkap
- 📖 Tingkat kelas (Grade Level)
- 📊 Progress belajar real-time
- 🏆 Achievement badges yang sudah dibuka
- 📞 Informasi kontak

### ✅ 5. Home Page Student yang Diperbaiki
**File**: `lib/features/student/pages/student_home.dart`

Ditampilkan di home:
- Greeting card dengan nama siswa
- Statistik pembelajaran (tugas selesai, rata-rata nilai)
- **Progress Card** - Progress bar dan XP display
- **Achievement Badges** - 6 badges terbaru yang sudah dibuka
- Kelas aktif
- Progress per kelas
- Aktivitas terbaru

### ✅ 6. Provider dengan Real-time Streams
**File**: `lib/features/student/providers/student_provider.dart`

Provider baru mendukung:
```dart
// Load data
loadStudentByUserId(userId);

// Stream untuk real-time updates
streamProgress(studentId);
streamAchievements(studentId);
streamUnlockedAchievements(studentId);

// Action methods
addExperiencePoints(points);
completeActivity(activityId);
completeTopic(topicId);
unlockAchievement(achievementId);
```

### ✅ 7. Data Seeding untuk Development
**Files**:
- `lib/core/utils/firebase_seeding.dart` - Seeding logic
- `lib/core/utils/data_seeding_dialog.dart` - UI untuk seeding

**Dummy Data yang Diseed:**
- Progress: Level 3, 75 XP, 3 topics, 4 activities completed
- 8 Achievement badges dengan berbagai kategori

**Cara Menggunakan:**
1. Buka halaman profil student
2. Scroll ke bawah
3. Klik tombol "Seed Data (Dev)"
4. Pilih "Seed Data" untuk menambah dummy data
5. Pilih "Clear Data" untuk menghapus dummy data

---

## Struktur Database Firestore

### Collection: `student_progress`
```json
{
  "studentId": "string",
  "currentLevel": 3,
  "maxLevel": 10,
  "experiencePoints": 75,
  "maxExperiencePoints": 100,
  "progressPercentage": 0.75,
  "completedTopics": ["topic_1", "topic_2", "topic_3"],
  "completedActivities": ["activity_1", "activity_2", "activity_3", "activity_4"],
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Collection: `achievements`
```json
{
  "studentId": "string",
  "title": "Permulaan Gemilang",
  "description": "Menyelesaikan 5 aktivitas pertama",
  "icon": "🌟",
  "points": 50,
  "category": "badge",  // atau "sticker"
  "isUnlocked": true,
  "unlockedAt": "timestamp"
}
```

### Collection: `quizzes`
```json
{
  "studentId": "string",
  "classId": "string",
  "title": "Matematika Dasar",
  "description": "Kuis tentang penjumlahan dan pengurangan",
  "questions": [
    {
      "id": "q1",
      "question": "Berapa hasil dari 5 + 3?",
      "options": ["6", "8", "9", "10"],
      "correctOptionIndex": 1,
      "points": 10,
      "selectedOptionIndex": null
    }
  ],
  "totalPoints": 35,
  "score": 0,
  "isCompleted": false,
  "createdAt": "timestamp",
  "completedAt": null
}
```

---

## Cara Implementasi

### 1. Integrate Student Provider & Quiz Repository
```dart
ChangeNotifierProvider(
  create: (context) => StudentProvider(
    StudentRepository(),
    ClassRepository(),
    SessionRepository(),
    ProgressRepository(),
  ),
  child: const BerandaMurid(),
),

// Atau dengan Provider untuk QuizRepository
Provider<QuizRepository>(
  create: (_) => QuizRepository(),
),
```

### 2. Tampilkan Progress di Widget
```dart
StreamBuilder(
  stream: _progressRepository.streamProgressByStudentId(studentId),
  builder: (context, snapshot) {
    final progress = snapshot.data;
    return StudentProgressCard(progress: progress);
  },
),
```

### 3. Tampilkan Achievements
```dart
StreamBuilder(
  stream: _progressRepository.streamUnlockedAchievements(studentId),
  builder: (context, snapshot) {
    final achievements = snapshot.data ?? [];
    return AchievementBadges(achievements: achievements);
  },
),
```

### 4. Trigger Achievement
```dart
showDialog(
  context: context,
  builder: (context) => RewardDialog(
    achievement: achievementModel,
  ),
);
```

---

## Testing Checklist

- [ ] Login halaman student berfungsi dan redirect ke home
- [ ] Progress bar menampilkan dengan benar
- [ ] Achievement badges menampilkan 6 terbaru
- [ ] Data real-time update ketika ada perubahan di Firestore
- [ ] Seed data dialog berfungsi (add & clear)
- [ ] Profil menampilkan progress dan achievements
- [ ] Animasi reward dialog smooth dan menarik
- [ ] XP dan level naik saat complete activity/topic

---

## Future Improvements

1. **Leaderboard**: Ranking siswa berdasarkan XP/Level
2. **Weekly Challenges**: Misi mingguan dengan bonus XP
3. **Streak Counter**: Penghitung hari belajar berturut-turut
4. **Custom Avatars**: Avatar yang bisa dikustomisasi
5. **Sound Effects**: Efek suara saat achievement unlock
6. **Particle Effects**: Animasi partikel saat level up
7. **Quiz Integration**: Kuis adaptif berdasarkan progress
8. **Parent Dashboard**: Dashboard untuk orang tua melihat progress anak

---

## Troubleshooting

### Progress tidak muncul
- Pastikan Firestore memiliki document di collection `student_progress`
- Pastikan `studentId` sudah benar
- Coba gunakan "Seed Data" button di profil untuk membuat data dummy

### Achievement tidak tampil
- Pastikan collection `achievements` ada di Firestore
- Check bahwa `studentId` cocok dengan student saat ini
- Coba clear dan seed data lagi

### Stream tidak update
- Pastikan Firestore security rules mengizinkan read
- Check console untuk error messages
- Restart aplikasi

---

## Notes untuk Developer

- Data seeding hanya untuk development/testing
- Disable "Seed Data" button sebelum production
- Pastikan Firestore indexes sudah di-setup untuk queries dengan `where`
- Real-time streams bisa expensive, gunakan dengan bijak
