import 'package:flutter/material.dart';
import '../pengaturan/warna.dart';
import '../pengaturan/rute.dart';

class HalamanSplash extends StatefulWidget {
  const HalamanSplash({super.key});

  @override
  State<HalamanSplash> createState() => _HalamanSplashState();
}

class _HalamanSplashState extends State<HalamanSplash> {
  @override
  void initState() {
    super.initState();
    // Pindah ke halaman pengenalan setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.pengenalan1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Buku
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            // Nama App
            const Text(
              'Ruang Les',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Belajar Jadi Menyenangkan',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}