import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/user_model.dart';
import '../../core/utils/constants.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String collectionName = AppConstants.usersCollection;

  // 1. CREATE USER (Setelah registrasi Firebase Auth)
  Future<UserModel> createUser({
    required String email,
    required String name,
    required String role,
    required String phone,
    String? photoUrl,
  }) async {
    try {
      // Pastikan user sudah login di Firebase Auth
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final userModel = UserModel(
        userId: currentUser.uid,
        email: email,
        name: name,
        role: role,
        phone: phone,
        photoUrl: photoUrl,
        createdAt: DateTime.now(),
      );

      // Simpan ke Firestore
      await _firestore
          .collection(collectionName)
          .doc(currentUser.uid)
          .set(userModel.toMap());

      return userModel;
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // 2. GET USER BY ID (dari Firestore)
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // 3. GET CURRENT USER (dari Firebase Auth + Firestore)
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      return await getUserById(currentUser.uid);
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  // 4. GET USER BY EMAIL
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final query = await _firestore
          .collection(collectionName)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return UserModel.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user by email: $e');
    }
  }

  // 5. UPDATE USER PROFILE
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;

      if (updateData.isNotEmpty) {
        await _firestore
            .collection(collectionName)
            .doc(userId)
            .update(updateData);
      }
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // 6. UPDATE USER ROLE (untuk admin)
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(userId)
          .update({'role': newRole});
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  // 7. DELETE USER (Firestore saja, Auth harus dipisah)
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(collectionName).doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // 8. CHECK IF EMAIL EXISTS
  Future<bool> checkEmailExists(String email) async {
    try {
      final query = await _firestore
          .collection(collectionName)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check email: $e');
    }
  }

  // 9. GET ALL USERS BY ROLE (untuk admin/pengajar)
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final query = await _firestore
          .collection(collectionName)
          .where('role', isEqualTo: role)
          .get();

      return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get users by role: $e');
    }
  }

  // 10. STREAM USER DATA (real-time updates)
  Stream<UserModel?> streamUser(String userId) {
    return _firestore
        .collection(collectionName)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // 11. STREAM CURRENT USER
  Stream<UserModel?> streamCurrentUser() {
    return _auth.authStateChanges().asyncMap((user) {
      if (user != null) {
        return getUserById(user.uid);
      }
      return null;
    });
  }

  // 12. SEARCH USERS (untuk pencarian di admin/pengajar)
  Future<List<UserModel>> searchUsers(String queryText) async {
    try {
      final query = await _firestore
          .collection(collectionName)
          .where('name', isGreaterThanOrEqualTo: queryText)
          .where('name', isLessThan: queryText + 'z')
          .limit(20)
          .get();

      return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // 13. GET USER COUNT BY ROLE
  Future<int> getUserCountByRole(String role) async {
    try {
      final query = await _firestore
          .collection(collectionName)
          .where('role', isEqualTo: role)
          .count()
          .get();

      return query.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get user count: $e');
    }
  }

  // 14. VERIFY USER ROLE (validasi role user)
  Future<bool> verifyUserRole(String userId, String requiredRole) async {
    try {
      final user = await getUserById(userId);
      return user?.role == requiredRole;
    } catch (e) {
      throw Exception('Failed to verify user role: $e');
    }
  }

  // 15. BATCH OPERATION: Create user with related data
  Future<void> createUserWithRoleData({
    required UserModel userModel,
    Map<String, dynamic>? studentData,
    Map<String, dynamic>? parentData,
    Map<String, dynamic>? teacherData,
  }) async {
    try {
      final batch = _firestore.batch();

      // 1. Create user document
      final userRef =
          _firestore.collection(collectionName).doc(userModel.userId);
      batch.set(userRef, userModel.toMap());

      // 2. Create role-specific document jika ada data
      if (userModel.role == AppConstants.roleStudent && studentData != null) {
        final studentRef = _firestore
            .collection(AppConstants.studentsCollection)
            .doc(userModel.userId);
        batch.set(studentRef, {
          ...studentData,
          'userId': userModel.userId,
          'createdAt': Timestamp.now(),
        });
      } else if (userModel.role == AppConstants.roleParent &&
          parentData != null) {
        final parentRef = _firestore
            .collection(AppConstants.parentsCollection)
            .doc(userModel.userId);
        batch.set(parentRef, {
          ...parentData,
          'userId': userModel.userId,
          'createdAt': Timestamp.now(),
        });
      } else if (userModel.role == AppConstants.roleTeacher &&
          teacherData != null) {
        final teacherRef = _firestore
            .collection(AppConstants.teachersCollection)
            .doc(userModel.userId);
        batch.set(teacherRef, {
          ...teacherData,
          'userId': userModel.userId,
          'createdAt': Timestamp.now(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to create user with role data: $e');
    }
  }

  // 16. GET USER WITH ROLE DETAILS (join dengan role collection)
  Future<Map<String, dynamic>> getUserWithRoleDetails(String userId) async {
    try {
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      Map<String, dynamic> result = {
        'user': user,
      };

      // Ambil data berdasarkan role
      switch (user.role) {
        case AppConstants.roleStudent:
          final studentDoc = await _firestore
              .collection(AppConstants.studentsCollection)
              .doc(userId)
              .get();
          if (studentDoc.exists) {
            result['studentData'] = studentDoc.data();
          }
          break;

        case AppConstants.roleParent:
          final parentDoc = await _firestore
              .collection(AppConstants.parentsCollection)
              .doc(userId)
              .get();
          if (parentDoc.exists) {
            result['parentData'] = parentDoc.data();
          }
          break;

        case AppConstants.roleTeacher:
          final teacherDoc = await _firestore
              .collection(AppConstants.teachersCollection)
              .doc(userId)
              .get();
          if (teacherDoc.exists) {
            result['teacherData'] = teacherDoc.data();
          }
          break;
      }

      return result;
    } catch (e) {
      throw Exception('Failed to get user with role details: $e');
    }
  }

  // 17. UPDATE USER LAST LOGIN
  Future<void> updateLastLogin(String userId) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(userId)
          .update({'lastLogin': Timestamp.now()});
    } catch (e) {
      print('Failed to update last login: $e');
      // Tidak throw exception karena ini opsional
    }
  }
}
