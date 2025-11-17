import 'package:flutter/material.dart';
import '../awal/halaman_pengenalan.dart';
import '../awal/halaman_pilih_role.dart';
import '../awal/halaman_login.dart';
import '../awal/halaman_daftar.dart';
import '../awal/halaman_lupa_password.dart';

// Import Pengajar
import '../pengajar/pengajar_beranda.dart';
import '../pengajar/quiz/pengajar_quiz.dart';
import '../pengajar/kelas/pengajar_kelas.dart';
import '../pengajar/pengajar_profile.dart';
import '../pengajar/pengajar_laporan_anak.dart';
import '../pengajar/pengajar_pembayaran.dart';
import '../pengajar/pengajar_pengaturan.dart';
import '../pengajar/pengajar_materi.dart';

// Import Murid
import '../murid/beranda_murid.dart';
import '../murid/halaman_kelas.dart';
import '../murid/halaman_profile.dart';
import '../murid/halaman_pengaturan.dart';

// Import Orang Tua
import '../orangtua/orangtua_beranda.dart';
import '../orangtua/orangtua_laporan_belajar.dart';
import '../orangtua/orangtua_profile.dart';
import '../orangtua/orangtua_forum.dart';
import '../orangtua/orangtua_pembayaran.dart';
import '../orangtua/orangtua_feedback.dart';
import '../orangtua/orangtua_pengaturan.dart';

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
        return MaterialPageRoute(builder: (_) => const HalamanQuiz());
      
      case pengajarKelas:
        return MaterialPageRoute(builder: (_) => const PengajarKelasPage());

      case pengajarMateri:
        return MaterialPageRoute(builder: (_) => const PengajarMateri());

      case pengajarProfil:
        return MaterialPageRoute(builder: (_) => const PengajarProfil());

      case pengajarNilai:
        return MaterialPageRoute(builder: (_) => const PengajarNilai());

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
        return MaterialPageRoute(builder: (_) => const LaporanBelajarOrangtua());

      case orangtuaPembayaran:
        return MaterialPageRoute(builder: (_) => const PembayaranOrangtua());

      case orangtuaFeedback:
        return MaterialPageRoute(builder: (_) => const FeedbackOrangtua());

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