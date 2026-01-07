import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String? studentId;
  final String userId;
  final String? parentId;
  final String nickname;
  final String fullName;
  final String gradeLevel; // 'TK', 'SD 1-3', 'SD 4-6', 'SMP'
  final String? avatarUrl;
  final int learningLevel;
  final int totalPoints;
  final List<String> badges;
  final DateTime createdAt;
  final DateTime? updatedAt;

  StudentModel({
    this.studentId,
    required this.userId,
    this.parentId,
    required this.nickname,
    required this.fullName,
    required this.gradeLevel,
    this.avatarUrl,
    this.learningLevel = 1,
    this.totalPoints = 0,
    this.badges = const [],
    required this.createdAt,
    this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'parentId': parentId,
      'nickname': nickname,
      'fullName': fullName,
      'gradeLevel': gradeLevel,
      'avatarUrl': avatarUrl,
      'learningLevel': learningLevel,
      'totalPoints': totalPoints,
      'badges': badges,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create from Firestore Document
  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return StudentModel(
      studentId: doc.id,
      userId: data['userId'] ?? '',
      parentId: data['parentId'],
      nickname: data['nickname'] ?? '',
      fullName: data['fullName'] ?? '',
      gradeLevel: data['gradeLevel'] ?? 'SD 1-3',
      avatarUrl: data['avatarUrl'],
      learningLevel: data['learningLevel'] ?? 1,
      totalPoints: data['totalPoints'] ?? 0,
      badges: List<String>.from(data['badges'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Copy with method for updates
  StudentModel copyWith({
    String? studentId,
    String? userId,
    String? parentId,
    String? nickname,
    String? fullName,
    String? gradeLevel,
    String? avatarUrl,
    int? learningLevel,
    int? totalPoints,
    List<String>? badges,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentModel(
      studentId: studentId ?? this.studentId,
      userId: userId ?? this.userId,
      parentId: parentId ?? this.parentId,
      nickname: nickname ?? this.nickname,
      fullName: fullName ?? this.fullName,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      learningLevel: learningLevel ?? this.learningLevel,
      totalPoints: totalPoints ?? this.totalPoints,
      badges: badges ?? this.badges,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
