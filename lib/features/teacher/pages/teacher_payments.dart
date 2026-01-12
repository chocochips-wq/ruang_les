import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/colors.dart';
import '../../../data/repositories/payment_repository.dart';
import '../../../data/repositories/class_repository.dart';
import '../../../core/models/class_model.dart';
import '../../../core/models/payment_model.dart';
import '../../../core/models/student_model.dart';
import '../widgets/teacher_app_bar.dart';
import '../widgets/teacher_bottom_nav.dart';

class PengajarPembayaran extends StatefulWidget {
  const PengajarPembayaran({super.key});

  @override
  State<PengajarPembayaran> createState() => _PengajarPembayaranState();
}

class _PengajarPembayaranState extends State<PengajarPembayaran> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PaymentRepository _paymentRepository = PaymentRepository();
  final ClassRepository _classRepository = ClassRepository();
  String? _teacherId;
  String? _selectedFilter = 'all'; // all, pending, paid, overdue
  int _selectedMenuIndex = 6; // Index for Pembayaran in drawer

  @override
  void initState() {
    super.initState();
    _teacherId = _auth.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return TeacherScaffold(
      title: 'Kelola Pembayaran',
      selectedMenuIndex: _selectedMenuIndex,
      onMenuSelected: (index) {
        setState(() {
          _selectedMenuIndex = index;
        });
      },
      bottomNavigationBar: const TeacherBottomNav(currentIndex: 1),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showCreatePaymentDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _teacherId == null
          ? const Center(child: Text('Tidak ada pengguna yang login'))
          : Column(
              children: [
                // Filter buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: ['all', 'pending', 'paid', 'overdue']
                        .map((filter) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _selectedFilter = filter);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _selectedFilter == filter
                                        ? AppColors.primary
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: AppColors.primary, width: 1),
                                  ),
                                  child: Text(
                                    _getFilterLabel(filter),
                                    style: TextStyle(
                                      color: _selectedFilter == filter
                                          ? Colors.white
                                          : AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                Expanded(child: _buildPaymentsList()),
              ],
            ),
    );
  }

  Widget _buildPaymentsList() {
    return StreamBuilder<List<PaymentModel>>(
      stream: _paymentRepository.streamPaymentsByTeacherId(_teacherId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle error - show message instead of crashing/logout
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat data pembayaran',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pastikan Firestore index sudah dibuat',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        var payments = snapshot.data ?? [];

        // Apply filter
        if (_selectedFilter != 'all') {
          payments =
              payments.where((p) => p.status == _selectedFilter).toList();
        }

        if (payments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  _selectedFilter == 'all'
                      ? 'Belum ada pembayaran'
                      : 'Belum ada pembayaran ${_getFilterLabel(_selectedFilter!).toLowerCase()}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final payment = payments[index];
            return _buildPaymentItem(context, payment);
          },
        );
      },
    );
  }

  Widget _buildPaymentItem(BuildContext context, PaymentModel payment) {
    final statusColor = _getStatusColor(payment.status);
    final statusLabel = _getStatusLabel(payment.status);
    final isOverdue = payment.dueDate.isBefore(DateTime.now()) &&
        payment.status != 'paid' &&
        payment.status != 'cancelled';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
                    Text('Rp ${payment.amount.toString()}',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
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
                  if (isOverdue)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('⚠️ Jatuh Tempo',
                          style: TextStyle(
                              color: Colors.red[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 10)),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Jatuh tempo: ${_formatDate(payment.dueDate)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11)),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showEditPaymentDialog(context, payment),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('Edit',
                          style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 10)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _showDeleteConfirm(context, payment.paymentId),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('Hapus',
                          style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreatePaymentDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    int amount = 0;
    DateTime dueDate = DateTime.now().add(const Duration(days: 30));
    String? selectedClassId;
    String? selectedStudentId;
    String? selectedParentId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat Pembayaran Baru'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Select Class
                StreamBuilder<List<ClassModel>>(
                  stream:
                      _classRepository.streamClassesByTeacherId(_teacherId!),
                  builder: (context, snapshot) {
                    final classes = snapshot.data ?? [];
                    return DropdownButtonFormField<String>(
                      hint: const Text('Pilih Kelas'),
                      items: classes
                          .map((c) => DropdownMenuItem(
                              value: c.classId,
                              child: Text('${c.className} - ${c.gradeLevel}')))
                          .toList(),
                      onChanged: (value) => selectedClassId = value,
                      validator: (v) =>
                          v == null ? 'Kelas harus dipilih' : null,
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Select Student (only show if class is selected)
                if (selectedClassId != null)
                  StreamBuilder<List<StudentModel>>(
                    stream: FirebaseFirestore.instance
                        .collection('classes')
                        .doc(selectedClassId)
                        .snapshots()
                        .asyncMap((classDoc) async {
                      final classData = classDoc.data();
                      final studentIds =
                          List<String>.from(classData?['studentIds'] ?? []);
                      final students = <StudentModel>[];
                      for (final id in studentIds) {
                        final studentDoc = await FirebaseFirestore.instance
                            .collection('students')
                            .doc(id)
                            .get();
                        if (studentDoc.exists) {
                          students.add(StudentModel.fromFirestore(studentDoc));
                        }
                      }
                      return students;
                    }),
                    builder: (context, snapshot) {
                      final students = snapshot.data ?? [];
                      return DropdownButtonFormField<String>(
                        hint: const Text('Pilih Siswa'),
                        items: students
                            .map((s) => DropdownMenuItem(
                                value: s.studentId,
                                child: Text(s.nickname ?? s.fullName ?? '')))
                            .toList(),
                        onChanged: (value) => selectedStudentId = value,
                        validator: (v) =>
                            v == null ? 'Siswa harus dipilih' : null,
                      );
                    },
                  ),
                if (selectedStudentId != null) ...[
                  const SizedBox(height: 12),
                  FutureBuilder<String?>(
                    future: FirebaseFirestore.instance
                        .collection('students')
                        .doc(selectedStudentId)
                        .get()
                        .then((doc) => doc.data()?['parentId'] as String?),
                    builder: (context, snapshot) {
                      selectedParentId = snapshot.data;
                      return const SizedBox.shrink();
                    },
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Jumlah (Rp)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => amount = int.tryParse(v) ?? 0,
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Jumlah tidak boleh kosong' : null,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) dueDate = picked;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Jatuh tempo: ${_formatDate(dueDate)}'),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
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
            onPressed: () async {
              if (formKey.currentState!.validate() &&
                  selectedStudentId != null &&
                  selectedParentId != null &&
                  selectedClassId != null) {
                try {
                  await _paymentRepository.createPayment(
                    PaymentModel(
                      paymentId:
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      teacherId: _teacherId, // Add teacherId
                      studentId: selectedStudentId!,
                      parentId: selectedParentId!,
                      classId: selectedClassId!,
                      amount: amount,
                      description: 'Pembayaran SPP',
                      dueDate: dueDate,
                      createdAt: DateTime.now(),
                    ),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pembayaran dibuat')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Buat'),
          ),
        ],
      ),
    );
  }

  void _showEditPaymentDialog(BuildContext context, PaymentModel payment) {
    final formKey = GlobalKey<FormState>();
    late int amount = payment.amount;
    late DateTime dueDate = payment.dueDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Pembayaran'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: amount.toString(),
                  decoration: InputDecoration(
                    labelText: 'Jumlah (Rp)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => amount = int.tryParse(v) ?? 0,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) dueDate = picked;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Jatuh tempo: ${_formatDate(dueDate)}'),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
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
            onPressed: () async {
              try {
                await _paymentRepository.updatePayment(
                  payment.paymentId!,
                  amount: amount,
                  dueDate: dueDate,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pembayaran diperbarui')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, String? paymentId) {
    if (paymentId == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pembayaran'),
        content:
            const Text('Apakah Anda yakin ingin menghapus pembayaran ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _paymentRepository.deletePayment(paymentId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pembayaran dihapus')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
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
      case 'cancelled':
        return Colors.grey;
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

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'all':
        return 'Semua';
      case 'pending':
        return 'Menunggu';
      case 'paid':
        return 'Terbayar';
      case 'overdue':
        return 'Jatuh Tempo';
      default:
        return filter;
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
}
