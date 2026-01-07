import 'package:flutter/material.dart';
import '../pengaturan/warna.dart';
import 'drawer/appbar.dart';
import 'drawer/bottomnav.dart';

class HalamanBeranda extends StatefulWidget {
  const HalamanBeranda({super.key});

  @override
  State<HalamanBeranda> createState() => _HalamanBerandaState();
}

class _HalamanBerandaState extends State<HalamanBeranda> {
  int _selectedMenuIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Pakai PengajarScaffold yang sudah include AppBar + Drawer + Notif
    return PengajarScaffold(
      selectedMenuIndex: _selectedMenuIndex,
      onMenuSelected: (index) {
        setState(() {
          _selectedMenuIndex = index;
        });
      },
      onNotificationTap: () {
        // Aksi ketika notif diklik
        print('Notifikasi diklik');
        // Navigator.pushNamed(context, AppRoutes.pengajarNotifikasi);
      },
      body: Column(
        children: [
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

                        // Aktivitas Terakhir
                        const Text(
                          'Aktivitas Terakhir',
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
          
          // Bottom Navigation
          const PengajarFooter(currentIndex: 1),
        ],
      ),
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
            'Semi Private - PAUD',
            '09:00 - 10:00',
            '3 Murid',
            Colors.blue,
          ),
          const Divider(height: 24),
          _buildScheduleItem(
            'Reguler - SMP',
            '13:00 - 15:00',
            '8 Murid',
            Colors.orange,
          ),
          const Divider(height: 24),
          _buildScheduleItem(
            'Semi Private - SD',
            '15:00 - 17:00',
            '5 Murid',
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
            'Bunda Zayn',
            '2 hari yang lalu',
            'Terima kasih atas pengajarannya yang luar biasa! Anak saya sangat menikmati les matematika dan nilainya meningkat drastis.',
          ),
          const Divider(height: 24),
          _buildSingleFeedback(
            'Ayah Eleven',
            '5 hari yang lalu',
            'Penjelasan materi sangat jelas dan mudah dipahami. Eleven sekarang lebih percaya diri dalam belajar.',
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
            'Zayn Menyelesaikan Quiz Bahasa Indonesia',
            '15 Menit lalu',
            Icons.quiz,
            Colors.blue,
          ),
          const Divider(height: 24),
          _buildReportItem(
            'Raka Bergabung di Kelas Semi Private SD',
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