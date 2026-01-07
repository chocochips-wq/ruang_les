import 'package:flutter/material.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/routes.dart';
import '../../../core/widgets/custom_button.dart';

class HalamanPengenalan extends StatefulWidget {
  const HalamanPengenalan({super.key});

  @override
  State<HalamanPengenalan> createState() => _HalamanPengenalanState();
}

class _HalamanPengenalanState extends State<HalamanPengenalan> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showSplash = true;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.menu_book_rounded,
      'title': 'Ruang Les',
      'subtitle': 'By Ismaturrohmah',
      'description': 'Belajar Seru, Bersama Cerdas',
    },
    {
      'icon': Icons.menu_book_rounded,
      'title': 'Selamat Datang',
      'subtitle': 'Di Ruang Les',
      'description': 'Materi Belajar Inovatif & Seru\nMenjaga Rajin Belajar',
    },
    {
      'icon': Icons.insert_chart_rounded,
      'title': 'Belajar Dengan Cara',
      'titleHighlight': 'Menyenangkan',
      'description':
          'Aplikasi belajar jadi lebih seru dan menarik dengan game dan hadiah',
    },
    {
      'icon': Icons.people_rounded,
      'title': 'Kolaborasi Anak,',
      'titleHighlight': 'Orang Tua, Dan Guru',
      'description':
          'Ruang belajar bersama - untuk berbagi materi dan catatan perkembangan',
    },
    {
      'icon': Icons.calendar_today_rounded,
      'title': 'Pantau Perkembangan',
      'titleHighlight': 'Anak Setiap Hari',
      'description':
          'Orang tua bisa melihat progress anak setiap hari dengan simpel dan lengkap',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Auto pindah dari splash ke halaman pertama setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.pilihRole);
    }
  }

  void _skipToEnd() {
    Navigator.pushReplacementNamed(context, AppRoutes.pilihRole);
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan Splash Screen terlebih dahulu
    if (_showSplash) {
      return _buildSplashScreen();
    }

    // Setelah 3 detik, tampilkan PageView pengenalan
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index], index);
                },
              ),
            ),

            // Indicator & Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Dot Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.textLight.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Button Lanjut/Mulai Sekarang
                  TombolCustom(
                    teks: _currentPage == _pages.length - 1
                        ? 'Mulai Sekarang'
                        : 'Lanjut',
                    onPressed: _nextPage,
                  ),

                  // Button Lewati (hanya tampil di halaman 1-4)
                  if (_currentPage < _pages.length - 1) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _skipToEnd,
                      child: const Text(
                        'Lewati',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Splash Screen
  Widget _buildSplashScreen() {
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
            const SizedBox(height: 40),

            // Loading Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 120.0),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      backgroundColor: AppColors.textWhite.withOpacity(0.3),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.accent),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textWhite.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> pageData, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              pageData['icon'],
              size: 80,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 40),

          // Title
          Text(
            pageData['title'],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: index == 0 ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),

          // Subtitle (halaman 1) atau Title Highlight (halaman lainnya)
          if (index == 0) ...[
            const SizedBox(height: 12),
            Text(
              pageData['subtitle'],
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 8),
          ] else if (pageData['titleHighlight'] != null) ...[
            Text(
              pageData['titleHighlight'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
          ] else if (pageData['subtitle'] != null) ...[
            const SizedBox(height: 12),
            Text(
              pageData['subtitle'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            const SizedBox(height: 16),
          ],

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              pageData['description'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
