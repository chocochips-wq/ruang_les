import 'package:flutter/material.dart';
import '../../pengaturan/warna.dart';
import 'drawer.dart';

class PengajarScaffold extends StatelessWidget {
  final String? title; // Sekarang optional
  final Widget body;
  final int selectedMenuIndex;
  final Function(int) onMenuSelected;
  final VoidCallback? onNotificationTap;

  const PengajarScaffold({
    super.key,
    this.title, // Otomatis pakai nama menu jika null
    required this.body,
    required this.selectedMenuIndex,
    required this.onMenuSelected,
    this.onNotificationTap,
  });

  // Fungsi untuk dapat nama halaman berdasarkan index
  String _getPageTitle() {
    if (title != null) return title!; // Pakai title custom jika ada
    
    switch (selectedMenuIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Profile';
      case 2:
        return 'Kelas Saya';
      case 3:
        return 'Quiz';
      case 4:
        return 'Laporan Anak';
      case 5:
        return 'Pembayaran';
      case 6:
        return 'Pengaturan';
      default:
        return 'Ruang Les';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getPageTitle(), // Otomatis ambil nama
          style: const TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
        actions: [
          // Icon Notifikasi
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                // Badge notifikasi (opsional)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: onNotificationTap ?? () {
              // Default action jika tidak ada callback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifikasi diklik')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: PengajarDrawer(
        selectedMenuIndex: selectedMenuIndex,
        onMenuSelected: onMenuSelected,
      ),
      body: body,
    );
  }
}