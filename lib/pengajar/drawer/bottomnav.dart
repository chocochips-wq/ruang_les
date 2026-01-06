import 'package:flutter/material.dart';
import '../../pengaturan/warna.dart';
import '../../pengaturan/rute.dart';

class PengajarFooter extends StatelessWidget {
  final int currentIndex;

  const PengajarFooter({
    super.key,
    required this.currentIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    // Jangan navigasi kalau sudah di halaman yang sama
    if (index == currentIndex) return;

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

    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textLight,
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          activeIcon: Icon(Icons.menu_book),
          label: 'Materi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}