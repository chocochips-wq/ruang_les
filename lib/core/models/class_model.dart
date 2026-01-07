import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel {
  final String? classId;
  final String className;
  final String gradeLevel; // 'TK', 'SD 1-3', 'SD 4-6', 'SMP'
  final String type; // 'regular', 'semi_private', 'private'
  final String teacherId;
  final List<String> studentIds;
  final int maxStudents;
  final int pricePerSession;
  final int totalSessions;
  final String schedule; // 'Senin 15:00-16:00'
  final DateTime createdAt;

  ClassModel({
    this.classId,
    required this.className,
    required this.gradeLevel,
    required this.type,
    required this.teacherId,
    this.studentIds = const [],
    required this.maxStudents,
    required this.pricePerSession,
    required this.totalSessions,
    required this.schedule,
    required this.createdAt,
  });

  int get totalPrice => pricePerSession * totalSessions;

  Map<String, dynamic> toMap() {
    return {
      'className': className,
      'gradeLevel': gradeLevel,
      'type': type,
      'teacherId': teacherId,
      'studentIds': studentIds,
      'maxStudents': maxStudents,
      'pricePerSession': pricePerSession,
      'totalSessions': totalSessions,
      'schedule': schedule,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ClassModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClassModel(
      classId: doc.id,
      className: data['className'] ?? '',
      gradeLevel: data['gradeLevel'] ?? 'SD 1-3',
      type: data['type'] ?? 'regular',
      teacherId: data['teacherId'] ?? '',
      studentIds: List<String>.from(data['studentIds'] ?? []),
      maxStudents: data['maxStudents'] ?? 6,
      pricePerSession: data['pricePerSession'] ?? 15000,
      totalSessions: data['totalSessions'] ?? 8,
      schedule: data['schedule'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}