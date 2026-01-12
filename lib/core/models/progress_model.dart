import 'package:cloud_firestore/cloud_firestore.dart';

class StudentProgressModel {
  final String? progressId;
  final String studentId;
  final String? subjectId;
  final int currentLevel;
  final int maxLevel;
  final int experiencePoints;
  final int maxExperiencePoints;
  final double progressPercentage;
  final List<String> completedTopics;
  final List<String> completedActivities;
  final DateTime createdAt;
  final DateTime? updatedAt;

  StudentProgressModel({
    this.progressId,
    required this.studentId,
    this.subjectId,
    this.currentLevel = 1,
    this.maxLevel = 10,
    this.experiencePoints = 0,
    this.maxExperiencePoints = 100,
    this.progressPercentage = 0.0,
    this.completedTopics = const [],
    this.completedActivities = const [],
    required this.createdAt,
    this.updatedAt,
  });

  // Calculate progress percentage
  double getProgressPercentage() {
    return (experiencePoints / maxExperiencePoints).clamp(0.0, 1.0);
  }

  // Check if ready to level up
  bool isReadyToLevelUp() {
    return experiencePoints >= maxExperiencePoints && currentLevel < maxLevel;
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'subjectId': subjectId,
      'currentLevel': currentLevel,
      'maxLevel': maxLevel,
      'experiencePoints': experiencePoints,
      'maxExperiencePoints': maxExperiencePoints,
      'progressPercentage': getProgressPercentage(),
      'completedTopics': completedTopics,
      'completedActivities': completedActivities,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create from Firestore Document
  factory StudentProgressModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return StudentProgressModel(
      progressId: doc.id,
      studentId: data['studentId'] ?? '',
      subjectId: data['subjectId'],
      currentLevel: data['currentLevel'] ?? 1,
      maxLevel: data['maxLevel'] ?? 10,
      experiencePoints: data['experiencePoints'] ?? 0,
      maxExperiencePoints: data['maxExperiencePoints'] ?? 100,
      progressPercentage: (data['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      completedTopics: List<String>.from(data['completedTopics'] ?? []),
      completedActivities: List<String>.from(data['completedActivities'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Copy with method for updates
  StudentProgressModel copyWith({
    String? progressId,
    String? studentId,
    String? subjectId,
    int? currentLevel,
    int? maxLevel,
    int? experiencePoints,
    int? maxExperiencePoints,
    double? progressPercentage,
    List<String>? completedTopics,
    List<String>? completedActivities,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentProgressModel(
      progressId: progressId ?? this.progressId,
      studentId: studentId ?? this.studentId,
      subjectId: subjectId ?? this.subjectId,
      currentLevel: currentLevel ?? this.currentLevel,
      maxLevel: maxLevel ?? this.maxLevel,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      maxExperiencePoints: maxExperiencePoints ?? this.maxExperiencePoints,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      completedTopics: completedTopics ?? this.completedTopics,
      completedActivities: completedActivities ?? this.completedActivities,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AchievementModel {
  final String? achievementId;
  final String studentId;
  final String title;
  final String description;
  final String icon; // emoji atau URL
  final int points;
  final String category; // 'badge', 'sticker', 'certificate'
  final bool isUnlocked;
  final DateTime unlockedAt;

  AchievementModel({
    this.achievementId,
    required this.studentId,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    required this.category,
    required this.isUnlocked,
    required this.unlockedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'title': title,
      'description': description,
      'icon': icon,
      'points': points,
      'category': category,
      'isUnlocked': isUnlocked,
      'unlockedAt': Timestamp.fromDate(unlockedAt),
    };
  }

  // Create from Firestore Document
  factory AchievementModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return AchievementModel(
      achievementId: doc.id,
      studentId: data['studentId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? '🏆',
      points: data['points'] ?? 10,
      category: data['category'] ?? 'badge',
      isUnlocked: data['isUnlocked'] ?? false,
      unlockedAt: (data['unlockedAt'] as Timestamp).toDate(),
    );
  }

  // Copy with method for updates
  AchievementModel copyWith({
    String? achievementId,
    String? studentId,
    String? title,
    String? description,
    String? icon,
    int? points,
    String? category,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return AchievementModel(
      achievementId: achievementId ?? this.achievementId,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      points: points ?? this.points,
      category: category ?? this.category,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
