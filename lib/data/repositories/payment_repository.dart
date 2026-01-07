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
}