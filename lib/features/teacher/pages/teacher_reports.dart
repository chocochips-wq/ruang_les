import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/colors.dart';
import '../widgets/teacher_app_bar.dart';
import '../providers/teacher_provider.dart';
import '../../../core/models/student_model.dart';
import '../../../core/models/session_model.dart';
import '../../../core/models/progress_note_model.dart';
import '../../../data/repositories/progress_note_repository.dart';

class PengajarNilai extends StatefulWidget {
  const PengajarNilai({super.key});

  @override
  State<PengajarNilai> createState() => _PengajarNilaiState();
}

class _PengajarNilaiState extends State<PengajarNilai> {
  int _selectedMenuIndex = 4;
  final ProgressNoteRepository _progressNoteRepository = ProgressNoteRepository();
  final Map<String, List<ProgressNoteModel>> _progressNotesMap = {};
  final Map<String, Map<String, dynamic>> _studentStatsMap = {};

  @override
  void initState() {
    super.initState();
    _loadProgressNotes();
  }

  Future<void> _loadProgressNotes() async {
    final teacherProvider = context.read<TeacherProvider>();
    final students = teacherProvider.students;

    for (final student in students) {
      if (student.studentId != null) {
        try {
          final notes = await _progressNoteRepository.getProgressNotesByStudentId(
            student.studentId!,
          );
          _progressNotesMap[student.studentId!] = notes;

          // Calculate stats
          final sessions = teacherProvider.sessions;
          int totalSessions = 0;
          int presentCount = 0;
          int absentCount = 0;
          int excusedCount = 0;

          for (final session in sessions) {
            final attendance = session.attendance.firstWhere(
              (a) => a.studentId == student.studentId,
              orElse: () => Attendance(
                studentId: student.studentId!,
                status: 'absent',
              ),
            );

            if (attendance.studentId == student.studentId) {
              totalSessions++;
              if (attendance.status == 'present') {
                presentCount++;
              } else if (attendance.status == 'absent') {
                absentCount++;
              } else if (attendance.status == 'excused') {
                excusedCount++;
              }
            }
          }

          _studentStatsMap[student.studentId!] = {
            'totalSessions': totalSessions,
            'presentCount': presentCount,
            'absentCount': absentCount,
            'excusedCount': excusedCount,
            'attendanceRate': totalSessions > 0
                ? ((presentCount / totalSessions) * 100).round()
                : 0,
          };
        } catch (e) {
          // Handle error
        }
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return TeacherScaffold(
      title: 'Laporan Anak',
      selectedMenuIndex: _selectedMenuIndex,
      onMenuSelected: (index) {
        setState(() => _selectedMenuIndex = index);
      },
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

          final students = teacherProvider.students;

          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_ind_outlined,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada siswa terdaftar',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              return _buildSiswaCard(students[index], teacherProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildSiswaCard(StudentModel siswa, TeacherProvider teacherProvider) {
    final stats = _studentStatsMap[siswa.studentId ?? ''] ?? {};
    final progressNotes = _progressNotesMap[siswa.studentId ?? ''] ?? [];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage:
                siswa.avatarUrl != null ? NetworkImage(siswa.avatarUrl!) : null,
            child: siswa.avatarUrl == null
                ? Text(
                    siswa.fullName.isNotEmpty
                        ? siswa.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.primary),
                  )
                : null,
          ),
          title: Text(
            siswa.fullName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          subtitle: Text(
            'Kelas: ${siswa.gradeLevel}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadReport(siswa, teacherProvider),
            tooltip: 'Download Laporan',
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  // Statistics Section
                  _buildStatsSection(stats),
                  const SizedBox(height: 16),
                  // Progress Notes Section
                  _buildProgressNotesSection(progressNotes, teacherProvider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Kehadiran',
                  '${stats['attendanceRate'] ?? 0}%',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Hadir',
                  '${stats['presentCount'] ?? 0}',
                  Icons.person,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Tidak Hadir',
                  '${stats['absentCount'] ?? 0}',
                  Icons.cancel,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.event,
            'Total Sesi',
            '${stats['totalSessions'] ?? 0} sesi',
            Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressNotesSection(
    List<ProgressNoteModel> progressNotes,
    TeacherProvider teacherProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.note, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Catatan Perkembangan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const Spacer(),
            Text(
              '${progressNotes.length} catatan',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (progressNotes.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Belum ada catatan perkembangan',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: progressNotes.length,
            itemBuilder: (context, index) {
              final note = progressNotes[index];
              final session = teacherProvider.sessions.firstWhere(
                (s) => s.sessionId == note.sessionId,
                orElse: () => SessionModel(
                  classId: '',
                  sessionNumber: 0,
                  date: DateTime.now(),
                  material: '',
                  createdAt: DateTime.now(),
                ),
              );

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
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
                        Icon(Icons.event_note, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Sesi ${session.sessionNumber} - ${DateFormat('dd/MM/yyyy').format(session.date)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      note.note,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadReport(
    StudentModel student,
    TeacherProvider teacherProvider,
  ) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Generate report data
      final progressNotes = _progressNotesMap[student.studentId ?? ''] ?? [];
      final stats = _studentStatsMap[student.studentId ?? ''] ?? {};
      final sessions = teacherProvider.sessions.where((s) {
        return s.attendance.any((a) => a.studentId == student.studentId);
      }).toList();

      // In a real app, you would generate a PDF or Excel file here
      // For now, we'll just show a success message
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Laporan Siap'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Laporan untuk ${student.fullName}'),
                const SizedBox(height: 8),
                Text('Total Sesi: ${stats['totalSessions'] ?? 0}'),
                Text('Kehadiran: ${stats['attendanceRate'] ?? 0}%'),
                Text('Catatan: ${progressNotes.length}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur download PDF akan segera hadir'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Download PDF'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat laporan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
