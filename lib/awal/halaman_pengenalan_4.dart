import 'package:flutter/material.dart';
import '../pengaturan/warna.dart';
import '../pengaturan/rute.dart';
import '../komponen/tombol_custom.dart';

class HalamanPengenalan4 extends StatelessWidget {
  const HalamanPengenalan4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Users/Group
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.people_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 40),
              
              // Title
              const Text(
                'Kolaborasi Anak,',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const Text(
                'Orang Tua, Dan Guru',
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
                  'Ruang belajar bersama - untuk berbagi materi dan catatan perkembangan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                    height: 1.5,
                  ),
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Button Lanjut
              TombolCustom(
                teks: 'Lanjut',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.pengenalan5);
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