import 'package:flutter/foundation.dart';
import '../../../data/repositories/parent_repository.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../data/repositories/payment_repository.dart';
import '../../../data/repositories/class_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/models/parent_model.dart';
import '../../../core/models/student_model.dart';
import '../../../core/models/payment_model.dart';
import '../../../core/models/class_model.dart';

class ParentProvider with ChangeNotifier {
  final ParentRepository _parentRepository;
  final StudentRepository _studentRepository;
  final PaymentRepository _paymentRepository;
  final ClassRepository _classRepository;
  final UserRepository _userRepository;

  ParentModel? _currentParent;
  List<StudentModel> _children = [];
  List<PaymentModel> _payments = [];
  List<ClassModel> _childrenClasses = [];
  bool _isLoading = false;
  String? _error;

  ParentProvider(
    this._parentRepository,
    this._studentRepository,
    this._paymentRepository,
    this._classRepository,
    this._userRepository, // Added to constructor
  );

  // Getters
  ParentModel? get currentParent => _currentParent;
  List<StudentModel> get children => _children;
  List<PaymentModel> get payments => _payments;
  List<ClassModel> get childrenClasses => _childrenClasses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load parent data
  Future<void> loadParentData(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 1. Load parent info
      final parent = await _parentRepository.getParentByUserId(userId);
      if (parent == null) {
        _error = 'Data orang tua tidak ditemukan';
        return;
      }
      _currentParent = parent;

      // 2. Load children
      await _loadChildren(parent.parentId!);

      // 3. Load payments
      await _loadPayments(parent.parentId!);
    } catch (e) {
      _error = 'Gagal memuat data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load children
  Future<void> _loadChildren(String parentId) async {
    try {
      _children = await _studentRepository.getStudentsByParentId(parentId);

      // Load classes for each child
      _childrenClasses = [];
      for (final child in _children) {
        if (child.studentId != null) {
          final classes =
              await _classRepository.getClassesByStudentId(child.studentId!);
          _childrenClasses.addAll(classes);
        }
      }
    } catch (e) {
      throw Exception('Gagal memuat data anak: $e');
    }
  }

  // Load payments
  Future<void> _loadPayments(String parentId) async {
    try {
      _payments = await _paymentRepository.getPaymentsByParentId(parentId);
    } catch (e) {
      throw Exception('Gagal memuat data pembayaran: $e');
    }
  }

  // Add new child
  Future<bool> addChild(StudentModel student) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Add to Firestore
      final studentId = await _studentRepository.createStudent(student);

      // Update parent's studentIds
      if (_currentParent?.parentId != null) {
        final updatedParent = _currentParent!.copyWith(
          studentIds: [..._currentParent!.studentIds, studentId],
        );
        await _parentRepository.updateParent(
          _currentParent!.parentId!,
          updatedParent,
        );
        _currentParent = updatedParent;
      }

      // Reload children
      await _loadChildren(_currentParent!.parentId!);

      return true;
    } catch (e) {
      _error = 'Gagal menambahkan anak: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Link existing student account by email
  Future<bool> linkStudentByEmail(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 1. Find user by email
      final user = await _userRepository.getUserByEmail(email);
      if (user == null) {
        _error = 'Email tidak ditemukan';
        return false;
      }

      // 2. Verify role is student
      if (user.role != 'student') {
        _error = 'Email tersebut bukan akun siswa';
        return false;
      }

      // 3. Get student profile
      final student = await _studentRepository.getStudentByUserId(user.userId!);
      if (student == null) {
        _error = 'Data profil siswa tidak ditemukan';
        return false;
      }

      // 4. Check if already linked to this parent
      if (_children.any((c) => c.studentId == student.studentId)) {
        _error = 'Akun ini sudah ditautkan';
        return false;
      }

      // 5. Update student with parentId
      if (_currentParent?.parentId == null) {
        _error = 'Data orang tua belum dimuat';
        return false;
      }

      final updatedStudent =
          student.copyWith(parentId: _currentParent!.parentId);
      if (student.studentId != null) {
        await _studentRepository.updateStudent(
            student.studentId!, updatedStudent);
      }

      // 6. Update parent with studentId
      final updatedParent = _currentParent!.copyWith(
        studentIds: [..._currentParent!.studentIds, student.studentId!],
      );
      await _parentRepository.updateParent(
        _currentParent!.parentId!,
        updatedParent,
      );
      _currentParent = updatedParent;

      // 7. Reload children list
      await _loadChildren(_currentParent!.parentId!);

      return true;
    } catch (e) {
      _error = 'Gagal menautkan akun: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update child info
  Future<bool> updateChild(StudentModel student) async {
    try {
      if (student.studentId == null) {
        _error = 'ID siswa tidak valid';
        return false;
      }

      _isLoading = true;
      notifyListeners();

      await _studentRepository.updateStudent(student.studentId!, student);

      // Update in local list
      final index =
          _children.indexWhere((c) => c.studentId == student.studentId);
      if (index != -1) {
        _children[index] = student;
      }

      return true;
    } catch (e) {
      _error = 'Gagal mengupdate data anak: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark payment as paid
  Future<bool> markPaymentAsPaid(String paymentId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _paymentRepository.updatePaymentStatus(paymentId, 'paid');

      // Update local list
      final index = _payments.indexWhere((p) => p.paymentId == paymentId);
      if (index != -1) {
        _payments[index] = _payments[index].copyWith(
          status: 'paid',
          paidAt: DateTime.now(),
        );
      }

      return true;
    } catch (e) {
      _error = 'Gagal menandai pembayaran: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get child by ID
  StudentModel? getChildById(String studentId) {
    return _children.firstWhere(
      (child) => child.studentId == studentId,
      orElse: () => StudentModel(
        userId: '',
        nickname: '',
        fullName: '',
        gradeLevel: '',
        createdAt: DateTime.now(),
      ),
    );
  }

  // Get child's classes
  List<ClassModel> getChildClasses(String studentId) {
    return _childrenClasses
        .where((class_) => class_.studentIds.contains(studentId))
        .toList();
  }

  // Get child's payments
  List<PaymentModel> getChildPayments(String studentId) {
    return _payments
        .where((payment) => payment.studentId == studentId)
        .toList();
  }

  // Get overdue payments
  List<PaymentModel> getOverduePayments() {
    final now = DateTime.now();
    return _payments
        .where((payment) =>
            payment.status == 'pending' && payment.dueDate.isBefore(now))
        .toList();
  }

  // Get upcoming payments
  List<PaymentModel> getUpcomingPayments() {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));

    return _payments
        .where((payment) =>
            payment.status == 'pending' &&
            payment.dueDate.isAfter(now) &&
            payment.dueDate.isBefore(weekFromNow))
        .toList();
  }

  // Clear parent data on logout
  void clearParentData() {
    _currentParent = null;
    _children.clear();
    _payments.clear();
    _childrenClasses.clear();
    _error = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
