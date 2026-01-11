import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressNoteModel {
  final String? noteId;
  final String sessionId;
  final String studentId;
  final String classId;
  final String note; // Catatan perkembangan
  final String? attachmentUrl; // URL untuk file/gambar yang diunggah
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProgressNoteModel({
    this.noteId,
    required this.sessionId,
    required this.studentId,
    required this.classId,
    required this.note,
    this.attachmentUrl,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'studentId': studentId,
      'classId': classId,
      'note': note,
      'attachmentUrl': attachmentUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory ProgressNoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgressNoteModel(
      noteId: doc.id,
      sessionId: data['sessionId'] ?? '',
      studentId: data['studentId'] ?? '',
      classId: data['classId'] ?? '',
      note: data['note'] ?? '',
      attachmentUrl: data['attachmentUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  ProgressNoteModel copyWith({
    String? noteId,
    String? sessionId,
    String? studentId,
    String? classId,
    String? note,
    String? attachmentUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProgressNoteModel(
      noteId: noteId ?? this.noteId,
      sessionId: sessionId ?? this.sessionId,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      note: note ?? this.note,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
