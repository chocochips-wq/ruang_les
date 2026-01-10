import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? userId;
  final String email;
  final String name;
  final String role; // 'student', 'parent', 'teacher', 'admin'
  final String phone;
  final String? photoUrl;
  final String verificationStatus; // 'pending', 'verified', 'rejected'
  final DateTime createdAt;
  final DateTime? verifiedAt;
  final String? verifiedBy; // userId of teacher/admin who verified

  UserModel({
    this.userId,
    required this.email,
    required this.name,
    required this.role,
    required this.phone,
    this.photoUrl,
    this.verificationStatus = 'pending', // Default pending for student/parent
    this.verifiedAt,
    this.verifiedBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'photoUrl': photoUrl,
      'verificationStatus': verificationStatus,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'verifiedBy': verifiedBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final role = data['role'] ?? 'student';
    
    // For old accounts without verificationStatus:
    // - Teacher: default to 'verified' (teachers don't need verification)
    // - Student/Parent: default to 'pending' (need verification)
    String defaultVerificationStatus;
    if (role == 'teacher' || role == 'pengajar') {
      defaultVerificationStatus = 'verified';
    } else {
      defaultVerificationStatus = 'pending';
    }
    
    return UserModel(
      userId: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: role,
      phone: data['phone'] ?? '',
      photoUrl: data['photoUrl'],
      verificationStatus: data['verificationStatus'] ?? defaultVerificationStatus,
      verifiedAt: data['verifiedAt'] != null
          ? (data['verifiedAt'] as Timestamp).toDate()
          : null,
      verifiedBy: data['verifiedBy'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  UserModel copyWith({
    String? userId,
    String? email,
    String? name,
    String? role,
    String? phone,
    String? photoUrl,
    String? verificationStatus,
    DateTime? verifiedAt,
    String? verifiedBy,
    DateTime? createdAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}