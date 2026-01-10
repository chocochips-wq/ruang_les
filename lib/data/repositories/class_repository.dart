import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/class_model.dart';

class ClassRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'classes';

  Future<String> createClass(ClassModel classModel) async {
    try {
      final docRef = await _firestore.collection(collectionName).add(
            classModel.toMap(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create class: $e');
    }
  }

  Future<ClassModel?> getClassById(String classId) async {
    try {
      final doc =
          await _firestore.collection(collectionName).doc(classId).get();
      if (doc.exists) {
        return ClassModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get class: $e');
    }
  }

  Future<List<ClassModel>> getClassesByTeacherId(String teacherId) async {
    try {
      final query = await _firestore
          .collection(collectionName)
          .where('teacherId', isEqualTo: teacherId)
          .get();

      return query.docs.map((doc) => ClassModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get classes by teacher ID: $e');
    }
  }

  Future<List<ClassModel>> getClassesByStudentId(String studentId) async {
    try {
      final query = await _firestore
          .collection(collectionName)
          .where('studentIds', arrayContains: studentId)
          .get();

      return query.docs.map((doc) => ClassModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get classes by student ID: $e');
    }
  }

  Future<void> addStudentToClass(String classId, String studentId) async {
    try {
      await _firestore.collection(collectionName).doc(classId).update({
        'studentIds': FieldValue.arrayUnion([studentId]),
      });
    } catch (e) {
      throw Exception('Failed to add student to class: $e');
    }
  }

  Future<void> removeStudentFromClass(String classId, String studentId) async {
    try {
      await _firestore.collection(collectionName).doc(classId).update({
        'studentIds': FieldValue.arrayRemove([studentId]),
      });
    } catch (e) {
      throw Exception('Failed to remove student from class: $e');
    }
  }

  Future<void> updateClass(String classId, ClassModel classModel) async {
    try {
      await _firestore.collection(collectionName).doc(classId).update(
            classModel.toMap(),
          );
    } catch (e) {
      throw Exception('Failed to update class: $e');
    }
  }

  Stream<List<ClassModel>> streamClassesByTeacherId(String teacherId) {
    return _firestore
        .collection(collectionName)
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ClassModel.fromFirestore(doc)).toList());
  }

  Stream<List<ClassModel>> streamClassesByStudentId(String studentId) {
    return _firestore
        .collection(collectionName)
        .where('studentIds', arrayContains: studentId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ClassModel.fromFirestore(doc)).toList());
  }
}
