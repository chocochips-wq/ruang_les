import 'package:flutter/material.dart';
import '../../pengaturan/warna.dart';
import '../../pengaturan/rute.dart';

// Class dengan nama lama (jika masih dipakai di file lain)
class PengajarFooter extends StatelessWidget {
  final int currentIndex;

  const PengajarFooter({
    super.key,
    this.currentIndex = 1, // Default: Beranda
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textLight,
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: 'Materi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    String route;

    switch (index) {
      case 0: // Materi
        route = AppRoutes.pengajarMateri;
        break;
      case 1: // Beranda
        route = AppRoutes.pengajarBeranda;
        break;
      case 2: // Profil
        route = AppRoutes.pengajarProfil;
        break;
      default:
        route = AppRoutes.pengajarBeranda;
    }

    // Navigasi ke halaman yang dipilih
    Navigator.pushReplacementNamed(context, route);
  }
}

// Alias baru untuk kompatibilitas dengan pengajar_profil.dart
class PengajarBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap; // Optional, karena kita pakai navigasi internal

  const PengajarBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textLight,
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: 'Materi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    String route;

    switch (index) {
      case 0: // Beranda
        route = AppRoutes.pengajarBeranda;
        break;
      case 1: // Materi
        route = AppRoutes.pengajarMateri;
        break;
      case 2: // Profil
        route = AppRoutes.pengajarProfil;
        break;
      default:
        route = AppRoutes.pengajarBeranda;
    }

    // Navigasi ke halaman yang dipilih
    Navigator.pushReplacementNamed(context, route);
  }
}