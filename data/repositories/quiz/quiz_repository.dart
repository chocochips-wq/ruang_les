import '../../datasources/quiz/quiz_datasource.dart';
import '../../../core/models/quiz/quiz.dart';

class QuizRepository {
  final QuizDataSource dataSource;
  QuizRepository(this.dataSource);

  Future<void> createQuiz(Quiz quiz) => dataSource.createQuiz(quiz);
  Future<List<Quiz>> getQuizzesByTeacher(String teacherId) => dataSource.getQuizzesByTeacher(teacherId);
  Future<List<Quiz>> getQuizzesForStudent(String studentId) => dataSource.getQuizzesForStudent(studentId);
  Future<void> submitQuizResult(QuizResult result) => dataSource.submitQuizResult(result);
  Future<List<QuizResult>> getResultsForQuiz(String quizId) => dataSource.getResultsForQuiz(quizId);
}
