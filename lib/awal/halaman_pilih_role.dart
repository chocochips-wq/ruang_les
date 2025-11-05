import 'package:flutter/material.dart';
import '../pengaturan/warna.dart';
import '../pengaturan/rute.dart';
import '../komponen/tombol_custom.dart';

class HalamanPilihRole extends StatefulWidget {
  const HalamanPilihRole({super.key});

  @override
  State<HalamanPilihRole> createState() => _HalamanPilihRoleState();
}

class _HalamanPilihRoleState extends State<HalamanPilihRole> {
  String? roleDipilih;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
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
                'By Ismaturrohmah',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Masuk Sebagai Siapa?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 24),
              
              // Pilihan Role
              _buildRoleCard('Murid', Icons.school_rounded),
              const SizedBox(height: 16),
              _buildRoleCard('Orang Tua', Icons.family_restroom_rounded),
              const SizedBox(height: 16),
              _buildRoleCard('Pengajar', Icons.person_rounded),
              
              const SizedBox(height: 40),
              
              // Button Masuk
              TombolCustom(
                teks: 'Masuk',
                onPressed: roleDipilih != null
                    ? () {
                        Navigator.pushNamed(context, AppRoutes.login);
                      }
                    : () {},
                warna: roleDipilih != null
                    ? AppColors.primary
                    : AppColors.buttonDisabled,
              ),
              
              const SizedBox(height: 16),
              
              // Text Belum Punya Akun
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Belum punya akun? ',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.daftar);
                    },
                    child: const Text(
                      'Daftar disini',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Link Kembali ke Path Panen
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Kembali ke path panen',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(String role, IconData icon) {
    final bool isSelected = roleDipilih == role;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          roleDipilih = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.textWhite : AppColors.primary,
              size: 32,
            ),
            const SizedBox(width: 16),
            Text(
              role,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.textWhite : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}