import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initialize collections with sample data
  Future<void> initializeCollections() async {
    try {
      // Check if collections already have data
      final studentsSnapshot = await _firestore.collection('students').limit(1).get();
      
      if (studentsSnapshot.docs.isEmpty) {
        await _createSampleStudents();
      }

      print('Firestore collections initialized successfully');
    } catch (e) {
      print('Error initializing Firestore: $e');
    }
  }

  Future<void> _createSampleStudents() async {
    final sampleStudents = [
      {
        'userId': 'sample_user_1',
        'nickname': 'Budi',
        'fullName': 'Budi Santoso',
        'gradeLevel': 'SD 1-3',
        'learningLevel': 1,
        'totalPoints': 150,
        'badges': ['Pembaca Cepat', 'Matematika Dasar'],
        'createdAt': Timestamp.now(),
      },
      {
        'userId': 'sample_user_2',
        'nickname': 'Sari',
        'fullName': 'Sari Wijaya',
        'gradeLevel': 'SD 4-6',
        'learningLevel': 3,
        'totalPoints': 300,
        'badges': ['Sains Explorer', 'Bahasa Inggris Dasar'],
        'createdAt': Timestamp.now(),
      },
    ];

    for (var student in sampleStudents) {
      await _firestore.collection('students').add(student);
    }
  }

  // Helper untuk mendapatkan current user's student data
  Future<Map<String, dynamic>?> getCurrentStudentData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final query = await _firestore
        .collection('students')
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.data();
    }
    return null;
  }
}