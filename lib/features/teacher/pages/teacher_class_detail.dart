import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/colors.dart';
import '../widgets/teacher_app_bar.dart';
import '../providers/teacher_provider.dart';
import '../../../core/models/class_model.dart';
import '../../../core/models/session_model.dart';
import '../../../core/models/student_model.dart';
import '../../../data/repositories/student_repository.dart';
import 'teacher_session_detail.dart';

class TeacherClassDetailPage extends StatefulWidget {
  final ClassModel classModel;

  const TeacherClassDetailPage({
    super.key,
    required this.classModel,
  });

  @override
  State<TeacherClassDetailPage> createState() => _TeacherClassDetailPageState();
}

class _TeacherClassDetailPageState extends State<TeacherClassDetailPage> {
  @override
  void initState() {
    super.initState();
    // Reload teacher data to ensure we have latest class info
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final teacherProvider = context.read<TeacherProvider>();
      if (teacherProvider.currentTeacher?.userId != null) {
        teacherProvider.loadTeacherData(teacherProvider.currentTeacher!.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TeacherScaffold(
      title: widget.classModel.className,
      selectedMenuIndex: 1,
      onMenuSelected: (index) {},
      onNotificationTap: () {},
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSessionDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          if (teacherProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Get updated class model from provider
          final classModel = teacherProvider.getClassById(widget.classModel.classId!) ?? widget.classModel;
          final students = teacherProvider.getStudentsByClassId(classModel.classId!);
          final sessions = teacherProvider.getSessionsByClassId(classModel.classId!);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildClassInfoCard(context, classModel, teacherProvider),
                const SizedBox(height: 16),
                _buildStudentsSection(context, students, classModel),
                const SizedBox(height: 16),
                _buildSessionsSection(context, sessions, teacherProvider, classModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildClassInfoCard(BuildContext context, ClassModel classModel, TeacherProvider teacherProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.class_,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classModel.className,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${classModel.gradeLevel} • ${classModel.type}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditClassDialog(context),
                  tooltip: 'Edit Kelas',
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.schedule, 'Jadwal', classModel.schedule),
            _buildInfoRow(Icons.people, 'Murid', '${classModel.studentIds.length} / ${classModel.maxStudents}'),
            _buildInfoRow(Icons.monetization_on, 'Biaya per Sesi', 'Rp ${classModel.pricePerSession}'),
            _buildInfoRow(Icons.event, 'Total Sesi', '${classModel.totalSessions} sesi'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsSection(BuildContext context, List<StudentModel> students, ClassModel classModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Daftar Murid',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${students.length}/${classModel.maxStudents} Murid',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (students.length < classModel.maxStudents)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showAddStudentDialog(context),
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Tambah Murid'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (students.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.people_outline, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Text(
                        'Belum ada murid',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  return _buildStudentItem(context, students[index]);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentItem(BuildContext context, StudentModel student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
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
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  student.gradeLevel,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
            onPressed: () => _showRemoveStudentDialog(context, student),
            tooltip: 'Hapus dari kelas',
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsSection(
    BuildContext context,
    List<SessionModel> sessions,
    TeacherProvider teacherProvider,
    ClassModel classModel,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event_note, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Sesi Pertemuan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${sessions.length} Sesi',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (sessions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.event_busy, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Text(
                        'Belum ada sesi pertemuan',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tekan tombol + untuk membuat sesi baru',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  return _buildSessionItem(context, sessions[index], teacherProvider, classModel);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem(
    BuildContext context,
    SessionModel session,
    TeacherProvider teacherProvider,
    ClassModel classModel,
  ) {
    final dateStr = '${session.date.day}/${session.date.month}/${session.date.year}';
    final presentCount = session.attendance
        .where((a) => a.status == 'present')
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeacherSessionDetailPage(
                session: session,
                classModel: classModel,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'S${session.sessionNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.material,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.people, size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '$presentCount hadir',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateSessionDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final materialController = TextEditingController();
    final objectiveController = TextEditingController();
    final dateController = TextEditingController();
    DateTime? selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Buat Sesi Pertemuan Baru'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: materialController,
                    decoration: const InputDecoration(
                      labelText: 'Materi Pembelajaran',
                      hintText: 'Contoh: Aljabar Dasar',
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: objectiveController,
                    decoration: const InputDecoration(
                      labelText: 'Tujuan Pembelajaran',
                      hintText: 'Contoh: Siswa dapat menyelesaikan persamaan linear',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Pertemuan',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setStateDialog(() {
                          selectedDate = date;
                          dateController.text =
                              '${date.day}/${date.month}/${date.year}';
                        });
                      }
                    },
                    validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
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
                if (formKey.currentState!.validate() && selectedDate != null) {
                  final teacherProvider = context.read<TeacherProvider>();
                  // Get updated class model
                  final updatedClass = teacherProvider.getClassById(widget.classModel.classId!) ?? widget.classModel;
                  final sessions = teacherProvider.getSessionsByClassId(updatedClass.classId!);
                  final nextSessionNumber = sessions.isEmpty
                      ? 1
                      : sessions.map((s) => s.sessionNumber).reduce((a, b) => a > b ? a : b) + 1;

                  final newSession = SessionModel(
                    classId: updatedClass.classId!,
                    sessionNumber: nextSessionNumber,
                    date: selectedDate!,
                    material: materialController.text,
                    learningObjective: objectiveController.text.isEmpty
                        ? null
                        : objectiveController.text,
                    createdAt: DateTime.now(),
                  );

                  final success = await teacherProvider.createSession(newSession);

                  if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sesi pertemuan berhasil dibuat'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(teacherProvider.error ?? 'Gagal membuat sesi'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context) async {
    final teacherProvider = context.read<TeacherProvider>();
    
    // Get updated class model
    final classModel = teacherProvider.getClassById(widget.classModel.classId!) ?? widget.classModel;
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Get all students from repository
    final studentRepository = StudentRepository();
    List<StudentModel> allStudents = [];
    try {
      allStudents = await studentRepository.getAllStudents();
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat daftar murid: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      Navigator.pop(context); // Close loading
    }

    final currentStudentIds = classModel.studentIds;
    final availableStudents = allStudents.where((s) {
      return s.studentId != null && !currentStudentIds.contains(s.studentId);
    }).toList();

    if (availableStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada murid yang bisa ditambahkan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (classModel.studentIds.length >= classModel.maxStudents) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kelas sudah penuh (${classModel.maxStudents} murid)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tambah Murid ke Kelas'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableStudents.length,
            itemBuilder: (context, index) {
              final student = availableStudents[index];
              return ListTile(
                leading: CircleAvatar(
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
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                title: Text(student.fullName),
                subtitle: Text(student.gradeLevel),
                onTap: () async {
                  if (student.studentId == null) return;

                  final currentClass = teacherProvider.getClassById(widget.classModel.classId!) ?? widget.classModel;
                  final success = await teacherProvider.addStudentToClass(
                    currentClass.classId!,
                    student.studentId!,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                      // Reload teacher data to get updated class
                      if (teacherProvider.currentTeacher?.userId != null) {
                        await teacherProvider.loadTeacherData(
                          teacherProvider.currentTeacher!.userId,
                        );
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${student.fullName} berhasil ditambahkan ke kelas'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(teacherProvider.error ?? 'Gagal menambahkan murid'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  void _showRemoveStudentDialog(BuildContext context, StudentModel student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Murid dari Kelas'),
        content: Text(
          'Apakah Anda yakin ingin menghapus ${student.fullName} dari kelas ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (student.studentId == null) return;

              final teacherProvider = context.read<TeacherProvider>();
              final currentClass = teacherProvider.getClassById(widget.classModel.classId!) ?? widget.classModel;
              final success = await teacherProvider.removeStudentFromClass(
                currentClass.classId!,
                student.studentId!,
              );

              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  // Reload teacher data to get updated class
                  if (teacherProvider.currentTeacher?.userId != null) {
                    await teacherProvider.loadTeacherData(
                      teacherProvider.currentTeacher!.userId,
                    );
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${student.fullName} berhasil dihapus dari kelas'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(teacherProvider.error ?? 'Gagal menghapus murid'),
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

  void _showEditClassDialog(BuildContext context) {
    final teacherProvider = context.read<TeacherProvider>();
    // Get updated class model
    final classModel = teacherProvider.getClassById(widget.classModel.classId!) ?? widget.classModel;
    
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: classModel.className);
    final gradeController = TextEditingController(text: classModel.gradeLevel);
    final scheduleController = TextEditingController(text: classModel.schedule);
    final maxStudentsController = TextEditingController(text: classModel.maxStudents.toString());
    final priceController = TextEditingController(text: classModel.pricePerSession.toString());
    final totalSessionsController = TextEditingController(text: classModel.totalSessions.toString());
    String selectedType = classModel.type;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Kelas'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama Kelas *'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: gradeController,
                    decoration: const InputDecoration(
                        labelText: 'Jenjang *', hintText: 'Contoh: SD Kelas 1'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: scheduleController,
                    decoration: const InputDecoration(
                        labelText: 'Jadwal *', hintText: 'Contoh: Senin 15:00-16:00'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'Tipe Kelas *'),
                    items: const [
                      DropdownMenuItem(value: 'regular', child: Text('Reguler')),
                      DropdownMenuItem(value: 'private', child: Text('Private')),
                      DropdownMenuItem(value: 'semi_private', child: Text('Semi Private')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setStateDialog(() {
                          selectedType = v;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: maxStudentsController,
                    decoration: const InputDecoration(
                        labelText: 'Maksimal Murid *', hintText: 'Contoh: 10'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Wajib diisi';
                      final num = int.tryParse(v);
                      if (num == null || num <= 0) return 'Harus angka positif';
                      if (num < classModel.studentIds.length) {
                        return 'Tidak boleh kurang dari jumlah murid saat ini (${classModel.studentIds.length})';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                        labelText: 'Biaya per Sesi (Rp) *', hintText: 'Contoh: 50000'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Wajib diisi';
                      final num = int.tryParse(v);
                      if (num == null || num < 0) return 'Harus angka >= 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: totalSessionsController,
                    decoration: const InputDecoration(
                        labelText: 'Total Sesi *', hintText: 'Contoh: 12'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Wajib diisi';
                      final num = int.tryParse(v);
                      if (num == null || num <= 0) return 'Harus angka positif';
                      return null;
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
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final updatedClass = classModel.copyWith(
                    className: nameController.text,
                    gradeLevel: gradeController.text,
                    type: selectedType,
                    maxStudents: int.parse(maxStudentsController.text),
                    pricePerSession: int.parse(priceController.text),
                    totalSessions: int.parse(totalSessionsController.text),
                    schedule: scheduleController.text,
                  );

                  final success = await teacherProvider.updateClass(updatedClass);

                  if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                      // Reload teacher data to get updated class
                      if (teacherProvider.currentTeacher?.userId != null) {
                        await teacherProvider.loadTeacherData(
                          teacherProvider.currentTeacher!.userId,
                        );
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kelas berhasil diperbarui'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(teacherProvider.error ?? 'Gagal memperbarui kelas'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
