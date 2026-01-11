import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/colors.dart';
import '../widgets/teacher_app_bar.dart';
import '../providers/teacher_provider.dart';
import '../../../core/models/session_model.dart';
import '../../../core/models/class_model.dart';
import '../../../core/models/student_model.dart';
import '../../../core/models/progress_note_model.dart';
import '../../../data/repositories/progress_note_repository.dart';
import '../../../data/repositories/session_repository.dart';

class TeacherSessionDetailPage extends StatefulWidget {
  final SessionModel session;
  final ClassModel classModel;

  const TeacherSessionDetailPage({
    super.key,
    required this.session,
    required this.classModel,
  });

  @override
  State<TeacherSessionDetailPage> createState() => _TeacherSessionDetailPageState();
}

class _TeacherSessionDetailPageState extends State<TeacherSessionDetailPage> {
  final ProgressNoteRepository _progressNoteRepository = ProgressNoteRepository();
  final SessionRepository _sessionRepository = SessionRepository();
  List<ProgressNoteModel> _progressNotes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProgressNotes();
  }

  Future<void> _loadProgressNotes() async {
    if (widget.session.sessionId == null) return;
    
    setState(() => _isLoading = true);
    try {
      _progressNotes = await _progressNoteRepository.getProgressNotesBySessionId(
        widget.session.sessionId!,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat catatan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TeacherScaffold(
      title: 'Sesi ${widget.session.sessionNumber}',
      selectedMenuIndex: 1,
      onMenuSelected: (index) {},
      onNotificationTap: () {},
      body: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          final students = teacherProvider.getStudentsByClassId(widget.classModel.classId!);
          
          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSessionInfoCard(teacherProvider),
                      const SizedBox(height: 16),
                      _buildLearningObjectiveCard(teacherProvider),
                      const SizedBox(height: 16),
                      _buildAttendanceSection(students, teacherProvider),
                      const SizedBox(height: 16),
                      _buildProgressNotesSection(students),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildSessionInfoCard(TeacherProvider teacherProvider) {
    final dateStr = '${widget.session.date.day}/${widget.session.date.month}/${widget.session.date.year}';
    
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
                    Icons.event_note,
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
                        'Sesi ${widget.session.sessionNumber}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
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
                  onPressed: () => _showEditSessionDialog(teacherProvider),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.book, 'Materi', widget.session.material),
            if (widget.session.teacherNotes != null && widget.session.teacherNotes!.isNotEmpty)
              _buildInfoRow(Icons.note, 'Catatan', widget.session.teacherNotes!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningObjectiveCard(TeacherProvider teacherProvider) {
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
                const Icon(Icons.flag, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Tujuan Pembelajaran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _showEditObjectiveDialog(teacherProvider),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.session.learningObjective ?? 'Belum ada tujuan pembelajaran',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.session.learningObjective != null
                      ? AppColors.textDark
                      : Colors.grey.shade500,
                  fontStyle: widget.session.learningObjective != null
                      ? FontStyle.normal
                      : FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceSection(
    List<StudentModel> students,
    TeacherProvider teacherProvider,
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
                const Icon(Icons.check_circle, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Absensi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showAttendanceDialog(students, teacherProvider),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (students.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Belum ada murid di kelas ini',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  final attendance = widget.session.attendance.firstWhere(
                    (a) => a.studentId == student.studentId,
                    orElse: () => Attendance(
                      studentId: student.studentId ?? '',
                      status: 'absent',
                    ),
                  );
                  return _buildAttendanceItem(student, attendance);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceItem(StudentModel student, Attendance attendance) {
    final statusColor = attendance.status == 'present'
        ? Colors.green
        : attendance.status == 'excused'
            ? Colors.orange
            : Colors.red;
    final statusIcon = attendance.status == 'present'
        ? Icons.check_circle
        : attendance.status == 'excused'
            ? Icons.info
            : Icons.cancel;
    final statusText = attendance.status == 'present'
        ? 'Hadir'
        : attendance.status == 'excused'
            ? 'Izin'
            : 'Tidak Hadir';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.1),
            backgroundImage: student.avatarUrl != null
                ? NetworkImage(student.avatarUrl!)
                : null,
            child: student.avatarUrl == null
                ? Icon(statusIcon, color: statusColor, size: 20)
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
                if (attendance.reason != null && attendance.reason!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    attendance.reason!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressNotesSection(List<StudentModel> students) {
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
                const Icon(Icons.note_add, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Catatan Perkembangan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (students.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Belum ada murid di kelas ini',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  final note = _progressNotes.firstWhere(
                    (n) => n.studentId == student.studentId,
                    orElse: () => ProgressNoteModel(
                      sessionId: widget.session.sessionId ?? '',
                      studentId: student.studentId ?? '',
                      classId: widget.classModel.classId ?? '',
                      note: '',
                      createdAt: DateTime.now(),
                    ),
                  );
                  return _buildProgressNoteItem(student, note);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressNoteItem(StudentModel student, ProgressNoteModel note) {
    final hasNote = note.noteId != null && note.note.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                child: Text(
                  student.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _showProgressNoteDialog(student, note),
                icon: Icon(
                  hasNote ? Icons.edit : Icons.add,
                  size: 18,
                ),
                label: Text(hasNote ? 'Edit' : 'Tambah'),
              ),
            ],
          ),
          if (hasNote) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                note.note,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textDark,
                ),
              ),
            ),
            if (note.attachmentUrl != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.attach_file, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'File terlampir',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Belum ada catatan',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showEditSessionDialog(TeacherProvider teacherProvider) {
    final materialController = TextEditingController(text: widget.session.material);
    final notesController = TextEditingController(text: widget.session.teacherNotes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Sesi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: materialController,
                decoration: const InputDecoration(
                  labelText: 'Materi Pembelajaran',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Catatan',
                ),
                maxLines: 3,
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
              if (widget.session.sessionId == null) return;

              final updatedSession = widget.session.copyWith(
                material: materialController.text,
                teacherNotes: notesController.text.isEmpty ? null : notesController.text,
              );

              try {
                await _sessionRepository.updateSession(
                  widget.session.sessionId!,
                  updatedSession,
                );

                await teacherProvider.loadTeacherData(
                  teacherProvider.currentTeacher!.userId,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sesi berhasil diperbarui'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal memperbarui: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditObjectiveDialog(TeacherProvider teacherProvider) {
    final objectiveController = TextEditingController(
      text: widget.session.learningObjective ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Tujuan Pembelajaran'),
        content: TextField(
          controller: objectiveController,
          decoration: const InputDecoration(
            labelText: 'Tujuan Pembelajaran',
            hintText: 'Contoh: Siswa dapat menyelesaikan persamaan linear',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (widget.session.sessionId == null) return;

              final updatedSession = widget.session.copyWith(
                learningObjective: objectiveController.text.isEmpty
                    ? null
                    : objectiveController.text,
              );

              try {
                await _sessionRepository.updateSession(
                  widget.session.sessionId!,
                  updatedSession,
                );

                await teacherProvider.loadTeacherData(
                  teacherProvider.currentTeacher!.userId,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tujuan pembelajaran berhasil diperbarui'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal memperbarui: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showAttendanceDialog(
    List<StudentModel> students,
    TeacherProvider teacherProvider,
  ) {
    final Map<String, Attendance> attendanceMap = {};
    for (final student in students) {
      if (student.studentId != null) {
        attendanceMap[student.studentId!] = widget.session.attendance.firstWhere(
          (a) => a.studentId == student.studentId,
          orElse: () => Attendance(
            studentId: student.studentId!,
            status: 'absent',
          ),
        );
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Absensi'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: students.map((student) {
                  if (student.studentId == null) return const SizedBox.shrink();
                  
                  final attendance = attendanceMap[student.studentId!]!;
                  final reasonController = TextEditingController(
                    text: attendance.reason ?? '',
                  );

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Text('Hadir'),
                                selected: attendance.status == 'present',
                                onSelected: (selected) {
                                  if (selected) {
                                    setStateDialog(() {
                                      attendanceMap[student.studentId!] = Attendance(
                                        studentId: student.studentId!,
                                        status: 'present',
                                        reason: null,
                                      );
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ChoiceChip(
                                label: const Text('Izin'),
                                selected: attendance.status == 'excused',
                                onSelected: (selected) {
                                  if (selected) {
                                    setStateDialog(() {
                                      attendanceMap[student.studentId!] = Attendance(
                                        studentId: student.studentId!,
                                        status: 'excused',
                                        reason: reasonController.text.isEmpty
                                            ? null
                                            : reasonController.text,
                                      );
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ChoiceChip(
                                label: const Text('Tidak Hadir'),
                                selected: attendance.status == 'absent',
                                onSelected: (selected) {
                                  if (selected) {
                                    setStateDialog(() {
                                      attendanceMap[student.studentId!] = Attendance(
                                        studentId: student.studentId!,
                                        status: 'absent',
                                        reason: reasonController.text.isEmpty
                                            ? null
                                            : reasonController.text,
                                      );
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        if (attendance.status != 'present') ...[
                          const SizedBox(height: 8),
                          TextField(
                            controller: reasonController,
                            decoration: const InputDecoration(
                              labelText: 'Alasan',
                              hintText: 'Masukkan alasan',
                              isDense: true,
                            ),
                            onChanged: (value) {
                              setStateDialog(() {
                                attendanceMap[student.studentId!] = Attendance(
                                  studentId: student.studentId!,
                                  status: attendance.status,
                                  reason: value.isEmpty ? null : value,
                                );
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
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
                if (widget.session.sessionId == null) return;

                final updatedAttendance = attendanceMap.values.toList();

                try {
                  await _sessionRepository.updateAttendance(
                    widget.session.sessionId!,
                    updatedAttendance,
                  );

                  await teacherProvider.loadTeacherData(
                    teacherProvider.currentTeacher!.userId,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Absensi berhasil diperbarui'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal memperbarui: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
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

  void _showProgressNoteDialog(StudentModel student, ProgressNoteModel note) {
    final noteController = TextEditingController(text: note.note);
    final hasNote = note.noteId != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(hasNote ? 'Edit Catatan' : 'Tambah Catatan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                student.fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Catatan Perkembangan',
                  hintText: 'Masukkan catatan perkembangan anak...',
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          if (hasNote)
            TextButton(
              onPressed: () async {
                try {
                  await _progressNoteRepository.deleteProgressNote(note.noteId!);
                  await _loadProgressNotes();
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Catatan berhasil dihapus'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menghapus: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Hapus',
                style: TextStyle(color: Colors.red),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (widget.session.sessionId == null ||
                  student.studentId == null ||
                  widget.classModel.classId == null) {
                return;
              }

              try {
                if (hasNote) {
                  // Update existing note
                  final updatedNote = note.copyWith(
                    note: noteController.text,
                  );
                  await _progressNoteRepository.updateProgressNote(
                    note.noteId!,
                    updatedNote,
                  );
                } else {
                  // Create new note
                  final newNote = ProgressNoteModel(
                    sessionId: widget.session.sessionId!,
                    studentId: student.studentId!,
                    classId: widget.classModel.classId!,
                    note: noteController.text,
                    createdAt: DateTime.now(),
                  );
                  await _progressNoteRepository.createProgressNote(newNote);
                }

                await _loadProgressNotes();

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(hasNote
                          ? 'Catatan berhasil diperbarui'
                          : 'Catatan berhasil ditambahkan'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menyimpan: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(hasNote ? 'Simpan' : 'Tambah'),
          ),
        ],
      ),
    );
  }
}
