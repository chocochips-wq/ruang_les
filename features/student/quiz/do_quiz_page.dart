import 'package:flutter/material.dart';
import '../../../core/models/quiz/quiz.dart';

class DoQuizPage extends StatefulWidget {
  final Quiz quiz;
  final void Function(QuizResult) onSubmit;
  final String studentId;

  const DoQuizPage({super.key, required this.quiz, required this.onSubmit, required this.studentId});

  @override
  State<DoQuizPage> createState() => _DoQuizPageState();
}

class _DoQuizPageState extends State<DoQuizPage> {
  final Map<String, int> _answers = {};

  void _submitQuiz() {
    int score = 0;
    final studentAnswers = <StudentAnswer>[];
    for (var q in widget.quiz.questions) {
      final selected = _answers[q.id] ?? -1;
      if (selected == q.correctAnswerIndex) score++;
      studentAnswers.add(StudentAnswer(questionId: q.id, selectedAnswerIndex: selected));
    }
    final result = QuizResult(
      quizId: widget.quiz.id,
      studentId: widget.studentId,
      score: score,
      answers: studentAnswers,
    );
    widget.onSubmit(result);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.quiz.description),
          const SizedBox(height: 16),
          ...widget.quiz.questions.map((q) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q.text, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ...List.generate(q.answers.length, (i) => RadioListTile<int>(
                          value: i,
                          groupValue: _answers[q.id],
                          onChanged: (val) => setState(() => _answers[q.id] = val!),
                          title: Text(q.answers[i].text),
                        )),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitQuiz,
            child: const Text('Kumpulkan'),
          ),
        ],
      ),
    );
  }
}
