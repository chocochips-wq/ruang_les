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

  ClassModel copyWith({
    String? classId,
    String? className,
    String? gradeLevel,
    String? type,
    String? teacherId,
    List<String>? studentIds,
    int? maxStudents,
    int? pricePerSession,
    int? totalSessions,
    String? schedule,
    DateTime? createdAt,
  }) {
    return ClassModel(
      classId: classId ?? this.classId,
      className: className ?? this.className,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      type: type ?? this.type,
      teacherId: teacherId ?? this.teacherId,
      studentIds: studentIds ?? this.studentIds,
      maxStudents: maxStudents ?? this.maxStudents,
      pricePerSession: pricePerSession ?? this.pricePerSession,
      totalSessions: totalSessions ?? this.totalSessions,
      schedule: schedule ?? this.schedule,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      classId: json['classId'],
      className: json['className'] ?? '',
      gradeLevel: json['gradeLevel'] ?? 'SD 1-3',
      type: json['type'] ?? 'regular',
      teacherId: json['teacherId'] ?? '',
      studentIds: List<String>.from(json['studentIds'] ?? []),
      maxStudents: json['maxStudents'] ?? 6,
      pricePerSession: json['pricePerSession'] ?? 15000,
      totalSessions: json['totalSessions'] ?? 8,
      schedule: json['schedule'] ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
