import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/colors.dart';
import '../widgets/teacher_app_bar.dart';
import '../providers/teacher_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/models/student_model.dart';
import '../../../data/repositories/student_repository.dart';

class HalamanKelolaMurid extends StatefulWidget {
  const HalamanKelolaMurid({super.key});

  @override
  State<HalamanKelolaMurid> createState() => _HalamanKelolaMuridState();
}

class _HalamanKelolaMuridState extends State<HalamanKelolaMurid> {
  int _selectedMenuIndex = 7;
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'Semua';
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<TeacherProvider>().loadTeacherData(user.userId!);
      }
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TeacherScaffold(
      title: 'Kelola Murid',
      selectedMenuIndex: _selectedMenuIndex,
      onMenuSelected: (index) => setState(() => _selectedMenuIndex = index),
      onNotificationTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifikasi')),
        );
      },
      body: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          if (teacherProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(teacherProvider.students.length),
                      const SizedBox(height: 24),
                      _buildSearchAndFilter(),
                      const SizedBox(height: 24),
                      _buildMuridList(teacherProvider.students),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(int totalStudents) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.people, color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kelola Data Murid',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: $totalStudents murid terdaftar',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showAddEditDialog(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Tambah'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Cari nama atau kelas...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        PopupMenuButton<String>(
          initialValue: _filterStatus,
          onSelected: (value) => setState(() => _filterStatus = value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list),
                const SizedBox(width: 8),
                Text(_filterStatus),
              ],
            ),
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'Semua', child: Text('Semua')),
            // Note: Status might not be available in StudentModel directly unless added
            // For now keeping simpler filter
            const PopupMenuItem(value: 'SD', child: Text('SD')),
            const PopupMenuItem(value: 'SMP', child: Text('SMP')),
          ],
        ),
      ],
    );
  }

  Widget _buildMuridList(List<StudentModel> students) {
    if (students.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Tidak ada murid ditemukan',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    final filteredList = students.where((student) {
      final matchesSearch = student.fullName
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          (student.gradeLevel
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()));
      // Simplified status filter based on grade level for now as pseudo-status
      final matchesFilter = _filterStatus == 'Semua' ||
          student.gradeLevel.contains(_filterStatus);
      return matchesSearch && matchesFilter;
    }).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final student = filteredList[index];
        return _buildMuridCard(student);
      },
    );
  }

  Widget _buildMuridCard(StudentModel student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          radius: 28,
          backgroundImage: student.avatarUrl != null
              ? NetworkImage(student.avatarUrl!)
              : null,
          child: student.avatarUrl == null
              ? Text(
                  student.fullName.isNotEmpty
                      ? student.fullName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                )
              : null,
        ),
        title: Text(
          student.fullName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.class_, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  student.gradeLevel,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Aktif', // Placeholder status
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'detail',
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 20, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  const Text('Detail'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined,
                      size: 20, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  const Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline,
                      size: 20, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  const Text('Hapus'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'detail') {
              _showDetailDialog(student);
            } else if (value == 'edit') {
              _showAddEditDialog(student: student);
            } else if (value == 'delete') {
              _showDeleteDialog(student);
            }
          },
        ),
      ),
    );
  }

  void _showAddEditDialog({StudentModel? student}) {
    final isEdit = student != null;
    final fullNameController =
        TextEditingController(text: student?.fullName ?? '');
    final gradeLevelController =
        TextEditingController(text: student?.gradeLevel ?? '');
    final nicknameController =
        TextEditingController(text: student?.nickname ?? '');

    // Note: Email dan Phone ada di UserModel, bukan StudentModel.
    // Untuk CRUD sederhana ini kita simpan data StudentModel dulu.

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isEdit ? Icons.edit : Icons.person_add,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(isEdit ? 'Edit Murid' : 'Tambah Murid'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nicknameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Panggilan',
                    prefixIcon: const Icon(Icons.face),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: gradeLevelController,
                  decoration: InputDecoration(
                    labelText: 'Kelas / Grade',
                    prefixIcon: const Icon(Icons.class_),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (fullNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama harus diisi')),
                  );
                  return;
                }

                try {
                  final teacherProvider = context.read<TeacherProvider>();
                  final studentRepo =
                      StudentRepository(); // Menggunakan repo langsung untuk create

                  if (isEdit) {
                    final updatedStudent = student!.copyWith(
                      fullName: fullNameController.text,
                      nickname: nicknameController.text,
                      gradeLevel: gradeLevelController.text,
                    );
                    await studentRepo.updateStudent(
                        student.studentId!, updatedStudent);
                  } else {
                    // Create new student
                    // Generate temp UID since we are not creating full Auth user here yet
                    final tempUserId = const Uuid().v4();
                    final newStudent = StudentModel(
                      userId: tempUserId,
                      fullName: fullNameController.text,
                      nickname: nicknameController.text,
                      gradeLevel: gradeLevelController.text,
                      createdAt: DateTime.now(),
                    );

                    // Create in Firestore
                    await studentRepo.createStudent(newStudent);

                    // Note: Idealnya kita juga add ke User collection dan Auth,
                    // tapi sesuai instruksi cukup CRUD data murid dulu.
                  }

                  // Reload data
                  final user = context.read<AuthProvider>().user;
                  if (user != null) {
                    await teacherProvider.loadTeacherData(user.userId!);
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEdit
                            ? 'Murid berhasil diupdate'
                            : 'Murid berhasil ditambahkan'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal: $e')),
                  );
                }
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text(isEdit ? 'Simpan' : 'Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(StudentModel student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: student.avatarUrl != null
                  ? NetworkImage(student.avatarUrl!)
                  : null,
              child: student.avatarUrl == null
                  ? Text(
                      student.fullName.isNotEmpty
                          ? student.fullName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                student.fullName,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.face, 'Nama Panggilan', student.nickname),
            _buildDetailRow(Icons.class_, 'Kelas', student.gradeLevel),
            _buildDetailRow(Icons.star, 'Total Poin', '${student.totalPoints}'),
            _buildDetailRow(
              Icons.calendar_today,
              'Tanggal Daftar',
              '${student.createdAt.day}/${student.createdAt.month}/${student.createdAt.year}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(StudentModel student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Hapus Murid'),
          ],
        ),
        content: Text(
            'Apakah Anda yakin ingin menghapus murid "${student.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Delete from Firestore
                await StudentRepository().deleteStudent(student.studentId!);

                // Refresh data
                // Note: Since TeacherProvider loads students from classes,
                // deleting a student might not remove them from the class list automatically
                // if we don't reload.
                final user = context.read<AuthProvider>().user;
                if (user != null) {
                  await context
                      .read<TeacherProvider>()
                      .loadTeacherData(user.userId!);
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Murid "${student.fullName}" berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
