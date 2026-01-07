import 'package:flutter/material.dart';
import '../../pengaturan/warna.dart';
import 'drawer/drawer.dart';

class PengaturanOrangtua extends StatefulWidget {
  const PengaturanOrangtua({super.key});

  @override
  State<PengaturanOrangtua> createState() => _PengaturanOrangtuaState();
}

class _PengaturanOrangtuaState extends State<PengaturanOrangtua> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const DrawerOrangtua(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Pengaturan Akun',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Perbarui foto, sandi, bahasa, dan lainnya',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
              ),

              const SizedBox(height: 24),

              // Akun Section
              _buildSectionCard(
                title: 'Pengaturan Akun',
                icon: Icons.person_outline,
                items: [
                  _buildSettingItem(
                    context,
                    icon: Icons.photo_camera,
                    iconColor: Colors.blue,
                    title: 'Ubah Foto Profil',
                    subtitle: 'Perbarui foto profil Anda',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.lock_outline,
                    iconColor: Colors.orange,
                    title: 'Ubah Kata Sandi',
                    subtitle: 'Amankan akun Anda',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Pilih Tema Section
              _buildSectionCard(
                title: 'Pilih Tema',
                icon: Icons.palette_outlined,
                items: [
                  _buildThemeToggle(),
                ],
              ),

              const SizedBox(height: 16),

              // Preferensi Section
              _buildSectionCard(
                title: 'Preferensi',
                icon: Icons.settings_outlined,
                items: [
                  _buildSettingItem(
                    context,
                    icon: Icons.language,
                    iconColor: Colors.green,
                    title: 'Bahasa',
                    subtitle: 'Indonesia',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.notifications_outlined,
                    iconColor: Colors.red,
                    title: 'Notifikasi',
                    subtitle: 'Kelola pemberitahuan',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Bantuan Section
              _buildSectionCard(
                title: 'Bantuan & Dukungan',
                icon: Icons.help_outline,
                items: [
                  _buildSettingItem(
                    context,
                    icon: Icons.support_agent,
                    iconColor: Colors.purple,
                    title: 'Pusat Bantuan',
                    subtitle: 'FAQ dan panduan',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.info_outline,
                    iconColor: Colors.grey,
                    title: 'Tentang Aplikasi',
                    subtitle: 'Versi 1.0.0',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Colors.indigo,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mode Gelap',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isDarkMode ? 'Aktif' : 'Nonaktif',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
            },
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}