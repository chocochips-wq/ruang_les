import 'package:flutter/material.dart';
import '../../../core/utils/colors.dart';
import '../widgets/student_drawer.dart';
import '../widgets/student_bottom_nav.dart';

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
      drawer: const DrawerMurid(),
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
                'Atur profil dan aplikasi kamu',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
              ),

              const SizedBox(height: 24),

              // Akun Section
              _buildSectionCard(
                title: 'Profil Saya',
                icon: Icons.person_outline,
                items: [
                  _buildSettingItem(
                    context,
                    icon: Icons.photo_camera,
                    iconColor: Colors.blue,
                    title: 'Ubah Foto Profil',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.lock_outline,
                    iconColor: Colors.orange,
                    title: 'Ubah Kata Sandi',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Aplikasi Section
              _buildSectionCard(
                title: 'Pengaturan Aplikasi',
                icon: Icons.settings_outlined,
                items: [
                  _buildSettingItem(
                    context,
                    icon: Icons.notifications_outlined,
                    iconColor: Colors.red,
                    title: 'Notifikasi',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.language,
                    iconColor: Colors.green,
                    title: 'Bahasa',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.volume_up_outlined,
                    iconColor: Colors.purple,
                    title: 'Suara',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Bantuan Section
              _buildSectionCard(
                title: 'Bantuan',
                icon: Icons.help_outline,
                items: [
                  _buildSettingItem(
                    context,
                    icon: Icons.chat_bubble_outline,
                    iconColor: Colors.cyan,
                    title: 'Hubungi Guru',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.star_outline,
                    iconColor: Colors.amber,
                    title: 'Beri Rating',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.info_outline,
                    iconColor: Colors.grey,
                    title: 'Tentang Aplikasi',
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
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
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
}
