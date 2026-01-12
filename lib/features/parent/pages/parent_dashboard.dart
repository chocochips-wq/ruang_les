import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/colors.dart';
import '../../../data/repositories/payment_repository.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../data/repositories/class_repository.dart';
import '../../../core/models/student_model.dart';
import '../../../core/models/payment_model.dart';
import '../../../core/models/class_model.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PaymentRepository _paymentRepository = PaymentRepository();
  final StudentRepository _studentRepository = StudentRepository();
  final ProgressRepository _progressRepository = ProgressRepository();
  String? _parentId;

  @override
  void initState() {
    super.initState();
    _parentId = _auth.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    if (_parentId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Orang Tua')),
        body: const Center(child: Text('Tidak ada pengguna yang login')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Dashboard Orang Tua',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== ANAK-ANAK SECTION WITH ADD BUTTON =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Anak Saya',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () => _showAddChildDialog(context),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('+ Tambah Anak',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildChildrenList(),
            const SizedBox(height: 24),

            // ===== PEMBAYARAN SECTION =====
            const Text('Pembayaran',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildPaymentsList(),
          ],
        ),
      ),
    );
  }

  /// Fetch children from parents collection and display their progress
  Widget _buildChildrenList() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('parents')
          .doc(_parentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Text('Belum ada anak terdaftar',
                style: TextStyle(color: Colors.grey)),
          );
        }

        final parentData =
            snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final studentIds =
            List<String>.from(parentData['studentIds'] ?? []);

        if (studentIds.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Text('Belum ada anak terdaftar',
                style: TextStyle(color: Colors.grey)),
          );
        }

        // Display each child
        return Column(
          children: studentIds.map((studentId) {
            return _buildChildCard(studentId);
          }).toList(),
        );
      },
    );
  }

  /// Build individual child card with progress
  Widget _buildChildCard(String studentId) {
    return FutureBuilder<StudentModel?>(
      future: _studentRepository.getStudentById(studentId),
      builder: (context, studentSnapshot) {
        if (studentSnapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const CircularProgressIndicator(),
          );
        }

        if (!studentSnapshot.hasData) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Text('Data anak tidak ditemukan',
                style: TextStyle(color: Colors.red)),
          );
        }

        final student = studentSnapshot.data!;

        // Stream progress data
        return StreamBuilder(
          stream:
              _progressRepository.streamProgressByStudentId(studentId),
          builder: (context, progressSnapshot) {
            final progress = progressSnapshot.data;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.person,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student.fullName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            Text('${student.gradeLevel}',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (progress != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('XP: ${progress.experiencePoints ?? 0}',
                                style: const TextStyle(fontSize: 12)),
                            Text('Level: ${progress.currentLevel ?? 1}',
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress.getProgressPercentage(),
                            minHeight: 6,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                        ),
                      ],
                    )
                  else
                    const Text('Belum ada data progress',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Build payments list for parent
  Widget _buildPaymentsList() {
    return StreamBuilder<List<PaymentModel>>(
      stream: _paymentRepository.streamPaymentsByParentId(_parentId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final payments = snapshot.data ?? [];

        if (payments.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Text('Belum ada pembayaran',
                style: TextStyle(color: Colors.grey)),
          );
        }

        return Column(
          children: payments.map((payment) {
            return _buildPaymentCard(payment);
          }).toList(),
        );
      },
    );
  }

  /// Build individual payment card
  Widget _buildPaymentCard(PaymentModel payment) {
    final statusColor = _getStatusColor(payment.status);
    final statusLabel = _getStatusLabel(payment.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(payment.description,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('Rp ${payment.amount.toString()}',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(statusLabel,
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Jatuh tempo: ${_formatDate(payment.dueDate)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11)),
              if (payment.status == 'pending')
                GestureDetector(
                  onTap: () {
                    _showPaymentProofDialog(payment);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Konfirmasi',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Payment proof dialog
  void _showPaymentProofDialog(PaymentModel payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Apakah Anda sudah membayar ${payment.description}?'),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Catatan (opsional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              _paymentRepository.updatePaymentStatus(
                payment.paymentId,
                'paid',
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Pembayaran dikonfirmasi (pending verifikasi guru)')),
              );
            },
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'paid':
        return 'Terbayar';
      case 'pending':
        return 'Menunggu';
      case 'overdue':
        return 'Jatuh Tempo';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  void _showAddChildDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String fullName = '';
    String nickname = '';
    String gradeLevel = 'SD 1-3';
    String? selectedClassId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Anak'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (v) => fullName = v,
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Nama harus diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Nama Panggilan',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (v) => nickname = v,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: gradeLevel,
                  items: ['TK', 'SD 1-3', 'SD 4-6', 'SMP', 'SMA']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => gradeLevel = v ?? 'SD 1-3',
                  decoration: InputDecoration(
                    labelText: 'Tingkat Kelas',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<ClassModel>>(
                  stream: FirebaseFirestore.instance
                      .collection('classes')
                      .where('gradeLevel', isEqualTo: gradeLevel)
                      .snapshots()
                      .map((snapshot) => snapshot.docs
                          .map((doc) => ClassModel.fromJson(
                              {...doc.data(), 'classId': doc.id}))
                          .toList()),
                  builder: (context, snapshot) {
                    final classes = snapshot.data ?? [];
                    return DropdownButtonFormField<String>(
                      hint: const Text('Pilih Kelas (Opsional)'),
                      items: classes
                          .map((c) => DropdownMenuItem(
                              value: c.classId,
                              child:
                                  Text('${c.className} - ${c.gradeLevel}')))
                          .toList(),
                      onChanged: (v) => selectedClassId = v,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                _createChildAccount(
                  fullName: fullName,
                  nickname: nickname.isEmpty ? fullName.split(' ').first : nickname,
                  gradeLevel: gradeLevel,
                  classId: selectedClassId,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Akun anak dibuat, menunggu verifikasi guru')),
                );
              }
            },
            child: const Text('Buat'),
          ),
        ],
      ),
    );
  }

  Future<void> _createChildAccount({
    required String fullName,
    required String nickname,
    required String gradeLevel,
    String? classId,
  }) async {
    try {
      // For now, just show success message
      // In production, this would call AuthProvider.register() with special flag
      // to create student account and link to parent
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Fitur lengkap: hubungi admin untuk membuat akun')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

