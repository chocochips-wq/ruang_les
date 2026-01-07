import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? userId;
  final String email;
  final String name;
  final String role; // 'student', 'parent', 'teacher', 'admin'
  final String phone;
  final String? photoUrl;
  final DateTime createdAt;

  UserModel({
    this.userId,
    required this.email,
    required this.name,
    required this.role,
    required this.phone,
    this.photoUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      userId: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'student',
      phone: data['phone'] ?? '',
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}