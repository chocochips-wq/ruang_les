import 'package:flutter/material.dart';
import '../../features/auth/pages/introduction_page.dart';
import '../../features/auth/pages/role_selection_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/auth/pages/forgot_password_page.dart';

// Import Teacher
import '../../features/teacher/pages/teacher_home.dart';
// import '../../features/teacher/pages/teacher_quiz.dart'; // File doesn't exist
import '../../features/teacher/pages/teacher_classes.dart';
import '../../features/teacher/pages/teacher_profile.dart';
import '../../features/teacher/pages/teacher_reports.dart';
import '../../features/teacher/pages/teacher_payments.dart';
import '../../features/teacher/pages/teacher_settings.dart';
import '../../features/teacher/pages/teacher_materials.dart';
import '../../features/teacher/pages/teacher_students.dart';

// Import Student
import '../../features/student/pages/student_home.dart';
import '../../features/student/pages/student_classes.dart';
import '../../features/student/pages/student_profile.dart';
import '../../features/student/pages/student_settings.dart';

// Import Parent
import '../../features/parent/pages/parent_home.dart';
import '../../features/parent/pages/parent_learning_report.dart';
import '../../features/parent/pages/parent_profile.dart';
import '../../features/parent/pages/parent_forum.dart';
import '../../features/parent/pages/parent_payment.dart';
import '../../features/parent/pages/parent_settings.dart';

class AppRoutes {
  // ========== ROUTES UMUM ==========
  static const String splash = '/';
  static const String pengenalan = '/pengenalan';
  static const String pilihRole = '/pilih-role';
  static const String login = '/login';
  static const String daftar = '/daftar';
  static const String lupaPassword = '/lupa-password';

  // ========== ROUTES PENGAJAR ==========
  static const String pengajarBeranda = '/pengajar/beranda';
  static const String pengajarQuiz = '/pengajar/quiz';
  static const String pengajarKelas = '/pengajar/kelas';
  static const String pengajarMateri = '/pengajar/materi';
  static const String pengajarNilai = '/pengajar/nilai';
  static const String pengajarProfil = '/pengajar/profil';
  static const String pengajarPembayaran = '/pengajar/pembayaran';
  static const String pengajarPengaturan = '/pengajar/pengaturan';
  static const String pengajarLaporanAnak = '/pengajar/kelola-murid';

  // ========== ROUTES MURID ==========
  static const String muridBeranda = '/murid/beranda';
  static const String muridKelas = '/murid/kelas';
  static const String muridTugas = '/murid/tugas';
  static const String muridNilai = '/murid/nilai';
  static const String muridMateri = '/murid/materi';
  static const String muridProfile = '/murid/profile';
  static const String muridPengaturan = '/murid/pengaturan';

  // ========== ROUTES ORANG TUA ==========
  static const String orangtuaBeranda = '/orangtua/beranda';
  static const String orangtuaProfile = '/orangtua/profile';
  static const String orangtuaForum = '/orangtua/forum';
  static const String orangtuaLaporan = '/orangtua/laporan';
  static const String orangtuaPembayaran = '/orangtua/pembayaran';
  static const String orangtuaFeedback = '/orangtua/feedback';
  static const String orangtuaPengaturan = '/orangtua/pengaturan';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ========== ROUTES UMUM ==========
      case splash:
        return MaterialPageRoute(builder: (_) => const HalamanPengenalan());

      case pengenalan:
        return MaterialPageRoute(builder: (_) => const HalamanPengenalan());

      case pilihRole:
        return MaterialPageRoute(builder: (_) => const HalamanPilihRole());

      case login:
        final role = settings.arguments as String?;
        return MaterialPageRoute(
            builder: (_) => HalamanLogin(selectedRole: role));

      case daftar:
        return MaterialPageRoute(builder: (_) => const HalamanDaftar());

      case lupaPassword:
        return MaterialPageRoute(builder: (_) => const HalamanLupaPassword());

      // ========== ROUTES PENGAJAR ==========
      case pengajarBeranda:
        return MaterialPageRoute(builder: (_) => const HalamanBeranda());

      case pengajarQuiz:
        // TODO: Create teacher_quiz.dart or use quiz pages from features/quiz
        return MaterialPageRoute(
            builder: (_) => const HalamanBeranda()); // Temporary fallback

      case pengajarKelas:
        return MaterialPageRoute(builder: (_) => const PengajarKelas());

      case pengajarMateri:
        return MaterialPageRoute(builder: (_) => const PengajarMateri());

      case pengajarProfil:
        return MaterialPageRoute(builder: (_) => const PengajarProfil());

      case pengajarNilai:
        return MaterialPageRoute(builder: (_) => const PengajarNilai());

      case pengajarLaporanAnak:
        return MaterialPageRoute(builder: (_) => const HalamanKelolaMurid());

      case pengajarPembayaran:
        return MaterialPageRoute(builder: (_) => const PengajarPembayaran());

      case pengajarPengaturan:
        return MaterialPageRoute(builder: (_) => const PengajarPengaturan());

      // ========== ROUTES MURID ==========
      case muridBeranda:
        return MaterialPageRoute(builder: (_) => const BerandaMurid());

      case muridKelas:
        return MaterialPageRoute(builder: (_) => const HalamanKelas());

      case muridProfile:
        return MaterialPageRoute(builder: (_) => const ProfileMurid());

      case muridPengaturan:
        return MaterialPageRoute(builder: (_) => const PengaturanMurid());

      // ========== ROUTES ORANG TUA ==========
      case orangtuaBeranda:
        return MaterialPageRoute(builder: (_) => const BerandaOrangtua());

      case orangtuaProfile:
        return MaterialPageRoute(builder: (_) => const ProfileOrangtua());

      case orangtuaForum:
        return MaterialPageRoute(builder: (_) => const ForumOrangtua());

      case orangtuaLaporan:
        return MaterialPageRoute(
            builder: (_) => const LaporanBelajarOrangtua());

      case orangtuaPembayaran:
        return MaterialPageRoute(builder: (_) => const PembayaranOrangtua());

      case orangtuaPengaturan:
        return MaterialPageRoute(builder: (_) => const PengaturanOrangtua());

      // ========== DEFAULT ==========
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Halaman ${settings.name} tidak ditemukan'),
            ),
          ),
        );
    }
  }
}
