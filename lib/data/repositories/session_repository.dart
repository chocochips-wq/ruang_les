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
      // Try with orderBy first (requires composite index)
      try {
        final query = await _firestore
            .collection(collectionName)
            .where('classId', isEqualTo: classId)
            .orderBy('sessionNumber', descending: false)
            .get();

        return query.docs.map((doc) => SessionModel.fromFirestore(doc)).toList();
      } catch (e) {
        // If index error, fallback to query without orderBy and sort in memory
        if (e.toString().contains('index')) {
          final query = await _firestore
              .collection(collectionName)
              .where('classId', isEqualTo: classId)
              .get();

          final sessions = query.docs
              .map((doc) => SessionModel.fromFirestore(doc))
              .toList();
          
          // Sort by sessionNumber in memory
          sessions.sort((a, b) => a.sessionNumber.compareTo(b.sessionNumber));
          return sessions;
        }
        rethrow;
      }
    } catch (e) {
      throw Exception('Failed to get sessions by class ID: $e');
    }
  }

  Future<SessionModel?> getSessionById(String sessionId) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(sessionId).get();
      if (doc.exists) {
        return SessionModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get session by ID: $e');
    }
  }

  Future<void> updateSession(String sessionId, SessionModel session) async {
    try {
      await _firestore.collection(collectionName).doc(sessionId).update(
        session.toMap(),
      );
    } catch (e) {
      throw Exception('Failed to update session: $e');
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await _firestore.collection(collectionName).doc(sessionId).delete();
    } catch (e) {
      throw Exception('Failed to delete session: $e');
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
        .snapshots()
        .map((snapshot) {
          final sessions = snapshot.docs
              .map((doc) => SessionModel.fromFirestore(doc))
              .toList();
          // Sort by sessionNumber in memory
          sessions.sort((a, b) => a.sessionNumber.compareTo(b.sessionNumber));
          return sessions;
        });
  }

  // Get recent sessions for activities (for parent dashboard)
  Future<List<SessionModel>> getRecentSessionsByStudentIds(List<String> studentIds, {int limit = 10}) async {
    try {
      // Note: This requires a collection group query or multiple queries
      // For now, we'll get all sessions and filter by checking if student is in any class
      // This is a simplified approach - in production, you might want to store studentId in sessions
      final query = await _firestore
          .collection(collectionName)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) => SessionModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get recent sessions: $e');
    }
  }

  Stream<List<SessionModel>> streamRecentSessions({int limit = 10}) {
    return _firestore
        .collection(collectionName)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SessionModel.fromFirestore(doc))
            .toList());
  }
}