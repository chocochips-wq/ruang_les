import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/colors.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../data/repositories/class_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/teacher_repository.dart';
import '../../../core/models/student_model.dart';
import '../../../core/models/class_model.dart';
import '../../../core/models/session_model.dart';
import '../../../core/models/user_model.dart';
import '../widgets/student_drawer.dart';
import '../widgets/student_bottom_nav.dart';

class HalamanKelas extends StatefulWidget {
  const HalamanKelas({super.key});

  @override
  State<HalamanKelas> createState() => _HalamanKelasState();
}

class _HalamanKelasState extends State<HalamanKelas> {
  int _selectedIndex = 0;
  String? _selectedDay;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StudentRepository _studentRepository = StudentRepository();
  final ClassRepository _classRepository = ClassRepository();
  final SessionRepository _sessionRepository = SessionRepository();
  final TeacherRepository _teacherRepository = TeacherRepository();
  String? _studentId;
  String? _studentName;

  @override
  void initState() {
    super.initState();
    _selectedDay = _getCurrentDay();
    _loadStudentId();
  }

  String _getCurrentDay() {
    final now = DateTime.now();
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    return days[now.weekday % 7];
  }

  Future<void> _loadStudentId() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final student = await _studentRepository.getStudentByUserId(userId);
      if (student != null && student.studentId != null) {
        setState(() {
          _studentId = student.studentId;
          _studentName = student.fullName.isNotEmpty ? student.fullName : student.nickname;
        });
      }
    } catch (e) {
      print('Error loading student ID: $e');
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: const Text(
            'Kelas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        drawer: const DrawerMurid(),
        body: _studentId == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ====== HARI INI ======
                  _buildSectionCard(
                    title: 'Hari ini',
                    icon: Icons.today,
                    child: _buildTodaySchedule(),
                  ),

                  const SizedBox(height: 16),

                  // ====== HARI SECTION ======
                  _buildSimpleCard(
                    padding: 16,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'Senin',
                        'Selasa',
                        'Rabu',
                        'Kamis',
                        'Jumat',
                        'Sabtu',
                        'Minggu'
                      ].map((day) => _buildDayChip(day, day == _selectedDay)).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ====== KELASKU ======
                  _buildSectionCard(
                    title: 'Kelasku',
                    icon: Icons.class_,
                    child: _buildClassDetails(),
                  ),

                  const SizedBox(height: 16),

                  // ====== ABSEN ======
                  _buildSectionCard(
                    title: 'Absen',
                    icon: Icons.checklist,
                    child: _buildAbsenceTable(),
                  ),
                ],
              ),
        bottomNavigationBar: const FooterMurid(selectedIndex: 0));
  }

  Widget _buildTodaySchedule() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return StreamBuilder<List<ClassModel>>(
      stream: _classRepository.streamClassesByStudentId(_studentId!),
      builder: (context, classSnapshot) {
        if (classSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final classes = classSnapshot.data ?? [];
        final classIds = classes.map((c) => c.classId).whereType<String>().toList();

        if (classIds.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Tidak ada jadwal hari ini',
                style: TextStyle(color: Colors.grey)),
          );
        }

        return StreamBuilder<List<SessionModel>>(
          stream: _sessionRepository.streamRecentSessions(limit: 100),
          builder: (context, sessionSnapshot) {
            if (sessionSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allSessions = sessionSnapshot.data ?? [];
            final todaySessions = allSessions.where((session) {
              return classIds.contains(session.classId) &&
                  session.date.isAfter(today) &&
                  session.date.isBefore(tomorrow);
            }).toList();

            if (todaySessions.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Tidak ada jadwal hari ini',
                    style: TextStyle(color: Colors.grey)),
              );
            }

            return Column(
              children: todaySessions.map((session) {
                final class_ = classes.firstWhere(
                  (c) => c.classId == session.classId,
                  orElse: () => ClassModel(
                    className: 'Kelas',
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

                return _buildScheduleItem(
                  time: _formatTime(session.date),
                  title: '${class_.className} - ${class_.gradeLevel}',
                  buttonText: 'Masuk Kelas',
                  onTap: () {},
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildClassDetails() {
    return StreamBuilder<List<ClassModel>>(
      stream: _classRepository.streamClassesByStudentId(_studentId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final classes = snapshot.data ?? [];

        if (classes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Belum ada kelas terdaftar',
                style: TextStyle(color: Colors.grey)),
          );
        }

        // Show first class or all classes
        final class_ = classes.first;

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('teachers')
              .doc(class_.teacherId)
              .snapshots(),
          builder: (context, teacherSnapshot) {
            final teacherName = teacherSnapshot.data?.get('fullName') ?? 'Guru';

            // Get sessions for this class
            return StreamBuilder<List<SessionModel>>(
              stream: _sessionRepository.streamSessionsByClassId(class_.classId!),
              builder: (context, sessionSnapshot) {
                final sessions = sessionSnapshot.data ?? [];
                final completedSessions = sessions.where((s) {
                  return s.attendance.any((a) =>
                      a.studentId == _studentId && a.status == 'present');
                }).length;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
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
                            child: const Icon(Icons.book,
                                color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${class_.className} - ${class_.gradeLevel}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.person,
                          '${class_.type == 'private' ? 'Private' : class_.type == 'semi_private' ? 'Semi Private' : 'Regular'} - $teacherName'),
                      const SizedBox(height: 6),
                      _buildInfoRow(Icons.access_time, class_.schedule.isNotEmpty
                          ? class_.schedule
                          : 'Jadwal belum ditentukan'),
                      const SizedBox(height: 6),
                      _buildInfoRow(Icons.analytics,
                          '$completedSessions/${class_.totalSessions} Pertemuan'),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton('Materi', Icons.description, () {}),
                          _buildActionButton('Quiz', Icons.quiz, () {}),
                          _buildActionButton('Forum', Icons.forum, () {}),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAbsenceTable() {
    if (_studentId == null || _studentName == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<List<ClassModel>>(
      stream: _classRepository.streamClassesByStudentId(_studentId!),
      builder: (context, classSnapshot) {
        if (classSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final classes = classSnapshot.data ?? [];
        final classIds = classes.map((c) => c.classId).whereType<String>().toList();

        if (classIds.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Belum ada data absensi',
                style: TextStyle(color: Colors.grey)),
          );
        }

        return StreamBuilder<List<SessionModel>>(
          stream: _sessionRepository.streamRecentSessions(limit: 50),
          builder: (context, sessionSnapshot) {
            if (sessionSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allSessions = sessionSnapshot.data ?? [];
            final relevantSessions = allSessions
                .where((s) => classIds.contains(s.classId))
                .toList()
              ..sort((a, b) => b.date.compareTo(a.date));

            if (relevantSessions.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Belum ada data absensi',
                    style: TextStyle(color: Colors.grey)),
              );
            }

            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Text('Nama',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold))),
                      Expanded(
                          flex: 2,
                          child: Text('Tanggal',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold))),
                      Expanded(
                          flex: 1,
                          child: Text('Status',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                // Rows
                ...relevantSessions.take(10).map((session) {
                  final attendance = session.attendance.firstWhere(
                    (a) => a.studentId == _studentId,
                    orElse: () => Attendance(studentId: '', status: 'absent'),
                  );

                  final statusText = attendance.status == 'present'
                      ? 'Hadir'
                      : attendance.status == 'excused'
                          ? 'Izin'
                          : 'Tidak Hadir';
                  final statusColor = attendance.status == 'present'
                      ? AppColors.success
                      : attendance.status == 'excused'
                          ? Colors.orange
                          : Colors.red;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: relevantSessions.indexOf(session) ==
                              relevantSessions.length - 1
                          ? const BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            )
                          : BorderRadius.zero,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(_studentName!,
                              style: const TextStyle(fontSize: 13)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(_formatDate(session.date),
                              style: const TextStyle(fontSize: 13)),
                        ),
                        Expanded(
                          flex: 1,
                          child: _buildStatusBadge(statusText, statusColor),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDayChip(String day, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = day;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.grey[100]!,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey[300]!,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? AppColors.primary : AppColors.textLight,
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleItem({
    required String time,
    required String title,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[50]!, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.schedule, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textLight),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.textLight),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.grey[100]!,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.textDark),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSectionCard(
      {required String title, required Widget child, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildSimpleCard({required Widget child, double padding = 12}) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: _cardDecoration(),
      child: child,
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[300]!),
      boxShadow: [
        BoxShadow(
          color: Colors.grey[200]!,
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
