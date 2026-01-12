import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/payment_model.dart';

class PaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'payments';

  Future<String> createPayment(PaymentModel payment) async {
    try {
      final docRef = await _firestore.collection(collectionName).add(
        payment.toMap(),
      );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  Future<List<PaymentModel>> getPaymentsByParentId(String parentId) async {
    try {
      final query = await _firestore
          .collection(collectionName)
          .where('parentId', isEqualTo: parentId)
          .orderBy('dueDate', descending: false)
          .get();

      return query.docs.map((doc) => PaymentModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get payments by parent ID: $e');
    }
  }

  Future<List<PaymentModel>> getPaymentsByStudentId(String studentId) async {
    try {
      final query = await _firestore
          .collection(collectionName)
          .where('studentId', isEqualTo: studentId)
          .orderBy('dueDate', descending: false)
          .get();

      return query.docs.map((doc) => PaymentModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get payments by student ID: $e');
    }
  }

  Future<void> updatePaymentStatus(String paymentId, String status) async {
    try {
      await _firestore.collection(collectionName).doc(paymentId).update({
        'status': status,
        'paidAt': status == 'paid' ? Timestamp.now() : null,
      });
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  Stream<List<PaymentModel>> streamPaymentsByParentId(String parentId) {
    return _firestore
        .collection(collectionName)
        .where('parentId', isEqualTo: parentId)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentModel.fromFirestore(doc))
            .toList());
  }

  // ===== ADDITIONAL METHODS FOR OPTION A FLOW =====

  Future<List<PaymentModel>> getPaymentsByTeacherId(String teacherId) async {
    try {
      final query = await _firestore
          .collection(collectionName)
          .where('teacherId', isEqualTo: teacherId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => PaymentModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get payments by teacher: $e');
    }
  }

  Stream<List<PaymentModel>> streamPaymentsByTeacherId(String teacherId) {
    return _firestore
        .collection(collectionName)
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentModel.fromFirestore(doc))
            .toList());
  }

  Future<PaymentModel?> getPaymentById(String paymentId) async {
    try {
      final doc =
          await _firestore.collection(collectionName).doc(paymentId).get();
      if (doc.exists) {
        return PaymentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get payment: $e');
    }
  }

  Future<void> updatePayment(String paymentId,
      {int? amount,
      String? description,
      DateTime? dueDate,
      String? notes}) async {
    try {
      final updateData = <String, dynamic>{};
      if (amount != null) updateData['amount'] = amount;
      if (description != null) updateData['description'] = description;
      if (dueDate != null) updateData['dueDate'] = Timestamp.fromDate(dueDate);
      if (notes != null) updateData['notes'] = notes;
      updateData['updatedAt'] = Timestamp.now();

      if (updateData.isNotEmpty) {
        await _firestore
            .collection(collectionName)
            .doc(paymentId)
            .update(updateData);
      }
    } catch (e) {
      throw Exception('Failed to update payment: $e');
    }
  }

  Future<void> deletePayment(String paymentId) async {
    try {
      await _firestore.collection(collectionName).doc(paymentId).delete();
    } catch (e) {
      throw Exception('Failed to delete payment: $e');
    }
  }

  Future<List<PaymentModel>> getPaymentsByStatus(String status) async {
    try {
      final query = await _firestore
          .collection(collectionName)
          .where('status', isEqualTo: status)
          .orderBy('dueDate', descending: true)
          .get();

      return query.docs.map((doc) => PaymentModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get payments by status: $e');
    }
  }

  Stream<List<PaymentModel>> streamPaymentsByStatus(String status) {
    return _firestore
        .collection(collectionName)
        .where('status', isEqualTo: status)
        .orderBy('dueDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentModel.fromFirestore(doc))
            .toList());
  }
}