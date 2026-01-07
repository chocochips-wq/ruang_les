import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/parent_model.dart';

class ParentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'parents';

  Future<String> createParent(ParentModel parent) async {
    try {
      final docRef = await _firestore.collection(collectionName).add(
        parent.toMap(),
      );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create parent: $e');
    }
  }

  Future<ParentModel?> getParentById(String parentId) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(parentId).get();
      if (doc.exists) {
        return ParentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get parent: $e');
    }
  }

  Future<ParentModel?> getParentByUserId(String userId) async {
    try {
      final query = await _firestore
          .collection(collectionName)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return ParentModel.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get parent by user ID: $e');
    }
  }

  Future<void> updateParent(String parentId, ParentModel parent) async {
    try {
      await _firestore.collection(collectionName).doc(parentId).update(
        parent.toMap(),
      );
    } catch (e) {
      throw Exception('Failed to update parent: $e');
    }
  }

  Stream<ParentModel?> streamParent(String parentId) {
    return _firestore
        .collection(collectionName)
        .doc(parentId)
        .snapshots()
        .map((doc) => doc.exists ? ParentModel.fromFirestore(doc) : null);
  }
}