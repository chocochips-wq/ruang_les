import 'package:flutter/material.dart';
import '../../../core/utils/routes.dart';
import '../../../core/utils/colors.dart';
import '../../../data/repositories/user_repository.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';

class TeacherDrawer extends StatelessWidget {
  final int selectedMenuIndex;
  final Function(int) onMenuSelected;

  const TeacherDrawer({
    super.key,
    required this.selectedMenuIndex,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: AppColors.textWhite,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primaryDark,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ismaturrohmah',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pengajar',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  index: 0,
                  route: AppRoutes.pengajarBeranda,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.person,
                  title: 'Profile',
                  index: 1,
                  route: AppRoutes.pengajarProfil,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.class_,
                  title: 'Kelas Saya',
                  index: 2,
                  route: AppRoutes.pengajarKelas,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.quiz,
                  title: 'Quiz',
                  index: 3,
                  route: AppRoutes.pengajarQuiz,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.group,
                  title: 'Kelola Akun',
                  index: 4,
                  route: AppRoutes.pengajarLaporanAnak,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.assignment,
                  title: 'Laporan Anak',
                  index: 4,
                  route: AppRoutes.pengajarNilai,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.payments,
                  title: 'Pembayaran',
                  index: 5,
                  route: AppRoutes.pengajarPembayaran,
                ),
                _buildVerificationMenuItem(context),

                // ===== GARIS PEMISAH =====
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(thickness: 1),
                ),

                // ===== PENGATURAN (di bawah garis) =====
                _buildMenuItem(
                  context,
                  icon: Icons.settings,
                  title: 'Pengaturan',
                  index: 7,
                  route: AppRoutes.pengajarPengaturan,
                ),

                // ===== LOGOUT (di bawah pengaturan) =====
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Keluar',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int index,
    String? route,
  }) {
    final isSelected = selectedMenuIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textLight,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textDark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.accent,
      onTap: () {
        // 1. Close drawer first
        Navigator.pop(context);

        // 2. Schedule navigation for next frame
        if (route != null) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (context.mounted) {
              onMenuSelected(index);
              // Reset stack to avoid "no active routes" error
              Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
            }
          });
        }
      },
    );
  }

  Widget _buildVerificationMenuItem(BuildContext context) {
    final isSelected = selectedMenuIndex == 6;

    return StreamBuilder<int>(
      stream: UserRepository().streamPendingUsers(
          roles: ['student', 'parent']).map((users) => users.length),
      builder: (context, snapshot) {
        final pendingCount = snapshot.data ?? 0;

        return ListTile(
          leading: Icon(
            Icons.verified_user,
            color: isSelected ? AppColors.primary : AppColors.textLight,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'Verifikasi Akun',
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textDark,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (pendingCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$pendingCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          selected: isSelected,
          selectedTileColor: AppColors.accent,
          onTap: () {
            onMenuSelected(6);
            Navigator.pop(context);
            Navigator.pushReplacementNamed(
                context, AppRoutes.pengajarVerifikasi);
          },
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              _logoutUser(context);
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logoutUser(BuildContext context) async {
    Navigator.pop(context); // Close dialog
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.pilihRole, (route) => false);
    }
  }
}
