import 'package:flutter/material.dart';
import '../../pengaturan/warna.dart';
import '../../pengaturan/rute.dart'; // Pastikan AppRoutes diimpor

class DrawerMurid extends StatelessWidget {
  const DrawerMurid({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header Drawer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Alfito',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'murid@gmail.com',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  onTap: () {
                    Navigator.pop(context); // Menutup drawer
                    // Navigasi ke halaman Dashboard Murid
                    Navigator.pushReplacementNamed(context, AppRoutes.muridBeranda);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person,
                  title: 'Profile',
                  onTap: () {
                    Navigator.pop(context); // Menutup drawer
                    // Navigasi ke halaman Profile Murid
                    Navigator.pushReplacementNamed(context, AppRoutes.muridProfile);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.school,
                  title: 'Kelas',
                  onTap: () {
                    Navigator.pop(context); // Menutup drawer
                    // Navigasi ke halaman Kelas Murid
                    Navigator.pushReplacementNamed(context, AppRoutes.muridKelas);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: 'Pengaturan',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, AppRoutes.muridPengaturan);
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.logout,
                  title: 'Keluar',
                  onTap: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                  color: Colors.red,
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Versi 1.0.0',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textDark),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? AppColors.textDark,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }
}
