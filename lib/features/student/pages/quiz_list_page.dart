import 'package:flutter/material.dart';
import '../../../core/models/quiz/quiz.dart';
import '../widgets/student_drawer.dart';

class QuizListPage extends StatelessWidget {
  final List<Quiz> quizzes;
  final void Function(Quiz) onStartQuiz;
  const QuizListPage({super.key, required this.quizzes, required this.onStartQuiz});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz dari Pengajar')),
      drawer: const DrawerMurid(),
      body: quizzes.isEmpty
          ? const Center(child: Text('Belum ada quiz dari pengajar.'))
          : ListView.separated(
              itemCount: quizzes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final quiz = quizzes[index];
                return Card(
                  child: ListTile(
                    title: Text(quiz.title),
                    subtitle: Text(quiz.description),
                    trailing: ElevatedButton(
                      onPressed: () => onStartQuiz(quiz),
                      child: const Text('Kerjakan'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
