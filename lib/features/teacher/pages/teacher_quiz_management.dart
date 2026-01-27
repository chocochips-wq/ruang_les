import 'package:flutter/material.dart';
import '../../../../core/models/quiz/quiz.dart';
import 'quiz/teacher_quiz_page.dart';
import 'quiz/create_quiz_page.dart';

class TeacherQuizManagement extends StatefulWidget {
  const TeacherQuizManagement({super.key});

  @override
  State<TeacherQuizManagement> createState() => _TeacherQuizManagementState();
}

class _TeacherQuizManagementState extends State<TeacherQuizManagement> {
  final List<Quiz> _quizzes = [];

  void _addQuiz(Quiz quiz) {
    setState(() {
      _quizzes.add(quiz);
    });
  }

  void _openCreateQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateQuizPage(onQuizCreated: _addQuiz),
      ),
    );
  }

  void _viewResults(Quiz quiz) {
    // TODO: Implementasi halaman hasil quiz
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lihat hasil untuk quiz: ${quiz.title}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TeacherQuizPage(
      quizzes: _quizzes,
      onCreateQuiz: _openCreateQuiz,
      onViewResults: _viewResults,
    );
  }
}
