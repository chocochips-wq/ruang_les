import 'package:flutter/material.dart';
import '../pengaturan/warna.dart';
import '../halaman/halaman_quiz.dart';
import '../halaman/halaman_beranda.dart';

class AppDrawer extends StatefulWidget {
  final int selectedMenuIndex;
  final Function(int)? onMenuSelected;

  const AppDrawer({
    super.key,
    this.selectedMenuIndex = 0,
    this.onMenuSelected,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late int _selectedMenuIndex;

  @override
  void initState() {
    super.initState();
    _selectedMenuIndex = widget.selectedMenuIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.sidebarBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan warna hijau
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                24, MediaQuery.of(context).padding.top + 20, 24, 24),
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Ruang les',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'By Ismaturrohmah',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textWhite,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerMenuItem(0, 'dashboard', Icons.dashboard),
                _buildDrawerMenuItem(1, 'Kelas Saya', Icons.class_),
                _buildDrawerMenuItem(2, 'Quiz', Icons.quiz),
                _buildDrawerMenuItem(3, 'Laporan Anak', Icons.description),
                const SizedBox(height: 20),
                _buildDrawerMenuItem(4, 'Profile', Icons.person),
                _buildDrawerMenuItem(5, 'Pengaturan', Icons.settings),
                _buildDrawerMenuItem(6, 'Pembayaran', Icons.payment),
              ],
            ),
          ),

          // Login Status
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Masuk Sebagai:',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pengajar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerMenuItem(int index, String title, IconData icon) {
    final isSelected = _selectedMenuIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMenuIndex = index;
        });
        
        // Panggil callback jika ada
        widget.onMenuSelected?.call(index);
        
        Navigator.pop(context); // Tutup drawer dulu

        // Navigasi berdasarkan index menu
        if (index == 0) {
          // Dashboard/Beranda - Gunakan pushReplacement agar tidak menumpuk
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HalamanBeranda()),
          );
        } else if (index == 2) {
          // Quiz - Gunakan pushReplacement
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HalamanQuiz()),
          );
        }
        // Tambahkan navigasi untuk menu lain di sini
        // else if (index == 1) {
        //   Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(builder: (context) => const HalamanKelasSaya()),
        //   );
        // }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.sidebarActive : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.textDark : AppColors.textLight,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.textDark : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}