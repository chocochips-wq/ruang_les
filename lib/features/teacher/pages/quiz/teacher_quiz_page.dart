import 'package:flutter/material.dart';
import '../../widgets/teacher_app_bar.dart';
import '../../widgets/teacher_drawer.dart';
import '../../../../core/models/quiz/quiz.dart';

class TeacherQuizPage extends StatelessWidget {
  final List<Quiz> quizzes;
  final void Function() onCreateQuiz;
  final void Function(Quiz) onViewResults;

  const TeacherQuizPage({
    super.key,
    required this.quizzes,
    required this.onCreateQuiz,
    required this.onViewResults,
  });

  @override
  Widget build(BuildContext context) {
    return TeacherScaffold(
      title: 'Quiz',
      selectedMenuIndex: 4, // index sesuai menu Quiz di drawer
      onMenuSelected: (index) {
        Navigator.pop(context);
        // Navigasi ke menu lain jika perlu
      },
      onNotificationTap: () {},
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Quiz',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: onCreateQuiz,
                  icon: const Icon(Icons.add),
                  label: const Text('Buat Quiz'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: quizzes.isEmpty
                  ? Center(
                      child: Text('Belum ada quiz. Klik "Buat Quiz" untuk menambah.',
                          style: TextStyle(color: Colors.grey[600])),
                    )
                  : ListView.separated(
                      itemCount: quizzes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final quiz = quizzes[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              child: const Icon(Icons.quiz, color: Colors.blue),
                            ),
                            title: Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(quiz.description),
                            trailing: IconButton(
                              icon: const Icon(Icons.bar_chart, color: Colors.deepPurple),
                              tooltip: 'Lihat Hasil',
                              onPressed: () => onViewResults(quiz),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
