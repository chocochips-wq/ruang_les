import 'package:flutter/material.dart';
import '../pengaturan/warna.dart';
import '../komponen/app_drawer.dart';

class HalamanQuiz extends StatefulWidget {
  const HalamanQuiz({super.key});

  @override
  State<HalamanQuiz> createState() => _HalamanQuizState();
}

class _HalamanQuizState extends State<HalamanQuiz> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Tambahkan ini
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Semua pelajaran';
  int _selectedMenuIndex = 2; // Index 2 untuk Quiz di drawer

  final List<Map<String, dynamic>> _quizList = [
    {
      'title': 'Matematika - Aljabar Dasar',
      'subject': 'Matematika - SMP',
      'questionCount': 20,
      'duration': 30,
      'deadline': '1 Jan 2026',
      'status': 'Mudah',
      'statusColor': Colors.green,
    },
    {
      'title': 'Bahasa Inggris - Grammar & Tenses',
      'subject': 'Matematika - SMP',
      'questionCount': 20,
      'duration': 40,
      'deadline': '1 Jan 2026',
      'status': 'Sedang',
      'statusColor': Colors.orange,
    },
    {
      'title': 'IPA - Sistem Pencernaan',
      'subject': 'IPA - SMP',
      'questionCount': 26,
      'duration': 30,
      'deadline': '11 Jan 2026',
      'status': 'Mudah',
      'statusColor': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Tambahkan key
      backgroundColor: AppColors.background,
      drawer: AppDrawer( // Tambahkan drawer
        selectedMenuIndex: _selectedMenuIndex,
        onMenuSelected: (index) {
          setState(() {
            _selectedMenuIndex = index;
          });
        },
      ),
      body: Column(
        children: [
          // Custom AppBar dengan warna hijau
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Ganti arrow_back dengan menu icon
                  IconButton(
                    icon: const Icon(Icons.menu),
                    color: AppColors.textWhite,
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer(); // Buka drawer
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Quiz',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  // Optional: Tambahkan notifikasi dan profil seperti di beranda
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Text
                    const Text(
                      'Persiapkan quiz untuk melatih pemahaman muridmu!',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Search Bar and Filter
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Cari Quiz..',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey.shade600,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _selectedFilter,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: AppColors.textDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Quiz Tersedia Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textDark,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Quiz Tersedia',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textWhite,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Tambah quiz
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Tambah'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cardBackground,
                            foregroundColor: AppColors.textDark,
                            elevation: 0,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Quiz List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _quizList.length,
                      itemBuilder: (context, index) {
                        return _buildQuizCard(_quizList[index]);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Materi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quiz) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quiz['subject'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  quiz['status'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quiz Info
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                size: 18,
                color: AppColors.textLight,
              ),
              const SizedBox(width: 6),
              Text(
                '${quiz['questionCount']} soal',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(width: 20),
              const Icon(
                Icons.access_time,
                size: 18,
                color: AppColors.textLight,
              ),
              const SizedBox(width: 6),
              Text(
                '${quiz['duration']} menit',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Deadline
          Text(
            'Deadline: ${quiz['deadline']}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textLight,
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Edit quiz
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textDark,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Lihat/Unggah quiz
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textDark,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    quiz['status'] == 'Mudah' ? 'Lihat Quiz' : 'Unggah Quiz',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}