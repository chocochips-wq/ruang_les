import 'package:flutter/material.dart';
import '../pengaturan/warna.dart';
import 'drawer/drawer.dart';
import 'drawer/buttomnav.dart';

class BerandaMurid extends StatefulWidget {
  const BerandaMurid({super.key});

  @override
  State<BerandaMurid> createState() => _BerandaMuridState();
}

class _BerandaMuridState extends State<BerandaMurid> {
  int _selectedIndex = 0;

  final _kelasAktif = [
    {'nama': 'Matematika', 'icon': Icons.calculate, 'color': Colors.blue},
    {'nama': 'Bahasa Inggris', 'icon': Icons.language, 'color': Colors.purple},
    {'nama': 'IPA', 'icon': Icons.science, 'color': Colors.green},
  ];

  final _progressBelajar = [
    {'mataPelajaran': 'Matematika Dasar', 'progress': 0.75, 'color': Colors.blue, 'completed': 15, 'total': 20},
    {'mataPelajaran': 'Bahasa Inggris', 'progress': 0.55, 'color': Colors.purple, 'completed': 11, 'total': 20},
    {'mataPelajaran': 'IPA', 'progress': 0.85, 'color': Colors.green, 'completed': 17, 'total': 20},
  ];

  final _aktivitasTerbaru = [
    {'title': 'Quiz Matematika - Aljabar', 'time': '2 jam lalu', 'icon': Icons.quiz, 'color': Colors.orange},
    {'title': 'Materi Bahasa Inggris - Tenses', 'time': '5 jam lalu', 'icon': Icons.book, 'color': Colors.blue},
    {'title': 'Tugas IPA - Sistem Pencernaan', 'time': '1 hari lalu', 'icon': Icons.assignment, 'color': Colors.green},
  ];

  final _statistik = [
    {'label': 'Quiz Selesai', 'value': '12', 'icon': Icons.task_alt, 'color': Colors.green},
    {'label': 'Tugas Aktif', 'value': '5', 'icon': Icons.pending_actions, 'color': Colors.orange},
    {'label': 'Rata-rata Nilai', 'value': '85', 'icon': Icons.trending_up, 'color': Colors.blue},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 2,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Beranda', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: const DrawerMurid(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 20),
            _buildStatistikCards(),
            const SizedBox(height: 20),
            _buildKelasAktif(),
            const SizedBox(height: 20),
            _buildProgressBelajar(),
            const SizedBox(height: 20),
            _buildAktivitasTerbaru(),
          ],
        ),
      ),
      bottomNavigationBar: FooterMurid(
        selectedIndex: _selectedIndex,
        onItemTapped: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.8), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Halo, Alfito! 👋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text('Selamat datang kembali!', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                const SizedBox(height: 4),
                Text('Mari lanjutkan belajarmu hari ini', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school, size: 32, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistikCards() {
    return Row(
      children: _statistik.map((stat) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: stat == _statistik.last ? 0 : 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 24),
                const SizedBox(height: 8),
                Text(stat['value'] as String, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: stat['color'] as Color)),
                const SizedBox(height: 4),
                Text(stat['label'] as String, style: TextStyle(fontSize: 10, color: Colors.grey.shade600), textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKelasAktif() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.class_, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text('Kelas Aktif', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _kelasAktif.map((kelas) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: (kelas['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: (kelas['color'] as Color).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(kelas['icon'] as IconData, size: 18, color: kelas['color'] as Color),
                    const SizedBox(width: 8),
                    Text(kelas['nama'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kelas['color'] as Color)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBelajar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text('Progres Belajarmu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          ..._progressBelajar.map((progress) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(progress['mataPelajaran'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      Text('${progress['completed']}/${progress['total']} Materi', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress['progress'] as double,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(progress['color'] as Color),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('${((progress['progress'] as double) * 100).toInt()}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: progress['color'] as Color)),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAktivitasTerbaru() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text('Aktivitas Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ..._aktivitasTerbaru.map((aktivitas) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (aktivitas['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(aktivitas['icon'] as IconData, size: 20, color: aktivitas['color'] as Color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(aktivitas['title'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(aktivitas['time'] as String, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}