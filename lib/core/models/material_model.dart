import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialModel {
  final String? materialId;
  final String teacherId;
  final String subject; // 'Matematika', 'IPA', etc
  final String title;
  final String description;
  final String gradeLevel;
  final String? fileUrl;
  final String? fileName;
  final String? fileType; // 'pdf', 'doc', 'ppt', etc
  final int fileSize; // in bytes
  final DateTime createdAt;
  final DateTime? updatedAt;

  MaterialModel({
    this.materialId,
    required this.teacherId,
    required this.subject,
    required this.title,
    required this.description,
    required this.gradeLevel,
    this.fileUrl,
    this.fileName,
    this.fileType,
    this.fileSize = 0,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'teacherId': teacherId,
      'subject': subject,
      'title': title,
      'description': description,
      'gradeLevel': gradeLevel,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileType': fileType,
      'fileSize': fileSize,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory MaterialModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MaterialModel(
      materialId: doc.id,
      teacherId: data['teacherId'] ?? '',
      subject: data['subject'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      gradeLevel: data['gradeLevel'] ?? '',
      fileUrl: data['fileUrl'],
      fileName: data['fileName'],
      fileType: data['fileType'],
      fileSize: data['fileSize'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  MaterialModel copyWith({
    String? materialId,
    String? teacherId,
    String? subject,
    String? title,
    String? description,
    String? gradeLevel,
    String? fileUrl,
    String? fileName,
    String? fileType,
    int? fileSize,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaterialModel(
      materialId: materialId ?? this.materialId,
      teacherId: teacherId ?? this.teacherId,
      subject: subject ?? this.subject,
      title: title ?? this.title,
      description: description ?? this.description,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
