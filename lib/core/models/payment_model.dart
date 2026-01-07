import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String? paymentId;
  final String studentId;
  final String parentId;
  final String classId;
  final int amount;
  final String status; // 'pending', 'paid', 'overdue'
  final int sessionsPaid;
  final DateTime dueDate;
  final DateTime? paidAt;
  final bool notificationSent;

  PaymentModel({
    this.paymentId,
    required this.studentId,
    required this.parentId,
    required this.classId,
    required this.amount,
    this.status = 'pending',
    this.sessionsPaid = 0,
    required this.dueDate,
    this.paidAt,
    this.notificationSent = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'parentId': parentId,
      'classId': classId,
      'amount': amount,
      'status': status,
      'sessionsPaid': sessionsPaid,
      'dueDate': Timestamp.fromDate(dueDate),
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'notificationSent': notificationSent,
    };
  }

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentModel(
      paymentId: doc.id,
      studentId: data['studentId'] ?? '',
      parentId: data['parentId'] ?? '',
      classId: data['classId'] ?? '',
      amount: data['amount'] ?? 0,
      status: data['status'] ?? 'pending',
      sessionsPaid: data['sessionsPaid'] ?? 0,
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      paidAt: data['paidAt'] != null
          ? (data['paidAt'] as Timestamp).toDate()
          : null,
      notificationSent: data['notificationSent'] ?? false,
    );
  }

  PaymentModel copyWith({
    String? paymentId,
    String? studentId,
    String? parentId,
    String? classId,
    int? amount,
    String? status,
    int? sessionsPaid,
    DateTime? dueDate,
    DateTime? paidAt,
    bool? notificationSent,
  }) {
    return PaymentModel(
      paymentId: paymentId ?? this.paymentId,
      studentId: studentId ?? this.studentId,
      parentId: parentId ?? this.parentId,
      classId: classId ?? this.classId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      sessionsPaid: sessionsPaid ?? this.sessionsPaid,
      dueDate: dueDate ?? this.dueDate,
      paidAt: paidAt ?? this.paidAt,
      notificationSent: notificationSent ?? this.notificationSent,
    );
  }
}
