import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/colors.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../../../core/models/quiz_model.dart';
import '../widgets/student_drawer.dart';
import '../widgets/student_bottom_nav.dart';

class QuizListPage extends StatefulWidget {
  const QuizListPage({super.key});

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StudentRepository _studentRepository = StudentRepository();
  final QuizRepository _quizRepository = QuizRepository();
  String? _studentId;

  @override
  void initState() {
    super.initState();
    _loadStudentId();
  }

  Future<void> _loadStudentId() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final student = await _studentRepository.getStudentByUserId(userId);
      if (student != null && student.studentId != null) {
        setState(() {
          _studentId = student.studentId;
        });
      }
    } catch (e) {
      print('Error loading student ID: $e');
    }
  }

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
        title: const Text('Kuis Saya',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      drawer: const DrawerMurid(),
      body: _studentId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<QuizModel>>(
              stream: _quizRepository.streamQuizzesByStudentId(_studentId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final quizzes = snapshot.data ?? [];

                if (quizzes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '📋',
                          style: TextStyle(fontSize: 64),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada kuis',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Kuis akan tersedia dari guru kamu',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = quizzes[index];
                    return _buildQuizCard(context, quiz);
                  },
                );
              },
            ),
      bottomNavigationBar: const FooterMurid(selectedIndex: 3),
    );
  }

  Widget _buildQuizCard(BuildContext context, QuizModel quiz) {
    final progress =
        quiz.isCompleted ? (quiz.score / quiz.totalPoints * 100).toInt() : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quiz.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: quiz.isCompleted
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    quiz.isCompleted ? '✅ Selesai' : '⏳ Belum',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: quiz.isCompleted ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Questions count
            Row(
              children: [
                const Icon(Icons.quiz, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  '${quiz.questions.length} soal',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  '${quiz.totalPoints} poin',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Score section (jika sudah selesai)
            if (quiz.isCompleted) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nilai Kamu',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${quiz.score}/${quiz.totalPoints}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Persentase',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$progress%',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to quiz detail/answer page
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(quiz.isCompleted
                          ? 'Lihat ulang: ${quiz.title}'
                          : 'Mulai: ${quiz.title}'),
                    ),
                  );
                },
                icon: Icon(quiz.isCompleted
                    ? Icons.visibility
                    : Icons.play_arrow),
                label: Text(
                  quiz.isCompleted ? 'Lihat Ulang' : 'Mulai Kuis',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: quiz.isCompleted
                      ? Colors.blue
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
