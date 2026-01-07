import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  final String studentId;
  final String status; // 'present', 'absent', 'excused'
  final String? reason;

  Attendance({
    required this.studentId,
    required this.status,
    this.reason,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'status': status,
      'reason': reason,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> data) {
    return Attendance(
      studentId: data['studentId'] ?? '',
      status: data['status'] ?? 'absent',
      reason: data['reason'],
    );
  }
}

class SessionModel {
  final String? sessionId;
  final String classId;
  final int sessionNumber;
  final DateTime date;
  final String material;
  final String? teacherNotes;
  final List<Attendance> attendance;
  final DateTime createdAt;

  SessionModel({
    this.sessionId,
    required this.classId,
    required this.sessionNumber,
    required this.date,
    required this.material,
    this.teacherNotes,
    this.attendance = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'sessionNumber': sessionNumber,
      'date': Timestamp.fromDate(date),
      'material': material,
      'teacherNotes': teacherNotes,
      'attendance': attendance.map((a) => a.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SessionModel(
      sessionId: doc.id,
      classId: data['classId'] ?? '',
      sessionNumber: data['sessionNumber'] ?? 1,
      date: (data['date'] as Timestamp).toDate(),
      material: data['material'] ?? '',
      teacherNotes: data['teacherNotes'],
      attendance: (data['attendance'] as List? ?? [])
          .map((a) => Attendance.fromMap(a))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  SessionModel copyWith({
    String? sessionId,
    String? classId,
    int? sessionNumber,
    DateTime? date,
    String? material,
    String? teacherNotes,
    List<Attendance>? attendance,
    DateTime? createdAt,
  }) {
    return SessionModel(
      sessionId: sessionId ?? this.sessionId,
      classId: classId ?? this.classId,
      sessionNumber: sessionNumber ?? this.sessionNumber,
      date: date ?? this.date,
      material: material ?? this.material,
      teacherNotes: teacherNotes ?? this.teacherNotes,
      attendance: attendance ?? this.attendance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
