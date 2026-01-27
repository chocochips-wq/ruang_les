import 'package:flutter/material.dart';
import '../../../../core/models/quiz/quiz.dart';

class StudentQuizPage extends StatelessWidget {
  final List<Quiz> quizzes;
  final void Function(Quiz) onStartQuiz;

  const StudentQuizPage({
    super.key,
    required this.quizzes,
    required this.onStartQuiz,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz untuk Murid')),
      body: ListView.builder(
        itemCount: quizzes.length,
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
