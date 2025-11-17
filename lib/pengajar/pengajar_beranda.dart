import 'package:flutter/material.dart';
import '../pengaturan/warna.dart';
import 'drawer/drawer.dart';
import 'drawer/bottomnav.dart';

class HalamanBeranda extends StatefulWidget {
  const HalamanBeranda({super.key});

  @override
  State<HalamanBeranda> createState() => _HalamanBerandaState();
}

class _HalamanBerandaState extends State<HalamanBeranda> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedMenuIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      // Gunakan PengajarDrawer yang sudah dipisah
      drawer: PengajarDrawer(
        selectedMenuIndex: _selectedMenuIndex,
        onMenuSelected: (index) {
          setState(() {
            _selectedMenuIndex = index;
          });
        },
      ),
      body: Column(
        children: [
          // Custom AppBar
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    color: AppColors.textWhite,
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Ruang Les',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    color: AppColors.textWhite,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: OrientationBuilder(
              builder: (context, orientation) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(
                        orientation == Orientation.portrait ? 20 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dashboard Title
                        const Text(
                          'dashboard',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Stats Cards
                        orientation == Orientation.landscape
                            ? Row(
                                children: [
                                  Expanded(
                                      child: _buildStatCard(
                                          'Total Murid', '24', Icons.people)),
                                  const SizedBox(width: 16),
                                  Expanded(
                                      child: _buildStatCard(
                                          'Kelas Aktif', '8', Icons.class_)),
                                  const SizedBox(width: 16),
                                  Expanded(
                                      child: _buildStatCard('Tugas Pending',
                                          '12', Icons.assignment)),
                                ],
                              )
                            : Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: _buildStatCard('Total Murid',
                                              '24', Icons.people)),
                                      const SizedBox(width: 16),
                                      Expanded(
                                          child: _buildStatCard('Kelas Aktif',
                                              '8', Icons.class_)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildStatCard(
                                      'Tugas Pending', '12', Icons.assignment),
                                ],
                              ),

                        const SizedBox(height: 24),

                        // Jadwal Mengajar Hari Ini
                        const Text(
                          'Jadwal Mengajar Hari Ini',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildScheduleCard(),

                        const SizedBox(height: 24),

                        // Feedback Orang Tua
                        const Text(
                          'Feedback Orang Tua',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFeedbackCard(),

                        const SizedBox(height: 24),

                        // Laporan Mingguan
                        const Text(
                          'Laporan Mingguan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildWeeklyReportCard(),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Gunakan PengajarFooter yang sudah dipisah
      bottomNavigationBar: const PengajarFooter(currentIndex: 1),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
              ),
              Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          _buildScheduleItem(
            'Matematika - Kelas 10A',
            '09:00 - 10:30',
            '15 Murid',
            Colors.blue,
          ),
          const Divider(height: 24),
          _buildScheduleItem(
            'Bahasa Indonesia - Kelas 11B',
            '13:00 - 14:30',
            '18 Murid',
            Colors.orange,
          ),
          const Divider(height: 24),
          _buildScheduleItem(
            'IPA - Kelas 9C',
            '15:00 - 16:30',
            '12 Murid',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(
      String title, String time, String students, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 14, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.people,
                      size: 14, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Text(
                    students,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Mulai',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          _buildSingleFeedback(
            'Bunda Umar',
            '2 hari yang lalu',
            'Terima kasih atas pengajarannya yang luar biasa! Anak saya sangat menikmati les matematika dan nilainya meningkat drastis.',
          ),
          const Divider(height: 24),
          _buildSingleFeedback(
            'Ayah Siti',
            '5 hari yang lalu',
            'Penjelasan materi sangat jelas dan mudah dipahami. Siti sekarang lebih percaya diri dalam belajar.',
          ),
        ],
      ),
    );
  }

  Widget _buildSingleFeedback(String name, String time, String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name.split(' ').map((e) => e[0]).join('').toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textDark,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyReportCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          _buildReportItem(
            'Alfito Mengumpulkan Tugas Matematika',
            '1 Menit lalu',
            Icons.assignment_turned_in,
            Colors.green,
          ),
          const Divider(height: 24),
          _buildReportItem(
            'Siti Menyelesaikan Quiz Bahasa Indonesia',
            '15 Menit lalu',
            Icons.quiz,
            Colors.blue,
          ),
          const Divider(height: 24),
          _buildReportItem(
            'Raka Bergabung di Kelas Fisika',
            '1 Jam lalu',
            Icons.person_add,
            Colors.orange,
          ),
          const Divider(height: 24),
          _buildReportItem(
            'Nina Meminta Revisi Tugas IPA',
            '2 Jam lalu',
            Icons.edit,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(
      String title, String time, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
