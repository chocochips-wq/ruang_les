import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/teacher_model.dart';

class TeacherRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'teachers';

  Future<String> createTeacher(TeacherModel teacher) async {
    try {
      final docRef = await _firestore.collection(collectionName).add(
        teacher.toMap(),
      );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create teacher: $e');
    }
  }

  Future<TeacherModel?> getTeacherById(String teacherId) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(teacherId).get();
      if (doc.exists) {
        return TeacherModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get teacher: $e');
    }
  }

  Future<TeacherModel?> getTeacherByUserId(String userId) async {
    try {
      final query = await _firestore
          .collection(collectionName)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return TeacherModel.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get teacher by user ID: $e');
    }
  }

  Future<void> updateTeacher(String teacherId, TeacherModel teacher) async {
    try {
      await _firestore.collection(collectionName).doc(teacherId).update(
        teacher.toMap(),
      );
    } catch (e) {
      throw Exception('Failed to update teacher: $e');
    }
  }

  Stream<TeacherModel?> streamTeacher(String teacherId) {
    return _firestore
        .collection(collectionName)
        .doc(teacherId)
        .snapshots()
        .map((doc) => doc.exists ? TeacherModel.fromFirestore(doc) : null);
  }
}