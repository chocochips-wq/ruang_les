import 'package:flutter/material.dart';
import '../../../../core/models/quiz/quiz.dart';

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

  void _addOrEditQuestion({Question? editQuestion, int? editIndex}) async {
    final questionController = TextEditingController(text: editQuestion?.text ?? '');
    final List<TextEditingController> answerControllers =
        List.generate(editQuestion?.answers.length ?? 4, (i) =>
            TextEditingController(text: editQuestion?.answers[i].text ?? ''));
    int correctIndex = editQuestion?.correctAnswerIndex ?? 0;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.quiz, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        editQuestion == null ? 'Tambah Soal' : 'Edit Soal',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: questionController,
                    decoration: InputDecoration(
                      labelText: 'Teks Soal',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.help_outline),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('Jawaban:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  ...List.generate(answerControllers.length, (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Radio<int>(
                              value: i,
                              groupValue: correctIndex,
                              onChanged: (val) {
                                correctIndex = val!;
                                (context as Element).markNeedsBuild();
                              },
                              activeColor: Colors.green,
                            ),
                            Expanded(
                              child: TextField(
                                controller: answerControllers[i],
                                decoration: InputDecoration(
                                  labelText: 'Jawaban ${i + 1}',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  prefixIcon: const Icon(Icons.short_text),
                                ),
                              ),
                            ),
                            if (answerControllers.length > 2)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Hapus jawaban',
                                onPressed: () {
                                  answerControllers.removeAt(i);
                                  if (correctIndex >= answerControllers.length) correctIndex = 0;
                                  (context as Element).markNeedsBuild();
                                },
                              ),
                          ],
                        ),
                      )),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          answerControllers.add(TextEditingController());
                          (context as Element).markNeedsBuild();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Jawaban'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          foregroundColor: Colors.blue.shade700,
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (questionController.text.trim().isEmpty ||
                              answerControllers.any((c) => c.text.trim().isEmpty)) return;
                          Navigator.pop(context, {
                            'text': questionController.text,
                            'answers': answerControllers.map((c) => c.text).toList(),
                            'correct': correctIndex,
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Simpan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (result != null) {
      final question = Question(
        id: UniqueKey().toString(),
        text: result['text'],
        answers: List.generate(result['answers'].length, (i) =>
            Answer(id: UniqueKey().toString(), text: result['answers'][i])),
        correctAnswerIndex: result['correct'],
      );
      setState(() {
        if (editIndex != null) {
          _questions[editIndex] = question;
        } else {
          _questions.add(question);
        }
      });
    }
  }

  void _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _saveQuiz() {
    if (_titleController.text.trim().isEmpty || _questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan minimal 1 soal wajib diisi!')),
      );
      return;
    }
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Daftar Soal', style: TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () => _addOrEditQuestion(),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Soal'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _questions.isEmpty
                  ? Center(child: Text('Belum ada soal.'))
                  : ListView.separated(
                      itemCount: _questions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final q = _questions[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            title: Text(q.text, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...List.generate(q.answers.length, (i) => Row(
                                  children: [
                                    Icon(
                                      i == q.correctAnswerIndex ? Icons.check_circle : Icons.circle_outlined,
                                      color: i == q.correctAnswerIndex ? Colors.green : Colors.grey,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(q.answers[i].text),
                                  ],
                                )),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () => _addOrEditQuestion(editQuestion: q, editIndex: index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteQuestion(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: const Text('Simpan Quiz'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
