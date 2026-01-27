import 'package:flutter/material.dart';
import '../../../core/models/quiz/quiz.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Pengajar')),
      body: ListView.builder(
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          return Card(
            child: ListTile(
              title: Text(quiz.title),
              subtitle: Text(quiz.description),
              trailing: IconButton(
                icon: const Icon(Icons.bar_chart),
                onPressed: () => onViewResults(quiz),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onCreateQuiz,
        child: const Icon(Icons.add),
        tooltip: 'Buat Quiz Baru',
      ),
    );
  }
}
