import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/progress_model.dart';

class ProgressRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get progress for a student
  Future<StudentProgressModel?> getProgressByStudentId(String studentId) async {
    try {
      final query = await _firestore
          .collection('student_progress')
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }

      return StudentProgressModel.fromFirestore(query.docs.first);
    } catch (e) {
      throw Exception('Gagal memuat progress: $e');
    }
  }

  // Get realtime stream of student progress
  Stream<StudentProgressModel?> streamProgressByStudentId(String studentId) {
    return _firestore
        .collection('student_progress')
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }
      return StudentProgressModel.fromFirestore(snapshot.docs.first);
    });
  }

  // Get progress by progress ID
  Future<StudentProgressModel?> getProgressById(String progressId) async {
    try {
      final doc = await _firestore
          .collection('student_progress')
          .doc(progressId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return StudentProgressModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Gagal memuat progress: $e');
    }
  }

  // Stream progress by progress ID
  Stream<StudentProgressModel?> streamProgressById(String progressId) {
    return _firestore
        .collection('student_progress')
        .doc(progressId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return null;
      }
      return StudentProgressModel.fromFirestore(doc);
    });
  }

  // Create new progress
  Future<String> createProgress(StudentProgressModel progress) async {
    try {
      final doc = await _firestore
          .collection('student_progress')
          .add(progress.toMap());
      return doc.id;
    } catch (e) {
      throw Exception('Gagal membuat progress: $e');
    }
  }

  // Update progress
  Future<void> updateProgress(
      String progressId, StudentProgressModel progress) async {
    try {
      await _firestore
          .collection('student_progress')
          .doc(progressId)
          .update(progress.toMap());
    } catch (e) {
      throw Exception('Gagal memperbarui progress: $e');
    }
  }

  // Add experience points
  Future<void> addExperiencePoints(String progressId, int points) async {
    try {
      final doc = await _firestore
          .collection('student_progress')
          .doc(progressId)
          .get();

      if (doc.exists) {
        final progress = StudentProgressModel.fromFirestore(doc);
        int newXp = progress.experiencePoints + points;
        int newLevel = progress.currentLevel;

        // Check for level up
        while (newXp >= progress.maxExperiencePoints &&
            newLevel < progress.maxLevel) {
          newXp -= progress.maxExperiencePoints;
          newLevel++;
        }

        await _firestore.collection('student_progress').doc(progressId).update({
          'experiencePoints': newXp,
          'currentLevel': newLevel,
          'progressPercentage': (newXp / progress.maxExperiencePoints)
              .clamp(0.0, 1.0),
          'updatedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      throw Exception('Gagal menambah experience points: $e');
    }
  }

  // Complete activity
  Future<void> completeActivity(
      String progressId, String activityId) async {
    try {
      final doc = await _firestore
          .collection('student_progress')
          .doc(progressId)
          .get();

      if (doc.exists) {
        final progress = StudentProgressModel.fromFirestore(doc);
        final activities = List<String>.from(progress.completedActivities);

        if (!activities.contains(activityId)) {
          activities.add(activityId);
          await _firestore
              .collection('student_progress')
              .doc(progressId)
              .update({
            'completedActivities': activities,
            'updatedAt': Timestamp.now(),
          });
        }
      }
    } catch (e) {
      throw Exception('Gagal menyelesaikan activity: $e');
    }
  }

  // Complete topic
  Future<void> completeTopic(String progressId, String topicId) async {
    try {
      final doc = await _firestore
          .collection('student_progress')
          .doc(progressId)
          .get();

      if (doc.exists) {
        final progress = StudentProgressModel.fromFirestore(doc);
        final topics = List<String>.from(progress.completedTopics);

        if (!topics.contains(topicId)) {
          topics.add(topicId);
          await _firestore
              .collection('student_progress')
              .doc(progressId)
              .update({
            'completedTopics': topics,
            'updatedAt': Timestamp.now(),
          });
        }
      }
    } catch (e) {
      throw Exception('Gagal menyelesaikan topic: $e');
    }
  }

  // Get all achievements for a student
  Future<List<AchievementModel>> getAchievementsByStudentId(
      String studentId) async {
    try {
      final query = await _firestore
          .collection('achievements')
          .where('studentId', isEqualTo: studentId)
          .orderBy('unlockedAt', descending: true)
          .get();

      return query.docs
          .map((doc) => AchievementModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat achievements: $e');
    }
  }

  // Stream all achievements for a student
  Stream<List<AchievementModel>> streamAchievementsByStudentId(
      String studentId) {
    return _firestore
        .collection('achievements')
        .where('studentId', isEqualTo: studentId)
        .orderBy('unlockedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AchievementModel.fromFirestore(doc))
            .toList());
  }

  // Get unlocked achievements
  Future<List<AchievementModel>> getUnlockedAchievements(
      String studentId) async {
    try {
      final query = await _firestore
          .collection('achievements')
          .where('studentId', isEqualTo: studentId)
          .where('isUnlocked', isEqualTo: true)
          .orderBy('unlockedAt', descending: true)
          .get();

      return query.docs
          .map((doc) => AchievementModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat achievements: $e');
    }
  }

  // Stream unlocked achievements
  Stream<List<AchievementModel>> streamUnlockedAchievements(
      String studentId) {
    return _firestore
        .collection('achievements')
        .where('studentId', isEqualTo: studentId)
        .where('isUnlocked', isEqualTo: true)
        .orderBy('unlockedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AchievementModel.fromFirestore(doc))
            .toList());
  }

  // Create achievement
  Future<String> createAchievement(AchievementModel achievement) async {
    try {
      final doc =
          await _firestore.collection('achievements').add(achievement.toMap());
      return doc.id;
    } catch (e) {
      throw Exception('Gagal membuat achievement: $e');
    }
  }

  // Update achievement
  Future<void> updateAchievement(
      String achievementId, AchievementModel achievement) async {
    try {
      await _firestore
          .collection('achievements')
          .doc(achievementId)
          .update(achievement.toMap());
    } catch (e) {
      throw Exception('Gagal memperbarui achievement: $e');
    }
  }

  // Unlock achievement
  Future<void> unlockAchievement(String achievementId) async {
    try {
      await _firestore.collection('achievements').doc(achievementId).update({
        'isUnlocked': true,
        'unlockedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Gagal membuka achievement: $e');
    }
  }
}
