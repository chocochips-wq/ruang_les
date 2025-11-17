import 'package:flutter/material.dart';
import '../../pengaturan/warna.dart';
import '../drawer/drawer.dart';
import '../drawer/bottomnav.dart';
import 'halaman_buat_quiz.dart';
import 'halaman_hasil_quiz.dart';

class HalamanQuiz extends StatefulWidget {
  const HalamanQuiz({super.key});

  @override
  State<HalamanQuiz> createState() => _HalamanQuizState();
}

class _HalamanQuizState extends State<HalamanQuiz> with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();
  final _selectedFilter = 'Semua pelajaran';
  int _selectedMenuIndex = 3;
  late AnimationController _animationController;

  final List<Map<String, dynamic>> _quizList = [
    {
      'title': 'Matematika - Aljabar Dasar',
      'subject': 'Matematika - SMP',
      'questionCount': 20,
      'duration': 30,
      'deadline': '1 Jan 2026',
      'status': 'Aktif',
      'statusColor': Colors.green,
      'icon': Icons.calculate_outlined,
      'submittedCount': 25,
      'totalStudents': 30,
    },
    {
      'title': 'Bahasa Inggris - Grammar & Tenses',
      'subject': 'Bahasa Inggris - SMP',
      'questionCount': 20,
      'duration': 40,
      'deadline': '1 Jan 2026',
      'status': 'Draft',
      'statusColor': Colors.orange,
      'icon': Icons.language_outlined,
      'submittedCount': 0,
      'totalStudents': 30,
    },
    {
      'title': 'IPA - Sistem Pencernaan',
      'subject': 'IPA - SMP',
      'questionCount': 26,
      'duration': 30,
      'deadline': '11 Jan 2026',
      'status': 'Aktif',
      'statusColor': Colors.green,
      'icon': Icons.science_outlined,
      'submittedCount': 18,
      'totalStudents': 30,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _addNewQuiz(Map<String, dynamic> newQuiz) {
    setState(() {
      _quizList.insert(0, newQuiz);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: PengajarDrawer(
        selectedMenuIndex: _selectedMenuIndex,
        onMenuSelected: (index) => setState(() => _selectedMenuIndex = index),
      ),
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  _buildQuizList(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const PengajarFooter(currentIndex: 0),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu),
              color: AppColors.textWhite,
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            const Expanded(
              child: Text(
                'Kelola Quiz',
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
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _animationController,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.primary.withOpacity(0.05),
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
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.assignment_outlined, color: AppColors.primary, size: 32),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kelola Quiz Anda',
                    style: TextStyle(fontSize: 18, color: AppColors.textDark, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Buat quiz dan monitor progress murid dengan mudah',
                    style: TextStyle(fontSize: 14, color: AppColors.textLight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari Quiz..',
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Text(_selectedFilter, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuizList() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.textDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Quiz Tersedia',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textWhite),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HalamanBuatQuiz(),
                  ),
                );
                
                // Jika ada quiz baru yang dikembalikan
                if (result != null && result is Map<String, dynamic>) {
                  _addNewQuiz(result);
                }
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Buat Quiz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textWhite,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _quizList.length,
          itemBuilder: (ctx, i) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
              CurvedAnimation(parent: _animationController, curve: Interval(i * 0.1, 1.0, curve: Curves.easeOut)),
            ),
            child: _buildQuizCard(_quizList[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quiz) {
    final submitted = quiz['submittedCount'] as int;
    final total = quiz['totalStudents'] as int;
    final progress = total > 0 ? submitted / total : 0.0;
    final isActive = quiz['status'] == 'Aktif';
    final index = _quizList.indexOf(quiz);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [quiz['statusColor'].withOpacity(0.1), quiz['statusColor'].withOpacity(0.05)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: quiz['statusColor'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(quiz['icon'], color: quiz['statusColor'], size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(quiz['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(quiz['subject'], style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: quiz['statusColor'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: quiz['statusColor'].withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isActive ? Icons.check_circle : Icons.edit_note, size: 14, color: quiz['statusColor']),
                      const SizedBox(width: 4),
                      Text(quiz['status'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: quiz['statusColor'])),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildInfo(Icons.description_outlined, '${quiz['questionCount']} soal')),
                    Expanded(child: _buildInfo(Icons.access_time, '${quiz['duration']} menit')),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event_outlined, size: 16, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Text('Deadline: ${quiz['deadline']}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.red.shade700)),
                    ],
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pengumpulan Murid', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      Text('$submitted/$total', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(progress > 0.7 ? Colors.green : progress > 0.4 ? Colors.orange : Colors.red),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Text('Hapus Quiz?'),
                              content: Text('Apakah Anda yakin ingin menghapus quiz "${quiz['title']}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Batal'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() => _quizList.removeAt(index));
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Quiz berhasil dihapus'), backgroundColor: Colors.green),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('Hapus'),
                                  
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete_outline, size: 12, color: Colors.red),
                        label: const Text('Hapus', style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (isActive) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => HalamanHasilQuiz(quizTitle: quiz['title'], quizSubject: quiz['subject'])));
                          }
                        },
                        icon: Icon(isActive ? Icons.analytics_outlined : Icons.upload_outlined, size: 15),
                        label: Text(isActive ? 'Hasil' : 'Upload'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.textWhite),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textLight),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textLight, fontWeight: FontWeight.w500)),
      ],
    );
  }
}