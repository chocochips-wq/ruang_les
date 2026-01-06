import 'package:flutter/material.dart';
import '../../pengaturan/warna.dart';
import '../../pengaturan/rute.dart';

class FooterOrangtua extends StatelessWidget {
  final int selectedIndex;

  const FooterOrangtua({
    super.key,
    required this.selectedIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    // Jangan navigasi kalau sudah di halaman yang sama
    if (index == selectedIndex) return;

    String route;
    switch (index) {
      case 0: // Beranda
        route = AppRoutes.orangtuaBeranda;
        break;
      case 1: // Laporan Anak
        route = AppRoutes.orangtuaLaporan;
        break;
      case 2: // Forum
        route = AppRoutes.orangtuaForum;
        break;
      case 3: // Profil
        route = AppRoutes.orangtuaProfile;
        break;
      default:
        route = AppRoutes.orangtuaBeranda;
    }

    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) => _onItemTapped(context, index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assessment_outlined),
          activeIcon: Icon(Icons.assessment),
          label: 'Laporan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.forum_outlined),
          activeIcon: Icon(Icons.forum),
          label: 'Forum',
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