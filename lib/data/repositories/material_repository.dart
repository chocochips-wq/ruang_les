import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/material_model.dart';
import '../../core/utils/constants.dart';

class MaterialRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'materials';

  Future<String> createMaterial(MaterialModel material) async {
    try {
      final docRef = await _firestore.collection(collectionName).add(
        material.toMap(),
      );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create material: $e');
    }
  }

  Future<MaterialModel?> getMaterialById(String materialId) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(materialId).get();
      if (doc.exists) {
        return MaterialModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get material by ID: $e');
    }
  }

  Future<List<MaterialModel>> getMaterialsByTeacherId(String teacherId) async {
    try {
      final query = await _firestore
          .collection(collectionName)
          .where('teacherId', isEqualTo: teacherId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => MaterialModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get materials by teacher ID: $e');
    }
  }

  Future<List<MaterialModel>> getMaterialsBySubject(String subject) async {
    try {
      final query = await _firestore
          .collection(collectionName)
          .where('subject', isEqualTo: subject)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => MaterialModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get materials by subject: $e');
    }
  }

  Future<List<MaterialModel>> getMaterialsByTeacherAndSubject(
    String teacherId,
    String subject,
  ) async {
    try {
      final query = await _firestore
          .collection(collectionName)
          .where('teacherId', isEqualTo: teacherId)
          .where('subject', isEqualTo: subject)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => MaterialModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get materials by teacher and subject: $e');
    }
  }

  Future<void> updateMaterial(String materialId, MaterialModel material) async {
    try {
      final updatedMaterial = material.copyWith(
        updatedAt: DateTime.now(),
      );
      await _firestore.collection(collectionName).doc(materialId).update(
        updatedMaterial.toMap(),
      );
    } catch (e) {
      throw Exception('Failed to update material: $e');
    }
  }

  Future<void> deleteMaterial(String materialId) async {
    try {
      await _firestore.collection(collectionName).doc(materialId).delete();
    } catch (e) {
      throw Exception('Failed to delete material: $e');
    }
  }

  Stream<List<MaterialModel>> streamMaterialsByTeacherId(String teacherId) {
    return _firestore
        .collection(collectionName)
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MaterialModel.fromFirestore(doc))
            .toList());
  }
}
