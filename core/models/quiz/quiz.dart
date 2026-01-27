class Quiz {
  final String id;
  final String title;
  final String description;
  final String teacherId;
  final List<Question> questions;
  final DateTime createdAt;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.teacherId,
    required this.questions,
    required this.createdAt,
  });
}

class Question {
  final String id;
  final String text;
  final List<Answer> answers;
  final int correctAnswerIndex;

  Question({
    required this.id,
    required this.text,
    required this.answers,
    required this.correctAnswerIndex,
  });
}

class Answer {
  final String id;
  final String text;

  Answer({
    required this.id,
    required this.text,
  });
}

class QuizResult {
  final String quizId;
  final String studentId;
  final int score;
  final List<StudentAnswer> answers;

  QuizResult({
    required this.quizId,
    required this.studentId,
    required this.score,
    required this.answers,
  });
}

class StudentAnswer {
  final String questionId;
  final int selectedAnswerIndex;

  StudentAnswer({
    required this.questionId,
    required this.selectedAnswerIndex,
  });
}
