import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/colors.dart';
import '../widgets/teacher_app_bar.dart';
import '../widgets/teacher_bottom_nav.dart';
import '../providers/teacher_provider.dart';
import '../../../core/models/class_model.dart';

class HalamanBeranda extends StatefulWidget {
  const HalamanBeranda({super.key});

  @override
  State<HalamanBeranda> createState() => _HalamanBerandaState();
}

class _HalamanBerandaState extends State<HalamanBeranda> {
  int _selectedMenuIndex = 0;

  @override
  void initState() {
    super.initState();
    // Ensure data is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<TeacherProvider>().currentTeacher;
      if (user != null) {
        context.read<TeacherProvider>().loadTeacherData(user.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TeacherScaffold(
      selectedMenuIndex: _selectedMenuIndex,
      onMenuSelected: (index) {
        setState(() {
          _selectedMenuIndex = index;
        });
      },
      onNotificationTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifikasi')),
        );
      },
      body: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          final totalStudents = teacherProvider.students.length;
          final totalClasses = teacherProvider.classes.length;

          return Column(
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
                                          child: _buildStatCard('Total Murid',
                                              '$totalStudents', Icons.people)),
                                      const SizedBox(width: 16),
                                      Expanded(
                                          child: _buildStatCard('Kelas Aktif',
                                              '$totalClasses', Icons.class_)),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                              child: _buildStatCard(
                                                  'Total Murid',
                                                  '$totalStudents',
                                                  Icons.people)),
                                          const SizedBox(width: 16),
                                          Expanded(
                                              child: _buildStatCard(
                                                  'Kelas Aktif',
                                                  '$totalClasses',
                                                  Icons.class_)),
                                        ],
                                      ),
                                    ],
                                  ),

                            const SizedBox(height: 24),

                            // Jadwal Mengajar Hari Ini
                            // Logic: Filter classes that contain today's day name in schedule string
                            _buildTodaySchedule(teacherProvider.classes),

                            const SizedBox(height: 24),

                            // Murid Terbaru (Pengganti Aktivitas Terakhir)
                            _buildRecentStudents(teacherProvider),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom Navigation
              const TeacherBottomNav(
                  currentIndex:
                      1), // Index 1 is Home in logic but Nav has Home at 1?
              // Wait, in BottomNav: 0=Materi, 1=Beranda, 2=Profil
            ],
          );
        },
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

  Widget _buildTodaySchedule(List<ClassModel> classes) {
    // Determine today's day name in Indonesian
    final now = DateTime.now();
    final dayNames = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    final todayName = dayNames[now.weekday - 1];

    // Filter classes
    final todayClasses =
        classes.where((c) => c.schedule.contains(todayName)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Jadwal Hari Ini ($todayName)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            if (todayClasses.isEmpty)
              Text(
                'Tidak ada jadwal',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (todayClasses.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: todayClasses.asMap().entries.map((entry) {
                final index = entry.key;
                final c = entry.value;
                return Column(
                  children: [
                    if (index > 0) const Divider(height: 24),
                    _buildScheduleItem(
                      c.className,
                      c.schedule,
                      '${c.studentIds.length} Murid',
                      _getColorForIndex(index),
                    ),
                  ],
                );
              }).toList(),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Center(
              child: Text('Libur mengajar! Istirahat yang cukup ☕'),
            ),
          ),
      ],
    );
  }

  Color _getColorForIndex(int index) {
    const colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red
    ];
    return colors[index % colors.length];
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
                  Expanded(
                    child: Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                      overflow: TextOverflow.ellipsis,
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
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            students,
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

  Widget _buildRecentStudents(TeacherProvider provider) {
    final students = provider.students.take(3).toList();
    if (students.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Murid Terbaru',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: students.asMap().entries.map((entry) {
              final index = entry.key;
              final s = entry.value;
              return Column(
                children: [
                  if (index > 0) const Divider(height: 24),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                        child: Text(s.fullName[0].toUpperCase()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Kelas ${s.gradeLevel}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Chip(
                        label: Text('Baru',
                            style:
                                TextStyle(fontSize: 10, color: Colors.white)),
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.all(0),
                      ),
                    ],
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
