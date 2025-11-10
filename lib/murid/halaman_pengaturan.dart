import 'package:flutter/material.dart';
import '../../pengaturan/warna.dart';
import 'drawer/drawer.dart';        // DrawerMurid
import 'drawer/buttomnav.dart';     // FooterMurid

class PengaturanMurid extends StatefulWidget {
  const PengaturanMurid({super.key});

  @override
  State<PengaturanMurid> createState() => _PengaturanMuridState();
}

class _PengaturanMuridState extends State<PengaturanMurid> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // burger (menu drawer) putih
        ),
      ),

      drawer: const DrawerMurid(),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              // Item pengaturan akun
              _buildSettingItem(
                context,
                icon: Icons.photo_camera,
                title: 'Ubah Foto Profil',
                onTap: () {},
              ),
              _buildSettingItem(
                context,
                icon: Icons.lock_outline,
                title: 'Ubah Kata Sandi',
                onTap: () {},
              ),
              _buildSettingItem(
                context,
                icon: Icons.language,
                title: 'Bahasa',
                onTap: () {},
              ),
              _buildSettingItem(
                context,
                icon: Icons.notifications,
                title: 'Notifikasi',
                onTap: () {},
              ),

              const Divider(),

              _buildSettingItem(
                context,
                icon: Icons.help_outline,
                title: 'Bantuan',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),

      // Footer dari bottomnav.dart
      bottomNavigationBar: FooterMurid(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
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
