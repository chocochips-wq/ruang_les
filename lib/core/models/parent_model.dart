import 'package:cloud_firestore/cloud_firestore.dart';

class ParentModel {
  final String? parentId;
  final String userId;
  final List<String> studentIds;
  final String address;
  final String? occupation;
  final DateTime createdAt;

  ParentModel({
    this.parentId,
    required this.userId,
    this.studentIds = const [],
    required this.address,
    this.occupation,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'studentIds': studentIds,
      'address': address,
      'occupation': occupation,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ParentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ParentModel(
      parentId: doc.id,
      userId: data['userId'] ?? '',
      studentIds: List<String>.from(data['studentIds'] ?? []),
      address: data['address'] ?? '',
      occupation: data['occupation'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  ParentModel copyWith({
    String? parentId,
    String? userId,
    List<String>? studentIds,
    String? address,
    String? occupation,
    DateTime? createdAt,
  }) {
    return ParentModel(
      parentId: parentId ?? this.parentId,
      userId: userId ?? this.userId,
      studentIds: studentIds ?? this.studentIds,
      address: address ?? this.address,
      occupation: occupation ?? this.occupation,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
