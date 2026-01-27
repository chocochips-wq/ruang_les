import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/quiz/quiz.dart';
import '../../../../core/models/quiz_model.dart';
import '../../../../core/models/class_model.dart';
import '../../../../data/repositories/quiz_repository.dart';
import '../providers/teacher_provider.dart';
import 'quiz/teacher_quiz_page.dart';
import 'quiz/create_quiz_page.dart';

class TeacherQuizManagement extends StatefulWidget {
  const TeacherQuizManagement({super.key});

  @override
  State<TeacherQuizManagement> createState() => _TeacherQuizManagementState();
}

class _TeacherQuizManagementState extends State<TeacherQuizManagement> {
  List<Quiz> _displayedQuizzes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchQuizzes();
    });
  }

  Future<void> _fetchQuizzes() async {
    setState(() => _isLoading = true);
    final teacherProvider = context.read<TeacherProvider>();
    final quizRepo = context.read<QuizRepository>();

    try {
      // Ensure classes are loaded
      if (teacherProvider.classes.isEmpty) {
        // Teacher data might not be loaded yet?
        // We rely on TeacherProvider being initialized by TeacherHome.
        // If empty, we can't do much.
      }

      final List<Quiz> aggregatedQuizzes = [];
      final Set<String> processedKeys = {}; // Key: "classId_title_description"

      for (final cls in teacherProvider.classes) {
        if (cls.classId == null) continue;

        final quizzes = await quizRepo.getQuizzesByClassId(cls.classId!);

        for (final qModel in quizzes) {
          // Create a unique key to group identical quizzes sent to multiple students in the same class
          // We assume quizzes with same title & description in same class are the "same" quiz assignment
          final key = '${cls.classId}_${qModel.title}_${qModel.description}';

          if (!processedKeys.contains(key)) {
            processedKeys.add(key);

            // Convert QuizModel (Firestore) -> Quiz (Local UI)
            aggregatedQuizzes.add(Quiz(
              id: qModel.quizId ?? '', // Use the ID of the first instance found
              title:
                  '${qModel.title} (${cls.className})', // Append class name for clarity
              description: qModel.description,
              teacherId: teacherProvider.currentTeacher?.teacherId ?? '',
              questions: qModel.questions
                  .map((q) => Question(
                        id: q.id.isEmpty ? UniqueKey().toString() : q.id,
                        text: q.question,
                        answers: q.options
                            .map((opt) =>
                                Answer(id: UniqueKey().toString(), text: opt))
                            .toList(),
                        correctAnswerIndex: q.correctOptionIndex,
                      ))
                  .toList(),
              createdAt: qModel.createdAt,
            ));
          }
        }
      }

      // Sort by newest
      aggregatedQuizzes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (mounted) {
        setState(() {
          _displayedQuizzes = aggregatedQuizzes;
        });
      }
    } catch (e) {
      print("Error fetching quizzes: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat daftar kuis: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleQuizWithClassSelection(Quiz quizTemplate) async {
    final teacherProvider = context.read<TeacherProvider>();

    // 1. Get Classes from Provider
    // The provider already holds the loaded classes for the current teacher
    final classes = teacherProvider.classes;

    if (classes.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda belum memiliki kelas.')),
        );
      }
      return;
    }

    // 2. Show Dialog to Select Class
    if (!mounted) return;

    final ClassModel? selectedClass = await showDialog<ClassModel>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pilih Kelas'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: classes.length,
              itemBuilder: (context, index) {
                final cls = classes[index];
                return ListTile(
                  title: Text('${cls.className} - ${cls.gradeLevel}'),
                  subtitle: Text('${cls.studentIds.length} Siswa'),
                  onTap: () {
                    Navigator.pop(context, cls);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedClass == null) return; // User cancelled

    // 3. Create Quiz for each student
    await _publishQuizToClass(quizTemplate, selectedClass);
  }

  Future<void> _publishQuizToClass(
      Quiz quizTemplate, ClassModel targetClass) async {
    setState(() {
      _isLoading = true;
    });

    final quizRepo = context.read<QuizRepository>();

    try {
      if (targetClass.studentIds.isEmpty) {
        throw Exception('Kelas ini tidak memilik siswa.');
      }

      int count = 0;
      for (final studentId in targetClass.studentIds) {
        // Map Dummy Quiz -> Real QuizModel
        final quizModel = QuizModel(
          studentId: studentId,
          classId: targetClass.classId!, // classId is required
          title: quizTemplate.title,
          description: quizTemplate.description,
          questions: quizTemplate.questions.map((q) {
            return QuizQuestion(
              id: q.id,
              question: q.text,
              options: q.answers.map((a) => a.text).toList(),
              correctOptionIndex: q.correctAnswerIndex,
              points: 10, // Default points per question
            );
          }).toList(),
          totalPoints: quizTemplate.questions.length * 10,
          createdAt: DateTime.now(),
        );

        await quizRepo.createQuiz(quizModel);
        count++;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sukses membagikan kuis ke $count siswa.')),
        );
        // Refresh list
        _fetchQuizzes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat kuis: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openCreateQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CreateQuizPage(onQuizCreated: _handleQuizWithClassSelection),
      ),
    );
  }

  void _viewResults(Quiz quiz) {
    // TODO: Implementasi halaman hasil quiz (Real) using QuizRepository
    // Since local quiz doesn't have IDs linked to real quizzes easily without more tracking,
    // we'll keep this as a stub or implement a class-based result view later.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lihat hasil untuk quiz: ${quiz.title}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TeacherQuizPage(
          quizzes: _displayedQuizzes,
          onCreateQuiz: _openCreateQuiz,
          onViewResults: _viewResults,
        ),
        if (_isLoading)
          Container(
            color: Colors.black45,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
