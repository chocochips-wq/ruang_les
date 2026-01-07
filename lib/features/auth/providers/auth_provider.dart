import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final UserRepository _userRepository;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  AuthProvider(this._userRepository);

  // Getters
  UserModel? get user => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  // Initialize auth state
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
        // Update last login
        await _userRepository.updateLastLogin(user.userId!);
      }
    } catch (e) {
      _error = 'Failed to initialize auth: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
    Map<String, dynamic>? roleData,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 1. Check if email exists
      final emailExists = await _userRepository.checkEmailExists(email);
      if (emailExists) {
        _error = 'Email sudah terdaftar';
        return false;
      }

      // 2. Create Firebase Auth user
      final auth = FirebaseAuth.instance;
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 3. Create user in Firestore with role data
      await _userRepository.createUserWithRoleData(
        userModel: UserModel(
          userId: credential.user!.uid,
          email: email,
          name: name,
          role: role,
          phone: phone,
          createdAt: DateTime.now(),
        ),
        studentData: role == 'student' ? roleData : null,
        parentData: role == 'parent' ? roleData : null,
        teacherData: role == 'teacher' ? roleData : null,
      );

      // 4. Load user data
      await initialize();

      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e);
      return false;
    } catch (e) {
      _error = 'Registration failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 1. Firebase Auth login
      final auth = FirebaseAuth.instance;
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Load user data
      await initialize();

      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e);
      return false;
    } catch (e) {
      _error = 'Login failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await FirebaseAuth.instance.signOut();
      _currentUser = null;
      _isAuthenticated = false;
    } catch (e) {
      _error = 'Logout failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e);
      return false;
    } catch (e) {
      _error = 'Reset password failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      if (_currentUser == null || _currentUser!.userId == null) {
        _error = 'User not authenticated';
        return false;
      }

      _isLoading = true;
      notifyListeners();

      await _userRepository.updateUserProfile(
        userId: _currentUser!.userId!,
        name: name,
        phone: phone,
        photoUrl: photoUrl,
      );

      // Reload user data
      await initialize();

      return true;
    } catch (e) {
      _error = 'Update profile failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Helper: Get Firebase auth error messages
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'invalid-email':
        return 'Email tidak valid';
      case 'operation-not-allowed':
        return 'Operasi tidak diizinkan';
      case 'weak-password':
        return 'Password terlalu lemah';
      case 'user-disabled':
        return 'Akun dinonaktifkan';
      case 'user-not-found':
        return 'User tidak ditemukan';
      case 'wrong-password':
        return 'Password salah';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan, coba lagi nanti';
      default:
        return 'Authentication failed (${e.code}): ${e.message}';
    }
  }
}
