import 'package:flutter/material.dart';
import '../pengaturan/warna.dart';
import '../pengaturan/rute.dart';
import '../komponen/tombol_custom.dart';

class HalamanPengenalan1 extends StatelessWidget {
  const HalamanPengenalan1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Buku
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 40),
              
              // Title
              const Text(
                'Ruang Les',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              
              // Subtitle
              const Text(
                'By Ismaturrohmah',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 8),
              
              const Text(
                'Belajar Seru, Bersama Cerdas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Button Lanjut
              TombolCustom(
                teks: 'Lanjut',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.pengenalan2);
                },
              ),
              
              const SizedBox(height: 16),
              
              // Button Lewati
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.pilihRole);
                },
                child: const Text(
                  'Lewati',
                  style: TextStyle(
                    color: AppColors.textLight,
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
}