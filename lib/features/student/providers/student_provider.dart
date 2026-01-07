import 'package:flutter/foundation.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../data/repositories/class_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../core/models/student_model.dart';
import '../../../core/models/class_model.dart';
import '../../../core/models/session_model.dart';

class StudentProvider with ChangeNotifier {
  final StudentRepository _studentRepository;
  final ClassRepository _classRepository;
  final SessionRepository _sessionRepository;

  StudentModel? _currentStudent;
  List<ClassModel> _classes = [];
  List<SessionModel> _sessions = [];
  bool _isLoading = false;
  String? _error;

  StudentProvider(
    this._studentRepository,
    this._classRepository,
    this._sessionRepository,
  );

  // Getters
  StudentModel? get currentStudent => _currentStudent;
  List<ClassModel> get classes => _classes;
  List<SessionModel> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load student by user ID
  Future<void> loadStudentByUserId(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final student = await _studentRepository.getStudentByUserId(userId);
      if (student == null) {
        _error = 'Data siswa tidak ditemukan';
        return;
      }
      _currentStudent = student;

      // Load classes and sessions
      await _loadClasses(student.studentId!);
      await _loadSessions();

    } catch (e) {
      _error = 'Gagal memuat data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load classes
  Future<void> _loadClasses(String studentId) async {
    try {
      _classes = await _classRepository.getClassesByStudentId(studentId);
    } catch (e) {
      throw Exception('Gagal memuat kelas: $e');
    }
  }

  // Load sessions
  Future<void> _loadSessions() async {
    try {
      _sessions = [];
      for (final class_ in _classes) {
        if (class_.classId != null) {
          final classSessions = await _sessionRepository.getSessionsByClassId(class_.classId!);
          _sessions.addAll(classSessions);
        }
      }
      // Sort by date (newest first)
      _sessions.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      throw Exception('Gagal memuat sesi: $e');
    }
  }

  // Update student profile
  Future<bool> updateProfile({
    String? nickname,
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      if (_currentStudent == null || _currentStudent!.studentId == null) {
        _error = 'Siswa tidak ditemukan';
        return false;
      }

      _isLoading = true;
      notifyListeners();

      final updatedStudent = _currentStudent!.copyWith(
        nickname: nickname ?? _currentStudent!.nickname,
        fullName: fullName ?? _currentStudent!.fullName,
        avatarUrl: avatarUrl ?? _currentStudent!.avatarUrl,
      );

      await _studentRepository.updateStudent(
        _currentStudent!.studentId!,
        updatedStudent,
      );

      _currentStudent = updatedStudent;

      return true;
    } catch (e) {
      _error = 'Gagal mengupdate profil: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add points
  Future<bool> addPoints(int points) async {
    try {
      if (_currentStudent == null || _currentStudent!.studentId == null) {
        _error = 'Siswa tidak ditemukan';
        return false;
      }

      _isLoading = true;
      notifyListeners();

      await _studentRepository.addPoints(_currentStudent!.studentId!, points);
      
      // Update local state
      _currentStudent = _currentStudent!.copyWith(
        totalPoints: _currentStudent!.totalPoints + points,
      );

      return true;
    } catch (e) {
      _error = 'Gagal menambahkan poin: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add badge
  Future<bool> addBadge(String badge) async {
    try {
      if (_currentStudent == null || _currentStudent!.studentId == null) {
        _error = 'Siswa tidak ditemukan';
        return false;
      }

      _isLoading = true;
      notifyListeners();

      await _studentRepository.addBadge(_currentStudent!.studentId!, badge);
      
      // Update local state
      final currentBadges = [..._currentStudent!.badges, badge];
      _currentStudent = _currentStudent!.copyWith(badges: currentBadges);

      return true;
    } catch (e) {
      _error = 'Gagal menambahkan badge: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get attendance by session
  Attendance? getAttendanceBySession(String sessionId) {
    if (_currentStudent?.studentId == null) return null;

    final session = _sessions.firstWhere(
      (s) => s.sessionId == sessionId,
      orElse: () => SessionModel(
        classId: '',
        sessionNumber: 0,
        date: DateTime.now(),
        material: '',
        createdAt: DateTime.now(),
      ),
    );

    return session.attendance.firstWhere(
      (a) => a.studentId == _currentStudent!.studentId,
      orElse: () => Attendance(
        studentId: '',
        status: 'absent',
      ),
    );
  }

  // Get attendance statistics
  Map<String, dynamic> getAttendanceStatistics() {
    if (_currentStudent?.studentId == null) {
      return {'total': 0, 'present': 0, 'percentage': 0};
    }

    int total = 0;
    int present = 0;

    for (final session in _sessions) {
      final attendance = session.attendance.firstWhere(
        (a) => a.studentId == _currentStudent!.studentId,
        orElse: () => Attendance(studentId: '', status: 'absent'),
      );
      
      total++;
      if (attendance.status == 'present') {
        present++;
      }
    }

    final percentage = total > 0 ? (present / total) * 100 : 0;

    return {
      'total': total,
      'present': present,
      'absent': total - present,
      'percentage': percentage.round(),
    };
  }

  // Get upcoming sessions (next 7 days)
  List<SessionModel> getUpcomingSessions() {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    
    return _sessions
        .where((session) => 
          session.date.isAfter(now) && 
          session.date.isBefore(weekFromNow))
        .toList();
  }

  // Get today's sessions
  List<SessionModel> getTodaySessions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return _sessions
        .where((session) => 
          session.date.isAfter(today) && 
          session.date.isBefore(tomorrow))
        .toList();
  }

  // Get class by ID
  ClassModel? getClassById(String classId) {
    return _classes.firstWhere(
      (class_) => class_.classId == classId,
      orElse: () => ClassModel(
        className: '',
        gradeLevel: '',
        type: '',
        teacherId: '',
        maxStudents: 0,
        pricePerSession: 0,
        totalSessions: 0,
        schedule: '',
        createdAt: DateTime.now(),
      ),
    );
  }

  // Get sessions by class ID
  List<SessionModel> getSessionsByClassId(String classId) {
    return _sessions
        .where((session) => session.classId == classId)
        .toList();
  }

  // Get recent sessions (last 10)
  List<SessionModel> getRecentSessions() {
    return _sessions.take(10).toList();
  }

  // Clear student data on logout
  void clearStudent() {
    _currentStudent = null;
    _classes.clear();
    _sessions.clear();
    _error = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}