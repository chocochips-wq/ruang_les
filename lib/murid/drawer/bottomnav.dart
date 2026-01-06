import 'package:flutter/material.dart';
import '../../pengaturan/warna.dart';
import '../../pengaturan/rute.dart';

class FooterMurid extends StatelessWidget {
  final int selectedIndex;

  const FooterMurid({
    super.key,
    required this.selectedIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    // Jangan navigasi kalau sudah di halaman yang sama
    if (index == selectedIndex) return;

    String route;
    switch (index) {
      case 0:
        route = AppRoutes.muridKelas; // Kelas (icon menu_book)
        break;
      case 1:
        route = AppRoutes.muridBeranda; // Home/Beranda
        break;
      case 2:
        route = AppRoutes.muridProfile; // Profile
        break;
      default:
        route = AppRoutes.muridBeranda;
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
      showSelectedLabels: true, // Ubah jadi true biar lebih jelas
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          activeIcon: Icon(Icons.menu_book),
          label: 'Kelas',
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