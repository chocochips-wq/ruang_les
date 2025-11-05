import 'package:flutter/material.dart';
import '../pengaturan/warna.dart';
import '../pengaturan/rute.dart';
import '../komponen/tombol_custom.dart';

class HalamanPengenalan5 extends StatelessWidget {
  const HalamanPengenalan5({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Calendar
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 40),
              
              // Title
              const Text(
                'Pantau Perkembangan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const Text(
                'Anak Setiap Hari',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Orang tua bisa melihat progress anak setiap hari dengan simpel dan lengkap',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                    height: 1.5,
                  ),
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Button Mulai Sekarang
              TombolCustom(
                teks: 'Mulai Sekarang',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.pilihRole);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}