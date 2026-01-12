import 'package:flutter/material.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/routes.dart';

class RoleSelectorPage extends StatelessWidget {
  const RoleSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Ruang Les',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pilih Role untuk Masuk',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textLight,
                ),
              ),

              const SizedBox(height: 48),

              // Role Cards
              _buildRoleCard(
                context,
                icon: Icons.school,
                title: 'Guru',
                subtitle: 'Masuk sebagai Pengajar',
                color: Colors.orange,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.login,
                    arguments: 'pengajar',
                  );
                },
              ),

              const SizedBox(height: 16),

              _buildRoleCard(
                context,
                icon: Icons.person,
                title: 'Murid',
                subtitle: 'Masuk sebagai Siswa',
                color: Colors.blue,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.login,
                    arguments: 'murid',
                  );
                },
              ),

              const SizedBox(height: 16),

              _buildRoleCard(
                context,
                icon: Icons.family_restroom,
                title: 'Orang Tua',
                subtitle: 'Masuk sebagai Wali Murid',
                color: Colors.green,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.login,
                    arguments: 'orangtua',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
