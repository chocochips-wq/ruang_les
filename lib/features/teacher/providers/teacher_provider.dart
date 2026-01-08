import 'package:flutter/foundation.dart';
import '../../../data/repositories/teacher_repository.dart';
import '../../../data/repositories/class_repository.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../data/repositories/payment_repository.dart';
import '../../../core/models/teacher_model.dart';
import '../../../core/models/class_model.dart';
import '../../../core/models/student_model.dart';
import '../../../core/models/session_model.dart';
import '../../../core/models/payment_model.dart';

class TeacherProvider with ChangeNotifier {
  final TeacherRepository _teacherRepository;
  final ClassRepository _classRepository;
  final StudentRepository _studentRepository;
  final SessionRepository _sessionRepository;
  final PaymentRepository _paymentRepository;

  TeacherModel? _currentTeacher;
  List<ClassModel> _classes = [];
  List<StudentModel> _students = [];
  List<SessionModel> _sessions = [];
  List<PaymentModel> _classPayments = [];
  bool _isLoading = false;
  String? _error;

  TeacherProvider(
    this._teacherRepository,
    this._classRepository,
    this._studentRepository,
    this._sessionRepository,
    this._paymentRepository,
  );

  // Getters
  TeacherModel? get currentTeacher => _currentTeacher;
  List<ClassModel> get classes => _classes;
  List<StudentModel> get students => _students;
  List<SessionModel> get sessions => _sessions;
  List<PaymentModel> get classPayments => _classPayments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load teacher data
  Future<void> loadTeacherData(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 1. Load teacher info
      final teacher = await _teacherRepository.getTeacherByUserId(userId);
      if (teacher == null) {
        _error = 'Data pengajar tidak ditemukan';
        return;
      }
      _currentTeacher = teacher;

      // 2. Load classes
      await _loadClasses(teacher.teacherId!);

      // 3. Load sessions for all classes
      await _loadSessions();

      // 4. Load payments for all classes
      await _loadPayments();
    } catch (e) {
      _error = 'Gagal memuat data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load classes
  Future<void> _loadClasses(String teacherId) async {
    try {
      _classes = await _classRepository.getClassesByTeacherId(teacherId);

      // Load students from all classes
      _students = [];
      for (final class_ in _classes) {
        for (final studentId in class_.studentIds) {
          final student = await _studentRepository.getStudentById(studentId);
          if (student != null &&
              !_students.any((s) => s.studentId == studentId)) {
            _students.add(student);
          }
        }
      }
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
          final classSessions =
              await _sessionRepository.getSessionsByClassId(class_.classId!);
          _sessions.addAll(classSessions);
        }
      }
      // Sort by date
      _sessions.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      throw Exception('Gagal memuat sesi: $e');
    }
  }

  // Load payments
  Future<void> _loadPayments() async {
    try {
      _classPayments = [];
      for (final student in _students) {
        if (student.studentId != null) {
          final studentPayments = await _paymentRepository
              .getPaymentsByStudentId(student.studentId!);
          _classPayments.addAll(studentPayments);
        }
      }
    } catch (e) {
      throw Exception('Gagal memuat pembayaran: $e');
    }
  }

  // Create new class
  Future<bool> createClass(ClassModel classModel) async {
    try {
      _isLoading = true;
      notifyListeners();

      final classId = await _classRepository.createClass(classModel);

      // Add to teacher's classIds
      if (_currentTeacher?.teacherId != null) {
        final updatedTeacher = _currentTeacher!.copyWith(
          classIds: [..._currentTeacher!.classIds, classId],
        );
        await _teacherRepository.updateTeacher(
          _currentTeacher!.teacherId!,
          updatedTeacher,
        );
        _currentTeacher = updatedTeacher;
      }

      // Reload classes
      await _loadClasses(_currentTeacher!.teacherId!);

      return true;
    } catch (e) {
      _error = 'Gagal membuat kelas: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update teacher
  Future<bool> updateTeacher(TeacherModel teacher) async {
    try {
      if (teacher.teacherId == null) {
        _error = 'ID pengajar tidak valid';
        return false;
      }

      _isLoading = true;
      notifyListeners();

      await _teacherRepository.updateTeacher(teacher.teacherId!, teacher);
      _currentTeacher = teacher;

      return true;
    } catch (e) {
      _error = 'Gagal mengupdate profile pengajar: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update class
  Future<bool> updateClass(ClassModel classModel) async {
    try {
      if (classModel.classId == null) {
        _error = 'ID kelas tidak valid';
        return false;
      }

      _isLoading = true;
      notifyListeners();

      await _classRepository.updateClass(classModel.classId!, classModel);

      // Update local list
      final index = _classes.indexWhere((c) => c.classId == classModel.classId);
      if (index != -1) {
        _classes[index] = classModel;
      }

      return true;
    } catch (e) {
      _error = 'Gagal mengupdate kelas: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create session
  Future<bool> createSession(SessionModel session) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _sessionRepository.createSession(session);

      // Reload sessions
      await _loadSessions();

      return true;
    } catch (e) {
      _error = 'Gagal membuat sesi: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update attendance
  Future<bool> updateAttendance(
      String sessionId, List<Attendance> attendance) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _sessionRepository.updateAttendance(sessionId, attendance);

      // Update local list
      final index = _sessions.indexWhere((s) => s.sessionId == sessionId);
      if (index != -1) {
        _sessions[index] = _sessions[index].copyWith(
          attendance: attendance,
        );
      }

      return true;
    } catch (e) {
      _error = 'Gagal mengupdate absensi: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add student to class
  Future<bool> addStudentToClass(String classId, String studentId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _classRepository.addStudentToClass(classId, studentId);

      // Reload classes and students
      if (_currentTeacher?.teacherId != null) {
        await _loadClasses(_currentTeacher!.teacherId!);
      }

      return true;
    } catch (e) {
      _error = 'Gagal menambahkan siswa: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove student from class
  Future<bool> removeStudentFromClass(String classId, String studentId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _classRepository.removeStudentFromClass(classId, studentId);

      // Reload classes and students
      if (_currentTeacher?.teacherId != null) {
        await _loadClasses(_currentTeacher!.teacherId!);
      }

      return true;
    } catch (e) {
      _error = 'Gagal menghapus siswa: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  // Get students by class ID
  List<StudentModel> getStudentsByClassId(String classId) {
    final class_ = getClassById(classId);
    if (class_ == null) return [];

    return _students
        .where((student) => class_.studentIds.contains(student.studentId))
        .toList();
  }

  // Get sessions by class ID
  List<SessionModel> getSessionsByClassId(String classId) {
    return _sessions.where((session) => session.classId == classId).toList();
  }

  // Get upcoming sessions (next 7 days)
  List<SessionModel> getUpcomingSessions() {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));

    return _sessions
        .where((session) =>
            session.date.isAfter(now) && session.date.isBefore(weekFromNow))
        .toList();
  }

  // Get today's sessions
  List<SessionModel> getTodaySessions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _sessions
        .where((session) =>
            session.date.isAfter(today) && session.date.isBefore(tomorrow))
        .toList();
  }

  // Get class statistics
  Map<String, dynamic> getClassStatistics(String classId) {
    final students = getStudentsByClassId(classId);
    final sessions = getSessionsByClassId(classId);
    final class_ = getClassById(classId);

    if (class_ == null) return {};

    int totalAttendance = 0;
    int totalSessions = sessions.length;

    for (final session in sessions) {
      totalAttendance +=
          session.attendance.where((a) => a.status == 'present').length;
    }

    final avgAttendance = totalSessions > 0
        ? (totalAttendance / (totalSessions * students.length)) * 100
        : 0;

    return {
      'totalStudents': students.length,
      'totalSessions': totalSessions,
      'avgAttendance': avgAttendance.round(),
      'totalRevenue': class_.totalPrice * students.length,
    };
  }

  // Clear teacher data on logout
  void clearTeacherData() {
    _currentTeacher = null;
    _classes.clear();
    _students.clear();
    _sessions.clear();
    _classPayments.clear();
    _error = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
