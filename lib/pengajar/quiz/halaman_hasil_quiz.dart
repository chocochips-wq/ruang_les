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

class _HalamanHasilQuizState extends State<HalamanHasilQuiz> {
  final _searchController = TextEditingController();

  final _studentResults = [
    {
      'name': 'Zayn Athallah',
      'studentId': '2024001',
      'score': 95,
      'submittedAt': '30 Des 2025, 14:30',
      'duration': '25 menit',
      'status': 'Selesai',
      'avatar': 'ZA',
    },
    {
      'name': 'Max Mayfield',
      'studentId': '2024002',
      'score': 88,
      'submittedAt': '30 Des 2025, 15:20',
      'duration': '28 menit',
      'status': 'Selesai',
      'avatar': 'MM',
    },
    {
      'name': 'Will Harrington',
      'studentId': '2024003',
      'score': 92,
      'submittedAt': '31 Des 2025, 09:15',
      'duration': '23 menit',
      'status': 'Selesai',
      'avatar': 'WH',
    },
    {
      'name': 'Jonathan',
      'studentId': '2024004',
      'score': 78,
      'submittedAt': '31 Des 2025, 10:45',
      'duration': '30 menit',
      'status': 'Selesai',
      'avatar': 'J',
    },
    {
      'name': 'Nina Bobo',
      'studentId': '2024005',
      'score': 85,
      'submittedAt': '31 Des 2025, 13:20',
      'duration': '27 menit',
      'status': 'Selesai',
      'avatar': 'NB',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double get _average => _studentResults.isEmpty
      ? 0
      : _studentResults.fold<int>(0, (sum, s) => sum + (s['score'] as int)) /
          _studentResults.length;

  int get _passedCount =>
      _studentResults.where((s) => (s['score'] as int) >= 75).length;

  Color _getScoreColor(int score) {
    if (score >= 85) return Colors.green;
    if (score >= 75) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hasil Quiz',
          style: TextStyle(
              color: AppColors.textWhite, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined,
                color: AppColors.textWhite),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuizInfo(),
            const SizedBox(height: 20),
            _buildStatistics(),
            const SizedBox(height: 24),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildResults(),
          ],
        ),
      ),
    );
  }

  // Info utama quiz (judul & mapel)
  Widget _buildQuizInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.assignment_outlined,
                color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.quizTitle,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(widget.quizSubject,
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Statistik hasil quiz (rata-rata, pengumpulan, lulus)
  Widget _buildStatistics() {
    return Row(
      children: [
        Expanded(
            child: _buildStatCard('Rata-rata', _average.toStringAsFixed(1),
                Icons.trending_up, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatCard('Pengumpulan', '${_studentResults.length}',
                Icons.people_outline, Colors.green)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatCard('Lulus', '$_passedCount',
                Icons.check_circle_outline, Colors.orange)),
      ],
    );
  }

  // Card statistik kecil
  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  // Search bar & filter murid
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari murid...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Icon(Icons.filter_list),
        ),
      ],
    );
  }

  // List hasil murid
  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.textDark,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Hasil Murid (${_studentResults.length})',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textWhite),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _studentResults.length,
          itemBuilder: (_, i) => _buildStudentCard(_studentResults[i]),
        ),
      ],
    );
  }

  // Card hasil per murid
  Widget _buildStudentCard(Map<String, dynamic> student) {
    final scoreColor = _getScoreColor(student['score']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: scoreColor.withOpacity(0.2),
                child: Text(student['avatar'],
                    style: TextStyle(
                        color: scoreColor, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student['name'],
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    Text('NIS: ${student['studentId']}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: scoreColor.withOpacity(0.3)),
                ),
                child: Text('${student['score']}',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: scoreColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(student['duration'],
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade700)),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.event_outlined,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          student['submittedAt'],
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showDetail(student),
              icon: const Icon(Icons.visibility_outlined, size: 16),
              label: const Text('Lihat Detail'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(student['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Nilai', '${student['score']}'),
            _buildDetailRow('NIS', student['studentId']),
            _buildDetailRow('Waktu', student['duration']),
            _buildDetailRow('Dikumpulkan', student['submittedAt']),
            _buildDetailRow('Status', student['status']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          Text(value,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
