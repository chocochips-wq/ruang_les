import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherModel {
  final String? teacherId;
  final String userId;
  final List<String> classIds;
  final String specialization; // 'TK', 'SD', 'SMP', 'Umum'
  final String? educationBackground;
  final int yearsOfExperience;
  final DateTime createdAt;

  TeacherModel({
    this.teacherId,
    required this.userId,
    this.classIds = const [],
    required this.specialization,
    this.educationBackground,
    this.yearsOfExperience = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'classIds': classIds,
      'specialization': specialization,
      'educationBackground': educationBackground,
      'yearsOfExperience': yearsOfExperience,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TeacherModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TeacherModel(
      teacherId: doc.id,
      userId: data['userId'] ?? '',
      classIds: List<String>.from(data['classIds'] ?? []),
      specialization: data['specialization'] ?? 'Umum',
      educationBackground: data['educationBackground'],
      yearsOfExperience: data['yearsOfExperience'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  TeacherModel copyWith({
    String? teacherId,
    String? userId,
    List<String>? classIds,
    String? specialization,
    String? educationBackground,
    int? yearsOfExperience,
    DateTime? createdAt,
  }) {
    return TeacherModel(
      teacherId: teacherId ?? this.teacherId,
      userId: userId ?? this.userId,
      classIds: classIds ?? this.classIds,
      specialization: specialization ?? this.specialization,
      educationBackground: educationBackground ?? this.educationBackground,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
