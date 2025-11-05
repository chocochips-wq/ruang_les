import 'package:flutter/material.dart';
import '../halaman/halaman_splash.dart';
import '../halaman/halaman_pengenalan_1.dart';
import '../halaman/halaman_pengenalan_2.dart';
import '../halaman/halaman_pengenalan_3.dart';
import '../halaman/halaman_pengenalan_4.dart';
import '../halaman/halaman_pengenalan_5.dart';
import '../halaman/halaman_pilih_role.dart';
import '../halaman/halaman_login.dart';
import '../halaman/halaman_daftar.dart';
import '../halaman/halaman_lupa_password.dart';
import '../halaman/halaman_beranda.dart';

class AppRoutes {
  static const String splash = '/';
  static const String pengenalan1 = '/pengenalan1';
  static const String pengenalan2 = '/pengenalan2';
  static const String pengenalan3 = '/pengenalan3';
  static const String pengenalan4 = '/pengenalan4';
  static const String pengenalan5 = '/pengenalan5';
  static const String pilihRole = '/pilih-role';
  static const String login = '/login';
  static const String daftar = '/daftar';
  static const String lupaPassword = '/lupa-password';
  static const String beranda = '/beranda';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const HalamanSplash());
      case pengenalan1:
        return MaterialPageRoute(builder: (_) => const HalamanPengenalan1());
      case pengenalan2:
        return MaterialPageRoute(builder: (_) => const HalamanPengenalan2());
      case pengenalan3:
        return MaterialPageRoute(builder: (_) => const HalamanPengenalan3());
      case pengenalan4:
        return MaterialPageRoute(builder: (_) => const HalamanPengenalan4());
      case pengenalan5:
        return MaterialPageRoute(builder: (_) => const HalamanPengenalan5());
      case pilihRole:
        return MaterialPageRoute(builder: (_) => const HalamanPilihRole());
      case login:
        return MaterialPageRoute(builder: (_) => const HalamanLogin());
      case daftar:
        return MaterialPageRoute(builder: (_) => const HalamanDaftar());
      case lupaPassword:
        return MaterialPageRoute(builder: (_) => const HalamanLupaPassword());
      case beranda:
        return MaterialPageRoute(builder: (_) => const HalamanBeranda());
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
