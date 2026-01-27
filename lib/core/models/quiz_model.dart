import 'package:cloud_firestore/cloud_firestore.dart';

class QuizModel {
  final String? quizId;
  final String studentId;
  final String classId;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final int totalPoints;
  final int score;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  QuizModel({
    this.quizId,
    required this.studentId,
    required this.classId,
    required this.title,
    required this.description,
    required this.questions,
    this.totalPoints = 100,
    this.score = 0,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'classId': classId,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toMap()).toList(),
      'totalPoints': totalPoints,
      'score': score,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  factory QuizModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return QuizModel(
      quizId: doc.id,
      studentId: data['studentId'] ?? '',
      classId: data['classId'] ?? '',
      title: data['title'] ?? 'Quiz',
      description: data['description'] ?? '',
      questions: (data['questions'] as List<dynamic>?)
              ?.map((q) => QuizQuestion.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
      totalPoints: data['totalPoints'] ?? 100,
      score: data['score'] ?? 0,
      isCompleted: data['isCompleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  QuizModel copyWith({
    String? quizId,
    String? studentId,
    String? classId,
    String? title,
    String? description,
    List<QuizQuestion>? questions,
    int? totalPoints,
    int? score,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return QuizModel(
      quizId: quizId ?? this.quizId,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      title: title ?? this.title,
      description: description ?? this.description,
      questions: questions ?? this.questions,
      totalPoints: totalPoints ?? this.totalPoints,
      score: score ?? this.score,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final int points;
  int? selectedOptionIndex;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.points = 10,
    this.selectedOptionIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'points': points,
      'selectedOptionIndex': selectedOptionIndex,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> data) {
    return QuizQuestion(
      id: data['id'] ?? '',
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctOptionIndex: data['correctOptionIndex'] ?? 0,
      points: data['points'] ?? 10,
      selectedOptionIndex: data['selectedOptionIndex'],
    );
  }

  QuizQuestion copyWith({
    String? id,
    String? question,
    List<String>? options,
    int? correctOptionIndex,
    int? points,
    int? selectedOptionIndex,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      points: points ?? this.points,
      selectedOptionIndex: selectedOptionIndex ?? this.selectedOptionIndex,
    );
  }

  bool isCorrect() {
    return selectedOptionIndex == correctOptionIndex;
  }
}
