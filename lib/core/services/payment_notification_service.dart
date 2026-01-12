import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/class_repository.dart';
import '../../core/models/session_model.dart';
import '../../core/models/payment_model.dart';
import '../../core/models/class_model.dart';

class PaymentNotificationService {
  final SessionRepository _sessionRepository = SessionRepository();
  final PaymentRepository _paymentRepository = PaymentRepository();
  final ClassRepository _classRepository = ClassRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check if payment notification should be sent after 8 sessions
  /// This should be called after each session is completed
  Future<void> checkAndNotifyPayment(String studentId, String classId) async {
    try {
      // Get all sessions for this class
      final sessions = await _sessionRepository.getSessionsByClassId(classId);
      
      // Count completed sessions (where student was present)
      int completedSessions = 0;
      for (final session in sessions) {
        final attendance = session.attendance.firstWhere(
          (a) => a.studentId == studentId,
          orElse: () => Attendance(studentId: '', status: 'absent'),
        );
        if (attendance.status == 'present') {
          completedSessions++;
        }
      }

      // Check if we've reached exactly 8 sessions
      if (completedSessions == 8) {
        final existingPayment = await _checkExistingPayment(studentId, classId);
        
        if (existingPayment == null) {
          // Get class info for payment amount
          final classModel = await _classRepository.getClassById(classId);
          if (classModel != null) {
            // Create payment record
            await _createPaymentNotification(studentId, classId, classModel);
          }
        }
      }
    } catch (e) {
      print('Error checking payment notification: $e');
    }
  }

  /// Check if payment already exists for this milestone
  Future<PaymentModel?> _checkExistingPayment(
    String studentId,
    String classId,
  ) async {
    try {
      final payments = await _paymentRepository.getPaymentsByStudentId(studentId);
      
      // Check if there's a pending payment for this class with 8 sessions
      for (final payment in payments) {
        if (payment.classId == classId && 
            payment.status == 'pending' &&
            payment.sessionsPaid == 8) {
          return payment;
        }
      }
      return null;
    } catch (e) {
      print('Error checking existing payment: $e');
      return null;
    }
  }

  /// Create payment notification/record
  Future<void> _createPaymentNotification(
    String studentId,
    String classId,
    ClassModel classModel,
  ) async {
    try {
      // Calculate amount (8 sessions * price per session)
      final amount = 8 * classModel.pricePerSession;
      
      // Due date is 7 days from now
      final dueDate = DateTime.now().add(const Duration(days: 7));

      // Get parent ID from student
      final studentDoc = await _firestore.collection('students').doc(studentId).get();
      if (studentDoc.exists) {
        final parentId = studentDoc.data()?['parentId'];
        if (parentId != null) {
          final payment = PaymentModel(
            studentId: studentId,
            parentId: parentId,
            classId: classId,
            amount: amount,
            status: 'pending',
            sessionsPaid: 8,
            dueDate: dueDate,
            notificationSent: false,
          );

          await _paymentRepository.createPayment(payment);
          
          // You can also send push notification here using Firebase Cloud Messaging
          // For now, we'll just create the payment record
          print('Payment notification created for student $studentId after 8 sessions');
        }
      }
    } catch (e) {
      print('Error creating payment notification: $e');
    }
  }

  /// Check all students and send notifications if needed
  /// This can be called periodically or after batch session creation
  Future<void> checkAllStudentsForPayment() async {
    try {
      // Get all classes
      final classesSnapshot = await _firestore.collection('classes').get();
      
      for (final classDoc in classesSnapshot.docs) {
        final classId = classDoc.id;
        final classData = classDoc.data();
        final studentIds = (classData['studentIds'] as List<dynamic>?)?.cast<String>() ?? [];
        
        for (final studentId in studentIds) {
          await checkAndNotifyPayment(studentId, classId);
        }
      }
    } catch (e) {
      print('Error checking all students for payment: $e');
    }
  }
}
