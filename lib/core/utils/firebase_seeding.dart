import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'quiz_seeding.dart';

class FirebaseSeeding {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seed payment data for parent-student links
  static Future<void> seedPaymentData(
      String teacherId, String classId, String? parentId, String? studentId) async {
    try {
      final now = DateTime.now();
      const uuid = Uuid();

      final payments = [
        {
          'paymentId': uuid.v4(),
          'teacherId': teacherId,
          'classId': classId,
          'studentId': studentId,
          'parentId': parentId,
          'amount': 150000,
          'currency': 'IDR',
          'description': 'Biaya kursus bulan Januari',
          'dueDate': Timestamp.fromDate(now.add(const Duration(days: 30))),
          'status': 'pending',
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
          'paidAt': null,
          'notes': null,
        },
        {
          'paymentId': uuid.v4(),
          'teacherId': teacherId,
          'classId': classId,
          'studentId': studentId,
          'parentId': parentId,
          'amount': 100000,
          'currency': 'IDR',
          'description': 'Biaya materi tambahan',
          'dueDate': Timestamp.fromDate(now.add(const Duration(days: 45))),
          'status': 'pending',
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
          'paidAt': null,
          'notes': null,
        },
      ];

      for (final payment in payments) {
        final paymentId = payment['paymentId'] as String;
        await _firestore
            .collection('payments')
            .doc(paymentId)
            .set(payment);
      }

      print('Payment data seeded successfully');
    } catch (e) {
      print('Error seeding payment data: $e');
    }
  }

  /// Migrate existing students to link with parents
  static Future<void> migrateStudentParentLinks() async {
    try {
      print('Starting migration: link students with parents');

      // Get all students
      final studentsSnapshot =
          await _firestore.collection('students').get();

      int migratedCount = 0;
      for (final studentDoc in studentsSnapshot.docs) {
        final studentData = studentDoc.data();
        final parentId = studentData['parentId'];

        // If student doesn't have parentId yet, try to find a parent
        if (parentId == null || parentId.isEmpty) {
          // Attempt to find parent from userId pattern or other logic
          // For now, just ensure totalPoints and fullName exist
          final updates = <String, dynamic>{};

          if (!studentData.containsKey('totalPoints')) {
            updates['totalPoints'] = 0;
          }

          if (!studentData.containsKey('fullName')) {
            updates['fullName'] = studentData['nickname'] ?? 'Student';
          }

          if (updates.isNotEmpty) {
            await studentDoc.reference.update(updates);
            migratedCount++;
          }
        }
      }

      print('Migration completed: $migratedCount students updated');
    } catch (e) {
      print('Error during migration: $e');
    }
  }

  /// Ensure all parents have studentIds array
  static Future<void> migrateParentStudentIds() async {
    try {
      print('Starting migration: ensure parents have studentIds');

      final parentsSnapshot =
          await _firestore.collection('parents').get();

      int migratedCount = 0;
      for (final parentDoc in parentsSnapshot.docs) {
        final parentData = parentDoc.data();

        if (!parentData.containsKey('studentIds') ||
            parentData['studentIds'] == null) {
          await parentDoc.reference.update({
            'studentIds': [],
          });
          migratedCount++;
        }
      }

      print('Migration completed: $migratedCount parents updated');
    } catch (e) {
      print('Error during parent migration: $e');
    }
  }


