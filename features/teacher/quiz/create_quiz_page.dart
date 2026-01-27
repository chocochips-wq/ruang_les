import 'package:flutter/material.dart';
import '../../../core/models/quiz/quiz.dart';

class CreateQuizPage extends StatefulWidget {
  final void Function(Quiz) onQuizCreated;
  const CreateQuizPage({super.key, required this.onQuizCreated});

  @override
  State<CreateQuizPage> createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final List<Question> _questions = [];

  void _addQuestion() async {
    // Dialog untuk tambah soal
    // ...
  }

  void _saveQuiz() {
    final quiz = Quiz(
      id: UniqueKey().toString(),
      title: _titleController.text,
      description: _descController.text,
      teacherId: 'teacherId', // Ganti dengan id pengajar
      questions: _questions,
      createdAt: DateTime.now(),
    );
    widget.onQuizCreated(quiz);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Quiz Baru')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul Quiz'),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addQuestion,
              child: const Text('Tambah Soal'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final q = _questions[index];
                  return ListTile(
                    title: Text(q.text),
                    subtitle: Text('Jawaban: ${q.answers.length}'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _saveQuiz,
              child: const Text('Simpan Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
