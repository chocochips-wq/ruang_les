import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/student_model.dart';

class StudentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'students';

  // Create new student
  Future<String> createStudent(StudentModel student) async {
    try {
      final docRef = await _firestore.collection(collectionName).add(
            student.toMap(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create student: $e');
    }
  }

  // Get student by ID
  Future<StudentModel?> getStudentById(String studentId) async {
    try {
      final doc =
          await _firestore.collection(collectionName).doc(studentId).get();
      if (doc.exists) {
        return StudentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get student: $e');
    }
  }

  // Get student by User ID
  Future<StudentModel?> getStudentByUserId(String userId) async {
    try {
      final query = await _firestore
          .collection(collectionName)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return StudentModel.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get student by user ID: $e');
    }
  }

  // Get students by parent ID
  Future<List<StudentModel>> getStudentsByParentId(String parentId) async {
    try {
      final query = await _firestore
          .collection(collectionName)
          .where('parentId', isEqualTo: parentId)
          .get();

      return query.docs.map((doc) => StudentModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get students by parent ID: $e');
    }
  }

  // Update student
  Future<void> updateStudent(String studentId, StudentModel student) async {
    try {
      await _firestore.collection(collectionName).doc(studentId).update({
        ...student.toMap(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update student: $e');
    }
  }

  // Add points to student
  Future<void> addPoints(String studentId, int points) async {
    try {
      await _firestore.collection(collectionName).doc(studentId).update({
        'totalPoints': FieldValue.increment(points),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to add points: $e');
    }
  }

  // Add badge to student
  Future<void> addBadge(String studentId, String badge) async {
    try {
      await _firestore.collection(collectionName).doc(studentId).update({
        'badges': FieldValue.arrayUnion([badge]),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to add badge: $e');
    }
  }

  // Delete student
  Future<void> deleteStudent(String studentId) async {
    try {
      await _firestore.collection(collectionName).doc(studentId).delete();
    } catch (e) {
      throw Exception('Failed to delete student: $e');
    }
  }

  // Stream for real-time updates
  Stream<StudentModel?> streamStudent(String studentId) {
    return _firestore
        .collection(collectionName)
        .doc(studentId)
        .snapshots()
        .map((doc) => doc.exists ? StudentModel.fromFirestore(doc) : null);
  }

  // Stream all students (for teacher/admin)
  Stream<List<StudentModel>> streamAllStudents() {
    return _firestore.collection(collectionName).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => StudentModel.fromFirestore(doc)).toList());
  }

  // Stream students by parent ID (for real-time updates)
  Stream<List<StudentModel>> streamStudentsByParentId(String parentId) {
    return _firestore
        .collection(collectionName)
        .where('parentId', isEqualTo: parentId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => StudentModel.fromFirestore(doc)).toList());
  }
}
