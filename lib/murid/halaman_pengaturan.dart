import 'package:flutter/material.dart';
import '../../pengaturan/warna.dart';
import 'drawer/drawer.dart';

class PengaturanMurid extends StatelessWidget {
  const PengaturanMurid({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary, // Sesuaikan dengan warna utama
        elevation: 0,
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: const DrawerMurid(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Pengaturan Akun
              const Text(
                'Pengaturan Akun',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Perbarui foto, sandi, bahasa, dan lainnya.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 24),

              // Menu Pengaturan
              _buildSettingItem(
                context,
                icon: Icons.photo_camera,
                title: 'Ubah Foto Profil',
                onTap: () {
                  // Logika untuk mengubah foto profil
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.lock_outline,
                title: 'Ubah Kata Sandi',
                onTap: () {
                  // Logika untuk mengubah kata sandi
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.language,
                title: 'Bahasa',
                onTap: () {
                  // Logika untuk mengubah bahasa
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.notifications,
                title: 'Notifikasi',
                onTap: () {
                  // Logika untuk pengaturan notifikasi
                },
              ),
              const Divider(),

              // Menu Lainnya
              _buildSettingItem(
                context,
                icon: Icons.help_outline,
                title: 'Bantuan',
                onTap: () {
                  // Logika untuk bantuan
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(
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
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.textDark,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
