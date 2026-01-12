import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/quiz_model.dart';

class QuizSeeding {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seed dummy quiz data untuk student
  static Future<void> seedQuizData(
    String studentId,
    String classId,
  ) async {
    try {
      print('Seeding quiz data for student: $studentId');

      final now = DateTime.now();

      // Quiz 1: Matematika Dasar
      final quiz1 = QuizModel(
        studentId: studentId,
        classId: classId,
        title: 'Matematika Dasar',
        description: 'Kuis tentang penjumlahan dan pengurangan',
        questions: [
          QuizQuestion(
            id: 'q1',
            question: 'Berapa hasil dari 5 + 3?',
            options: ['6', '8', '9', '10'],
            correctOptionIndex: 1,
            points: 10,
          ),
          QuizQuestion(
            id: 'q2',
            question: 'Berapa hasil dari 10 - 4?',
            options: ['5', '6', '7', '8'],
            correctOptionIndex: 1,
            points: 10,
          ),
          QuizQuestion(
            id: 'q3',
            question: 'Berapa hasil dari 7 × 3?',
            options: ['18', '20', '21', '24'],
            correctOptionIndex: 2,
            points: 15,
          ),
        ],
        totalPoints: 35,
        createdAt: now.subtract(const Duration(days: 5)),
      );

      // Quiz 2: Bahasa Inggris
      final quiz2 = QuizModel(
        studentId: studentId,
        classId: classId,
        title: 'Bahasa Inggris Dasar',
        description: 'Kuis tentang vocab dan grammar',
        questions: [
          QuizQuestion(
            id: 'q1',
            question: 'What is the English word for "buku"?',
            options: ['pen', 'book', 'desk', 'chair'],
            correctOptionIndex: 1,
            points: 10,
          ),
          QuizQuestion(
            id: 'q2',
            question: 'Choose the correct sentence:',
            options: [
              'She go to school',
              'She goes to school',
              'She going to school',
              'She gone to school'
            ],
            correctOptionIndex: 1,
            points: 15,
          ),
          QuizQuestion(
            id: 'q3',
            question: 'What is "hari" in English?',
            options: ['night', 'day', 'month', 'year'],
            correctOptionIndex: 1,
            points: 10,
          ),
        ],
        totalPoints: 35,
        createdAt: now.subtract(const Duration(days: 3)),
      );

      // Quiz 3: IPA (Sains)
      final quiz3 = QuizModel(
        studentId: studentId,
        classId: classId,
        title: 'IPA - Tumbuhan',
        description: 'Kuis tentang bagian-bagian tumbuhan',
        questions: [
          QuizQuestion(
            id: 'q1',
            question: 'Bagian tumbuhan yang berfungsi menyerap air adalah?',
            options: ['Daun', 'Batang', 'Akar', 'Bunga'],
            correctOptionIndex: 2,
            points: 10,
          ),
          QuizQuestion(
            id: 'q2',
            question: 'Proses tumbuhan membuat makanan sendiri disebut?',
            options: [
              'Respirasi',
              'Fotosintesis',
              'Transpirasi',
              'Evaporasi'
            ],
            correctOptionIndex: 1,
            points: 15,
          ),
          QuizQuestion(
            id: 'q3',
            question: 'Daun berwarna hijau karena mengandung?',
            options: ['Klorofil', 'Karotin', 'Amilum', 'Glukosa'],
            correctOptionIndex: 0,
            points: 15,
          ),
        ],
        totalPoints: 40,
        createdAt: now.subtract(const Duration(days: 2)),
      );

      // Quiz 4: IPS (Geografi)
      final quiz4 = QuizModel(
        studentId: studentId,
        classId: classId,
        title: 'IPS - Benua Dunia',
        description: 'Kuis tentang benua dan negara',
        questions: [
          QuizQuestion(
            id: 'q1',
            question: 'Berapa banyak benua di dunia?',
            options: ['5', '6', '7', '8'],
            correctOptionIndex: 2,
            points: 10,
          ),
          QuizQuestion(
            id: 'q2',
            question: 'Ibukota Australia adalah?',
            options: ['Sydney', 'Melbourne', 'Canberra', 'Brisbane'],
            correctOptionIndex: 2,
            points: 15,
          ),
          QuizQuestion(
            id: 'q3',
            question: 'Negara terbesar di Amerika Selatan adalah?',
            options: ['Argentina', 'Brazil', 'Peru', 'Colombia'],
            correctOptionIndex: 1,
            points: 15,
          ),
        ],
        totalPoints: 40,
        createdAt: now.subtract(const Duration(days: 1)),
      );

      // Quiz 5: Bahasa Indonesia
      final quiz5 = QuizModel(
        studentId: studentId,
        classId: classId,
        title: 'Bahasa Indonesia - Tata Bahasa',
        description: 'Kuis tentang kalimat dan kata',
        questions: [
          QuizQuestion(
            id: 'q1',
            question: 'Kalimat yang mengakhiri dengan tanda apa disebut kalimat tanya?',
            options: ['.', ',', '!', '?'],
            correctOptionIndex: 3,
            points: 10,
          ),
          QuizQuestion(
            id: 'q2',
            question: 'Kata kerja yang menunjukkan keadaan disebut?',
            options: [
              'Kata sifat',
              'Kata keadaan',
              'Kata benda',
              'Kata keterangan'
            ],
            correctOptionIndex: 1,
            points: 15,
          ),
          QuizQuestion(
            id: 'q3',
            question:
                'Kata "berlari" termasuk kata kerja yang menunjukkan tindakan?',
            options: [
              'Pasif',
              'Aktif',
              'Statis',
              'Dinamis'
            ],
            correctOptionIndex: 1,
            points: 15,
          ),
        ],
        totalPoints: 40,
        createdAt: now,
      );

      final quizzes = [quiz1, quiz2, quiz3, quiz4, quiz5];

      for (final quiz in quizzes) {
        try {
          await _firestore.collection('quizzes').add(quiz.toMap());
          print('Quiz created: ${quiz.title}');
        } catch (e) {
          print('Error creating quiz ${quiz.title}: $e');
        }
      }

      print('Quiz seeding completed successfully');
    } catch (e) {
      print('Error seeding quiz data: $e');
    }
  }

  /// Clear semua quiz data untuk student
  static Future<void> clearQuizData(String studentId) async {
    try {
      print('Clearing quiz data for student: $studentId');

      final query = await _firestore
          .collection('quizzes')
          .where('studentId', isEqualTo: studentId)
          .get();

      for (final doc in query.docs) {
        await doc.reference.delete();
      }

      print('Quiz data cleared successfully');
    } catch (e) {
      print('Error clearing quiz data: $e');
    }
  }
}
