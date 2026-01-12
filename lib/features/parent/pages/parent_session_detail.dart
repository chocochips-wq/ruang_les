import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/colors.dart';
import '../../../core/models/session_model.dart';
import '../../../core/models/student_model.dart';
import '../../../core/models/class_model.dart';
import '../../../core/models/progress_note_model.dart';
import '../../../core/models/material_model.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../data/repositories/progress_note_repository.dart';
import '../../../data/repositories/material_repository.dart';
import '../../../data/repositories/class_repository.dart';
import '../widgets/parent_drawer.dart';
import '../widgets/parent_bottom_nav.dart';

class ParentSessionDetailPage extends StatefulWidget {
  final SessionModel session;
  final StudentModel student;

  const ParentSessionDetailPage({
    super.key,
    required this.session,
    required this.student,
  });

  @override
  State<ParentSessionDetailPage> createState() => _ParentSessionDetailPageState();
}

class _ParentSessionDetailPageState extends State<ParentSessionDetailPage> {
  final SessionRepository _sessionRepository = SessionRepository();
  final ProgressNoteRepository _progressNoteRepository = ProgressNoteRepository();
  final MaterialRepository _materialRepository = MaterialRepository();
  final ClassRepository _classRepository = ClassRepository();

  ClassModel? _classModel;
  ProgressNoteModel? _progressNote;
  MaterialModel? _material;
  int _totalSessions = 0;
  int _completedSessions = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load class info
      final classModel = await _classRepository.getClassById(widget.session.classId);
      
      // Load progress note for this student and session
      final progressNote = await _progressNoteRepository.getProgressNoteBySessionAndStudent(
        widget.session.sessionId!,
        widget.student.studentId!,
      );

      // Try to find material by title (simplified - you might want to improve this)
      MaterialModel? material;
      try {
        final materials = await _materialRepository.getMaterialsByTeacherId(
          classModel?.teacherId ?? '',
        );
        material = materials.firstWhere(
          (m) => m.title.toLowerCase().contains(widget.session.material.toLowerCase()) ||
                 widget.session.material.toLowerCase().contains(m.title.toLowerCase()),
          orElse: () => materials.isNotEmpty ? materials.first : MaterialModel(
            teacherId: '',
            subject: '',
            title: '',
            description: '',
            gradeLevel: '',
            createdAt: DateTime.now(),
          ),
        );
        if (material?.materialId == null) material = null;
      } catch (e) {
        // Material not found, that's okay
      }

      // Calculate progress
      final allSessions = await _sessionRepository.getSessionsByClassId(widget.session.classId);
      _totalSessions = allSessions.length;
      _completedSessions = allSessions.where((s) {
        final attendance = s.attendance.firstWhere(
          (a) => a.studentId == widget.student.studentId,
          orElse: () => Attendance(studentId: '', status: 'absent'),
        );
        return attendance.status == 'present';
      }).length;

      setState(() {
        _classModel = classModel;
        _progressNote = progressNote;
        _material = material;
      });
    } catch (e) {
      print('Error loading session data: $e');
    }
  }

  Attendance? get _studentAttendance {
    return widget.session.attendance.firstWhere(
      (a) => a.studentId == widget.student.studentId,
      orElse: () => Attendance(studentId: '', status: 'absent'),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'present':
        return 'Hadir';
      case 'excused':
        return 'Izin';
      case 'absent':
      default:
        return 'Tidak Hadir';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'excused':
        return Colors.orange;
      case 'absent':
      default:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'present':
        return Icons.check_circle;
      case 'excused':
        return Icons.info;
      case 'absent':
      default:
        return Icons.cancel;
    }
  }

  Future<void> _openMaterial() async {
    if (_material?.fileUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File materi tidak tersedia')),
      );
      return;
    }

    final uri = Uri.parse(_material!.fileUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka file materi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendance = _studentAttendance ?? Attendance(studentId: '', status: 'absent');
    final progressPercentage = _totalSessions > 0 
        ? (_completedSessions / _totalSessions) * 100 
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Sesi ${widget.session.sessionNumber}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const ParentDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _classModel?.className ?? 'Kelas',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.session.date.day} ${_getMonthName(widget.session.date.month)} ${widget.session.date.year}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Kehadiran
                  _buildStatusCard(attendance),

                  const SizedBox(height: 16),

                  // Progress Bar
                  _buildProgressCard(progressPercentage),

                  const SizedBox(height: 16),

                  // Materi yang Diajarkan
                  _buildMaterialCard(),

                  const SizedBox(height: 16),

                  // Tujuan Pembelajaran
                  if (widget.session.learningObjective != null)
                    _buildLearningObjectiveCard(),

                  if (widget.session.learningObjective != null)
                    const SizedBox(height: 16),

                  // Catatan Perkembangan
                  if (_progressNote != null)
                    _buildProgressNoteCard(),

                  if (_progressNote != null)
                    const SizedBox(height: 16),

                  // Skor/Level Permainan (Dummy)
                  _buildGameScoreCard(),

                  const SizedBox(height: 16),

                  // Catatan Guru
                  if (widget.session.teacherNotes != null && widget.session.teacherNotes!.isNotEmpty)
                    _buildTeacherNotesCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ParentBottomNav(selectedIndex: 1),
    );
  }

  Widget _buildStatusCard(Attendance attendance) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Status Kehadiran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(attendance.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getStatusIcon(attendance.status),
                    color: _getStatusColor(attendance.status),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusText(attendance.status),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(attendance.status),
                        ),
                      ),
                      if (attendance.reason != null && attendance.reason!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Alasan: ${attendance.reason}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(double percentage) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_up, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Progress Pertemuan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_completedSessions} dari ${_totalSessions} pertemuan',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage / 100,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.book, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Materi yang Diajarkan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.session.material,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textDark,
              ),
            ),
            if (_material != null) ...[
              const SizedBox(height: 12),
              if (_material!.fileUrl != null)
                InkWell(
                  onTap: _openMaterial,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getFileIcon(_material!.fileType),
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _material!.fileName ?? 'File Materi',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              if (_material!.fileType != null)
                                Text(
                                  _material!.fileType!.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textLight,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.open_in_new,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLearningObjectiveCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.flag, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Tujuan Pembelajaran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.session.learningObjective!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textDark,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressNoteCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.note, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Catatan Perkembangan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _progressNote!.note,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textDark,
                height: 1.5,
              ),
            ),
            if (_progressNote!.attachmentUrl != null) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final uri = Uri.parse(_progressNote!.attachmentUrl!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.attachment, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Lihat Lampiran',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGameScoreCard() {
    // Dummy data for game score
    final gameScore = 85; // Dummy score
    final gameLevel = 'Level 5'; // Dummy level

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.games, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Skor/Level Permainan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '$gameScore',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      'Skor',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.grey.shade300,
                ),
                Column(
                  children: [
                    Text(
                      gameLevel,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      'Level',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherNotesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.school, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Catatan Guru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                widget.session.teacherNotes!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textDark,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String? fileType) {
    if (fileType == null) return Icons.insert_drive_file;
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return months[month - 1];
  }
}
