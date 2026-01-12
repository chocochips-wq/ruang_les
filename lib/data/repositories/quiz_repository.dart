import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/quiz_model.dart';

class QuizRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all quizzes for a student
  Future<List<QuizModel>> getQuizzesByStudentId(String studentId) async {
    try {
      final query = await _firestore
          .collection('quizzes')
          .where('studentId', isEqualTo: studentId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => QuizModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Gagal memuat kuis: $e');
    }
  }

  // Stream all quizzes for a student
  Stream<List<QuizModel>> streamQuizzesByStudentId(String studentId) {
    return _firestore
        .collection('quizzes')
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QuizModel.fromFirestore(doc))
            .toList());
  }

  // Get incomplete quizzes
  Future<List<QuizModel>> getIncompleteQuizzes(String studentId) async {
    try {
      final query = await _firestore
          .collection('quizzes')
          .where('studentId', isEqualTo: studentId)
          .where('isCompleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => QuizModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Gagal memuat kuis: $e');
    }
  }

  // Get completed quizzes
  Future<List<QuizModel>> getCompletedQuizzes(String studentId) async {
    try {
      final query = await _firestore
          .collection('quizzes')
          .where('studentId', isEqualTo: studentId)
          .where('isCompleted', isEqualTo: true)
          .orderBy('completedAt', descending: true)
          .get();

      return query.docs.map((doc) => QuizModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Gagal memuat kuis: $e');
    }
  }

  // Get quiz by ID
  Future<QuizModel?> getQuizById(String quizId) async {
    try {
      final doc = await _firestore.collection('quizzes').doc(quizId).get();

      if (!doc.exists) {
        return null;
      }

      return QuizModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Gagal memuat kuis: $e');
    }
  }

  // Stream quiz by ID
  Stream<QuizModel?> streamQuizById(String quizId) {
    return _firestore.collection('quizzes').doc(quizId).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return QuizModel.fromFirestore(doc);
    });
  }

  // Create quiz
  Future<String> createQuiz(QuizModel quiz) async {
    try {
      final doc = await _firestore.collection('quizzes').add(quiz.toMap());
      return doc.id;
    } catch (e) {
      throw Exception('Gagal membuat kuis: $e');
    }
  }

  // Update quiz
  Future<void> updateQuiz(String quizId, QuizModel quiz) async {
    try {
      await _firestore.collection('quizzes').doc(quizId).update(quiz.toMap());
    } catch (e) {
      throw Exception('Gagal memperbarui kuis: $e');
    }
  }

  // Submit quiz (mark as completed)
  Future<void> submitQuiz(
    String quizId,
    int score,
    List<QuizQuestion> questions,
  ) async {
    try {
      await _firestore.collection('quizzes').doc(quizId).update({
        'isCompleted': true,
        'score': score,
        'completedAt': Timestamp.now(),
        'questions': questions.map((q) => q.toMap()).toList(),
      });
    } catch (e) {
      throw Exception('Gagal submit kuis: $e');
    }
  }

  // Get quizzes by class
  Future<List<QuizModel>> getQuizzesByClassId(String classId) async {
    try {
      final query = await _firestore
          .collection('quizzes')
          .where('classId', isEqualTo: classId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => QuizModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Gagal memuat kuis: $e');
    }
  }

  // Stream quizzes by class
  Stream<List<QuizModel>> streamQuizzesByClassId(String classId) {
    return _firestore
        .collection('quizzes')
        .where('classId', isEqualTo: classId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QuizModel.fromFirestore(doc))
            .toList());
  }
}
