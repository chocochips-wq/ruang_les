import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/progress_note_model.dart';

class ProgressNoteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'progress_notes';

  Future<String> createProgressNote(ProgressNoteModel note) async {
    try {
      final docRef = await _firestore.collection(collectionName).add(
        note.toMap(),
      );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create progress note: $e');
    }
  }

  Future<ProgressNoteModel?> getProgressNoteById(String noteId) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(noteId).get();
      if (doc.exists) {
        return ProgressNoteModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get progress note by ID: $e');
    }
  }

  Future<List<ProgressNoteModel>> getProgressNotesBySessionId(
    String sessionId,
  ) async {
    try {
      final query = await _firestore
          .collection(collectionName)
          .where('sessionId', isEqualTo: sessionId)
          .orderBy('createdAt', descending: false)
          .get();

      return query.docs
          .map((doc) => ProgressNoteModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get progress notes by session ID: $e');
    }
  }

  Future<List<ProgressNoteModel>> getProgressNotesByStudentId(
    String studentId,
  ) async {
    try {
      final query = await _firestore
          .collection(collectionName)
          .where('studentId', isEqualTo: studentId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => ProgressNoteModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get progress notes by student ID: $e');
    }
  }

  Future<ProgressNoteModel?> getProgressNoteBySessionAndStudent(
    String sessionId,
    String studentId,
  ) async {
    try {
      final query = await _firestore
          .collection(collectionName)
          .where('sessionId', isEqualTo: sessionId)
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return ProgressNoteModel.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception(
          'Failed to get progress note by session and student: $e');
    }
  }

  Future<void> updateProgressNote(
    String noteId,
    ProgressNoteModel note,
  ) async {
    try {
      final updatedNote = note.copyWith(
        updatedAt: DateTime.now(),
      );
      await _firestore.collection(collectionName).doc(noteId).update(
        updatedNote.toMap(),
      );
    } catch (e) {
      throw Exception('Failed to update progress note: $e');
    }
  }

  Future<void> deleteProgressNote(String noteId) async {
    try {
      await _firestore.collection(collectionName).doc(noteId).delete();
    } catch (e) {
      throw Exception('Failed to delete progress note: $e');
    }
  }

  Stream<List<ProgressNoteModel>> streamProgressNotesBySessionId(
    String sessionId,
  ) {
    return _firestore
        .collection(collectionName)
        .where('sessionId', isEqualTo: sessionId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProgressNoteModel.fromFirestore(doc))
            .toList());
  }
}