  /// Seed progress data untuk student tertentu
  static Future<void> seedProgressData(String studentId) async {
    try {
      final now = DateTime.now();
      
      final progressData = {
        'studentId': studentId,
        'subjectId': null,
        'currentLevel': 3,
        'maxLevel': 10,
        'experiencePoints': 75,
        'maxExperiencePoints': 100,
        'progressPercentage': 0.75,
        'completedTopics': ['topic_1', 'topic_2', 'topic_3'],
        'completedActivities': ['activity_1', 'activity_2', 'activity_3', 'activity_4'],
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 30))),
        'updatedAt': Timestamp.fromDate(now),
      };

      await _firestore.collection('student_progress').add(progressData);
      print('Progress data seeded successfully');
    } catch (e) {
      print('Error seeding progress data: $e');
    }
  }

  /// Seed achievement data untuk student tertentu
  static Future<void> seedAchievementsData(String studentId) async {
    try {
      final now = DateTime.now();
      
      final achievements = [
        {
          'studentId': studentId,
          'title': 'Permulaan Gemilang',
          'description': 'Menyelesaikan 5 aktivitas pertama',
          'icon': '🌟',
          'points': 50,
          'category': 'badge',
          'isUnlocked': true,
          'unlockedAt': Timestamp.fromDate(now.subtract(const Duration(days: 20))),
        },
        {
          'studentId': studentId,
          'title': 'Jenius Matematika',
          'description': 'Menyelesaikan 10 soal matematika berturut-turut dengan benar',
          'icon': '🧮',
          'points': 100,
          'category': 'badge',
          'isUnlocked': true,
          'unlockedAt': Timestamp.fromDate(now.subtract(const Duration(days: 15))),
        },
        {
          'studentId': studentId,
          'title': 'Pembaca Setia',
          'description': 'Menyelesaikan 3 topik Bahasa Indonesia',
          'icon': '📚',
          'points': 75,
          'category': 'badge',
          'isUnlocked': true,
          'unlockedAt': Timestamp.fromDate(now.subtract(const Duration(days: 10))),
        },
        {
          'studentId': studentId,
          'title': 'Scientis Muda',
          'description': 'Menyelesaikan semua eksperimen IPA di minggu ini',
          'icon': '🔬',
          'points': 120,
          'category': 'badge',
          'isUnlocked': false,
          'unlockedAt': Timestamp.fromDate(now),
        },
        {
          'studentId': studentId,
          'title': 'Polyglot Cilik',
          'description': 'Menguasai 50 kosakata Bahasa Inggris',
          'icon': '🌍',
          'points': 90,
          'category': 'sticker',
          'isUnlocked': true,
          'unlockedAt': Timestamp.fromDate(now.subtract(const Duration(days: 5))),
        },
        {
          'studentId': studentId,
          'title': 'Petualang Peta',
          'description': 'Mempelajari 5 negara di IPS',
          'icon': '🗺️',
          'points': 85,
          'category': 'sticker',
          'isUnlocked': true,
          'unlockedAt': Timestamp.fromDate(now.subtract(const Duration(days: 3))),
        },
        {
          'studentId': studentId,
          'title': 'Legenda Ruang Les',
          'description': 'Mencapai level 10 (max level)',
          'icon': '👑',
          'points': 500,
          'category': 'badge',
          'isUnlocked': false,
          'unlockedAt': Timestamp.fromDate(now),
        },
        {
          'studentId': studentId,
          'title': 'Giat Belajar',
          'description': 'Masuk dan belajar setiap hari selama 7 hari berturut-turut',
          'icon': '🔥',
          'points': 150,
          'category': 'sticker',
          'isUnlocked': false,
          'unlockedAt': Timestamp.fromDate(now),
        },
      ];

      for (final achievement in achievements) {
        await _firestore.collection('achievements').add(achievement);
      }
      
      print('Achievements data seeded successfully');
    } catch (e) {
      print('Error seeding achievements data: $e');
    }
  }

  /// Seed semua data untuk student
  static Future<void> seedAllData(String studentId, {String? classId}) async {
    try {
      print('Starting to seed data for student: $studentId');

      // Run migrations first
      await migrateStudentParentLinks();
      await migrateParentStudentIds();

      // Check if progress already exists
      final progressQuery = await _firestore
          .collection('student_progress')
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();

      if (progressQuery.docs.isEmpty) {
        await seedProgressData(studentId);
      } else {
        print('Progress data already exists');
      }

      // Check if achievements already exist
      final achievementsQuery = await _firestore
          .collection('achievements')
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();

      if (achievementsQuery.docs.isEmpty) {
        await seedAchievementsData(studentId);
      } else {
        print('Achievements data already exists');
      }

      // Seed quiz data
      if (classId != null) {
        final quizQuery = await _firestore
            .collection('quizzes')
            .where('studentId', isEqualTo: studentId)
            .limit(1)
            .get();

        if (quizQuery.docs.isEmpty) {
          await QuizSeeding.seedQuizData(studentId, classId);
        } else {
          print('Quiz data already exists');
        }
      }

      // Seed payment data if we have class and parent info
      if (classId != null) {
        final paymentQuery = await _firestore
            .collection('payments')
            .where('studentId', isEqualTo: studentId)
            .limit(1)
            .get();

        if (paymentQuery.docs.isEmpty) {
          // Get student's parent and teacher info
          final studentDoc =
              await _firestore.collection('students').doc(studentId).get();
          final studentData = studentDoc.data() as Map<String, dynamic>?;
          final parentId = studentData?['parentId'];

          // Get teacher for this class
          final classDoc =
              await _firestore.collection('classes').doc(classId).get();
          final classData = classDoc.data() as Map<String, dynamic>?;
          final teacherId = classData?['teacherId'];

          if (parentId != null && teacherId != null) {
            await seedPaymentData(teacherId, classId, parentId, studentId);
          }
        }
      }

      print('Data seeding completed');
    } catch (e) {
      print('Error seeding all data: $e');
    }
  }

  /// Clear semua data untuk student (gunakan hanya untuk testing)
  static Future<void> clearAllData(String studentId) async {
    try {
      print('Clearing data for student: $studentId');
      
      // Clear progress
      final progressQuery = await _firestore
          .collection('student_progress')
          .where('studentId', isEqualTo: studentId)
          .get();

      for (final doc in progressQuery.docs) {
        await doc.reference.delete();
      }

      // Clear achievements
      final achievementsQuery = await _firestore
          .collection('achievements')
          .where('studentId', isEqualTo: studentId)
          .get();

      for (final doc in achievementsQuery.docs) {
        await doc.reference.delete();
      }

      // Clear payments
      final paymentsQuery = await _firestore
          .collection('payments')
          .where('studentId', isEqualTo: studentId)
          .get();

      for (final doc in paymentsQuery.docs) {
        await doc.reference.delete();
      }

      // Clear quizzes
      await QuizSeeding.clearQuizData(studentId);

      print('Data cleared successfully');
    } catch (e) {
      print('Error clearing data: $e');
    }
  }
}
