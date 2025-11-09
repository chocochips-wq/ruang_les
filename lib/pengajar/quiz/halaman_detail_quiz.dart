import 'package:flutter/material.dart';
import '../../pengaturan/warna.dart';

class HalamanHasilQuiz extends StatefulWidget {
  final String quizTitle;
  final String quizSubject;

  const HalamanHasilQuiz({
    super.key,
    required this.quizTitle,
    required this.quizSubject,
  });

  @override
  State<HalamanHasilQuiz> createState() => _HalamanHasilQuizState();
}

class _HalamanHasilQuizState extends State<HalamanHasilQuiz> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Map<String, dynamic>> _studentResults = [
    {
      'name': 'Ahmad Zaki',
      'avatar': 'AZ',
      'score': 95,
      'correctAnswers': 19,
      'totalQuestions': 20,
      'timeSpent': '25 menit',
      'submittedAt': '2 Jan 2026, 10:30',
      'status': 'Selesai',
    },
    {
      'name': 'Siti Nurhaliza',
      'avatar': 'SN',
      'score': 90,
      'correctAnswers': 18,
      'totalQuestions': 20,
      'timeSpent': '28 menit',
      'submittedAt': '2 Jan 2026, 11:15',
      'status': 'Selesai',
    },
    {
      'name': 'Budi Santoso',
      'avatar': 'BS',
      'score': 75,
      'correctAnswers': 15,
      'totalQuestions': 20,
      'timeSpent': '30 menit',
      'submittedAt': '2 Jan 2026, 14:20',
      'status': 'Selesai',
    },
    {
      'name': 'Rani Wijaya',
      'avatar': 'RW',
      'score': 85,
      'correctAnswers': 17,
      'totalQuestions': 20,
      'timeSpent': '27 menit',
      'submittedAt': '3 Jan 2026, 09:45',
      'status': 'Selesai',
    },
    {
      'name': 'Dimas Pratama',
      'avatar': 'DP',
      'score': 70,
      'correctAnswers': 14,
      'totalQuestions': 20,
      'timeSpent': '30 menit',
      'submittedAt': '3 Jan 2026, 13:00',
      'status': 'Selesai',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    // Calculate statistics
    int totalSubmitted = _studentResults.length;
    int totalStudents = 30;
    double averageScore = _studentResults.fold(0.0, (sum, student) => sum + student['score']) / totalSubmitted;
    int passedCount = _studentResults.where((s) => s['score'] >= 75).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hasil Quiz',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined, color: AppColors.textWhite),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mengunduh laporan...')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.quizTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.quizSubject,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textWhite.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                // Statistics Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Pengumpulan',
                        '$totalSubmitted/$totalStudents',
                        Icons.people_outline,
                        Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Rata-rata',
                        averageScore.toStringAsFixed(1),
                        Icons.analytics_outlined,
                        Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Lulus',
                        '$passedCount murid',
                        Icons.verified_outlined,
                        Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: AppColors.cardBackground,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textLight,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Daftar Nilai'),
                Tab(text: 'Statistik'),
              ],
            ),
          ),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStudentListTab(),
                _buildStatisticsTab(averageScore, passedCount, totalSubmitted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentListTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _studentResults.length,
      itemBuilder: (context, index) {
        final student = _studentResults[index];
        return _buildStudentCard(student, index);
      },
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, int index) {
    Color scoreColor = student['score'] >= 85
        ? Colors.green
        : student['score'] >= 75
            ? Colors.blue
            : student['score'] >= 60
                ? Colors.orange
                : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scoreColor.withOpacity(0.1),
                  scoreColor.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      student['avatar'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
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
                        student['name'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        student['submittedAt'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: scoreColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: scoreColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${student['score']}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.check_circle_outline,
                    'Benar',
                    '${student['correctAnswers']}/${student['totalQuestions']}',
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.shade300,
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.timer_outlined,
                    'Waktu',
                    student['timeSpent'],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.shade300,
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.info_outline,
                    'Status',
                    student['status'],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.textLight),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsTab(double averageScore, int passedCount, int totalSubmitted) {
    Map<String, int> scoreDistribution = {
      '90-100': _studentResults.where((s) => s['score'] >= 90).length,
      '80-89': _studentResults.where((s) => s['score'] >= 80 && s['score'] < 90).length,
      '70-79': _studentResults.where((s) => s['score'] >= 70 && s['score'] < 80).length,
      '60-69': _studentResults.where((s) => s['score'] >= 60 && s['score'] < 70).length,
      '<60': _studentResults.where((s) => s['score'] < 60).length,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Stats
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Nilai Rata-rata Kelas',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  averageScore.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '$passedCount',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Lulus',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                    Column(
                      children: [
                        Text(
                          '${totalSubmitted - passedCount}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Perlu Perbaikan',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Distribusi Nilai',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          ...scoreDistribution.entries.map((entry) {
            return _buildDistributionBar(
              entry.key,
              entry.value,
              totalSubmitted,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDistributionBar(String range, int count, int total) {
    double percentage = (count / total);
    Color barColor = range == '90-100'
        ? Colors.green
        : range == '80-89'
            ? Colors.blue
            : range == '70-79'
                ? Colors.orange
                : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
                range,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '$count murid',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}