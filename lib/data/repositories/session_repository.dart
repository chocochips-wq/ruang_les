import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/session_model.dart';

class SessionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'sessions';

  Future<String> createSession(SessionModel session) async {
    try {
      final docRef = await _firestore.collection(collectionName).add(
        session.toMap(),
      );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create session: $e');
    }
  }

  Future<List<SessionModel>> getSessionsByClassId(String classId) async {
    try {
      final query = await _firestore
          .collection(collectionName)
          .where('classId', isEqualTo: classId)
          .orderBy('sessionNumber', descending: false)
          .get();

      return query.docs.map((doc) => SessionModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get sessions by class ID: $e');
    }
  }

  Future<void> updateAttendance(
    String sessionId,
    List<Attendance> attendance,
  ) async {
    try {
      await _firestore.collection(collectionName).doc(sessionId).update({
        'attendance': attendance.map((a) => a.toMap()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to update attendance: $e');
    }
  }

  Stream<List<SessionModel>> streamSessionsByClassId(String classId) {
    return _firestore
        .collection(collectionName)
        .where('classId', isEqualTo: classId)
        .orderBy('sessionNumber', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SessionModel.fromFirestore(doc))
            .toList());
  }
}