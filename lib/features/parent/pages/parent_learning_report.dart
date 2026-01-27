import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/colors.dart';
import '../../../data/repositories/parent_repository.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../data/repositories/class_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../../../core/models/student_model.dart';
import '../../../core/models/class_model.dart';
import '../../../core/models/session_model.dart';
import '../widgets/parent_drawer.dart';
import '../widgets/parent_bottom_nav.dart';
import 'parent_session_detail.dart';

class LaporanBelajarOrangtua extends StatefulWidget {
  const LaporanBelajarOrangtua({super.key});

  @override
  State<LaporanBelajarOrangtua> createState() => _LaporanBelajarOrangtuaState();
}

class _LaporanBelajarOrangtuaState extends State<LaporanBelajarOrangtua> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ParentRepository _parentRepository = ParentRepository();
  final StudentRepository _studentRepository = StudentRepository();
  final ClassRepository _classRepository = ClassRepository();
  final SessionRepository _sessionRepository = SessionRepository();
  final QuizRepository _quizRepository = QuizRepository();
  String? _parentId;
  StudentModel? _selectedStudent;

  @override
  void initState() {
    super.initState();
    _loadParentId();
  }

  Future<void> _loadParentId() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final parent = await _parentRepository.getParentByUserId(userId);
      if (parent != null && parent.parentId != null) {
        setState(() {
          _parentId = parent.parentId;
        });
      }
    } catch (e) {
      print('Error loading parent ID: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Laporan Belajar Murid',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const ParentDrawer(),
      body: _parentId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<StudentModel>>(
              stream: _studentRepository.streamStudentsByParentId(_parentId!),
              builder: (context, studentsSnapshot) {
                if (studentsSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final students = studentsSnapshot.data ?? [];

                if (students.isEmpty) {
                  return const Center(child: Text('Belum ada anak terdaftar'));
                }

                // Use first student as default
                if (_selectedStudent == null && students.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _selectedStudent = students.first;
                    });
                  });
                }

                if (_selectedStudent == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header dengan Greeting
                      StreamBuilder<DocumentSnapshot>(
                        stream: userId != null
                            ? FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .snapshots()
                            : null,
                        builder: (context, userSnapshot) {
                          final userName =
                              userSnapshot.data?.get('name') ?? 'Pak/Bu';
                          return _buildHeaderSection(
                              userName, _selectedStudent!);
                        },
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Info Murid
                            _buildMuridInfoCard(_selectedStudent!),

                            const SizedBox(height: 16),

                            // Statistik Belajar - Real-time
                            FutureBuilder<Map<String, dynamic>>(
                              future: _getStatistics(_selectedStudent!),
                              builder: (context, statsSnapshot) {
                                if (!statsSnapshot.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                return _buildStatistikCard(statsSnapshot.data!);
                              },
                            ),

                            const SizedBox(height: 16),

                            // Performa Per Mata Pelajaran - Real-time
                            FutureBuilder<List<Map<String, dynamic>>>(
                              future: _getPerformanceData(_selectedStudent!),
                              builder: (context, perfSnapshot) {
                                if (!perfSnapshot.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                return _buildPerformaSection(
                                    perfSnapshot.data!);
                              },
                            ),

                            const SizedBox(height: 16),

                            // Daftar Sesi
                            FutureBuilder<List<SessionModel>>(
                              future: _getAllSessions(_selectedStudent!),
                              builder: (context, sessionsSnapshot) {
                                if (!sessionsSnapshot.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                return _buildSessionsList(
                                    sessionsSnapshot.data!);
                              },
                            ),

                            const SizedBox(height: 16),

                            // Catatan Pengajar - Real-time from sessions
                            FutureBuilder<List<SessionModel>>(
                              future: _getTeacherNotes(_selectedStudent!),
                              builder: (context, notesSnapshot) {
                                if (!notesSnapshot.hasData) {
                                  return const SizedBox.shrink();
                                }
                                return _buildCatatanPengajar(
                                    notesSnapshot.data!);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: const ParentBottomNav(selectedIndex: 1),
    );
  }

  Future<Map<String, dynamic>> _getStatistics(StudentModel student) async {
    try {
      final classes =
          await _classRepository.getClassesByStudentId(student.studentId!);
      int totalSessions = 0;
      int attendedSessions = 0;
      int totalStudyHours = 0;
      int completedQuizzes = 0;

      // 1. Calculate Attendance & Study Hours
      for (final classModel in classes) {
        final sessions =
            await _sessionRepository.getSessionsByClassId(classModel.classId!);
        totalSessions += sessions.length;

        for (final session in sessions) {
          final attendance = session.attendance.firstWhere(
            (a) => a.studentId == student.studentId,
            orElse: () => Attendance(studentId: '', status: 'absent'),
          );
          if (attendance.status == 'present') {
            attendedSessions++;
            totalStudyHours += 2; // Assume 2 hours per session
          }
        }
      }

      // 2. Calculate Quiz Completion
      final quizzes =
          await _quizRepository.getQuizzesByStudentId(student.studentId!);
      completedQuizzes = quizzes.where((q) => q.isCompleted).length;

      final attendancePercentage = totalSessions > 0
          ? ((attendedSessions / totalSessions) * 100).round()
          : 0;

      // 3. Calculate Global Average Score (from all quizzes)
      int totalQuizScore = 0;
      int completedQuizCount = 0;
      for (var q in quizzes) {
        if (q.isCompleted) {
          // Normalize score to 0-100 scale if totalPoints > 0
          final double normalized =
              q.totalPoints > 0 ? (q.score / q.totalPoints) * 100 : 0;
          totalQuizScore += normalized.round();
          completedQuizCount++;
        }
      }
      final int avgQuizScore = completedQuizCount > 0
          ? (totalQuizScore / completedQuizCount).round()
          : 0;

      // Final Average: 40% Attendance + 60% Quiz
      final combinedScore = (attendancePercentage * 0.4) + (avgQuizScore * 0.6);

      return {
        'completedQuizzes': completedQuizzes,
        'totalStudyHours': totalStudyHours,
        'attendancePercentage': attendancePercentage,
        'averageScore': combinedScore.round(),
      };
    } catch (e) {
      print('Error getting statistics: $e');
      return {
        'completedQuizzes': 0,
        'totalStudyHours': 0,
        'attendancePercentage': 0,
        'averageScore': 0,
      };
    }
  }

  Future<List<Map<String, dynamic>>> _getPerformanceData(
      StudentModel student) async {
    try {
      final classes =
          await _classRepository.getClassesByStudentId(student.studentId!);
      final allQuizzes =
          await _quizRepository.getQuizzesByStudentId(student.studentId!);

      final List<Map<String, dynamic>> performanceList = [];

      for (final classModel in classes) {
        // Attendance
        final sessions =
            await _sessionRepository.getSessionsByClassId(classModel.classId!);
        int totalSessions = sessions.length;
        int attendedSessions = 0;

        for (final session in sessions) {
          final attendance = session.attendance.firstWhere(
            (a) => a.studentId == student.studentId,
            orElse: () => Attendance(studentId: '', status: 'absent'),
          );
          if (attendance.status == 'present') {
            attendedSessions++;
          }
        }

        final attendancePct = totalSessions > 0
            ? ((attendedSessions / totalSessions) * 100).round()
            : 0;

        // Quizzes for this specific class
        final classQuizzes = allQuizzes
            .where((q) => q.classId == classModel.classId && q.isCompleted)
            .toList();
        final int completedCount = classQuizzes.length;

        int totalQuizScore = 0;
        for (var q in classQuizzes) {
          final double normalized =
              q.totalPoints > 0 ? (q.score / q.totalPoints) * 100 : 0;
          totalQuizScore += normalized.round();
        }
        final int avgQuizScore =
            completedCount > 0 ? (totalQuizScore / completedCount).round() : 0;

        // Combined Score: 40% Attendance, 60% Quiz (if any quiz exists), else 100% Attendance
        int finalScore;
        if (completedCount > 0) {
          finalScore = ((attendancePct * 0.4) + (avgQuizScore * 0.6)).round();
        } else {
          // If no quizzes yet, base entirely on attendance (capped at 100) or default to attendance score
          finalScore = attendancePct;
        }

        String grade;
        Color color;
        if (finalScore >= 85) {
          grade = 'A';
          color = Colors.blue;
        } else if (finalScore >= 75) {
          grade = 'B+';
          color = Colors.amber;
        } else if (finalScore >= 65) {
          grade = 'B';
          color = Colors.orange;
        } else {
          grade = 'C';
          color = Colors.red;
        }

        performanceList.add({
          'subject': classModel.className,
          'grade': grade,
          'score': finalScore,
          'subtitle': 'Quiz Diselesaikan: $completedCount',
          'color': color,
        });
      }

      return performanceList;
    } catch (e) {
      print('Error getting performance data: $e');
      return [];
    }
  }

  Future<List<SessionModel>> _getAllSessions(StudentModel student) async {
    try {
      final classes =
          await _classRepository.getClassesByStudentId(student.studentId!);
      final List<SessionModel> allSessions = [];

      for (final classModel in classes) {
        final sessions =
            await _sessionRepository.getSessionsByClassId(classModel.classId!);
        allSessions.addAll(sessions);
      }

      // Sort by date, most recent first
      allSessions.sort((a, b) => b.date.compareTo(a.date));
      return allSessions;
    } catch (e) {
      print('Error getting all sessions: $e');
      return [];
    }
  }

  Future<List<SessionModel>> _getTeacherNotes(StudentModel student) async {
    try {
      final classes =
          await _classRepository.getClassesByStudentId(student.studentId!);
      final List<SessionModel> notesList = [];

      for (final classModel in classes) {
        final sessions =
            await _sessionRepository.getSessionsByClassId(classModel.classId!);
        for (final session in sessions) {
          if (session.teacherNotes != null &&
              session.teacherNotes!.isNotEmpty) {
            notesList.add(session);
          }
        }
      }

      // Sort by date, most recent first
      notesList.sort((a, b) => b.date.compareTo(a.date));
      return notesList.take(3).toList(); // Get latest 3 notes
    } catch (e) {
      print('Error getting teacher notes: $e');
      return [];
    }
  }

  Widget _buildHeaderSection(String userName, StudentModel student) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '👋',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'HALO, ${userName.toUpperCase()}!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Selamat datang di halaman Laporan Belajar Murid. Halaman ini dirancang untuk membantu Anda memantau perkembangan belajar dan lebih mendalam memantau perkembangan belajar ${student.fullName}.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuridInfoCard(StudentModel student) {
    return FutureBuilder<int>(
      future: _getAverageScore(student),
      builder: (context, snapshot) {
        final averageScore = snapshot.data ?? 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: student.avatarUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          student.avatarUrl!,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 32,
                              color: AppColors.primary,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 32,
                        color: AppColors.primary,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildInfoBadge(
                            '$averageScore', 'Rata-rata', Colors.blue),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<int> _getAverageScore(StudentModel student) async {
    try {
      final classes =
          await _classRepository.getClassesByStudentId(student.studentId!);
      if (classes.isEmpty) return 0;

      int totalScore = 0;
      int classCount = 0;

      for (final classModel in classes) {
        final sessions =
            await _sessionRepository.getSessionsByClassId(classModel.classId!);
        int totalSessions = sessions.length;
        int attendedSessions = 0;

        for (final session in sessions) {
          final attendance = session.attendance.firstWhere(
            (a) => a.studentId == student.studentId,
            orElse: () => Attendance(studentId: '', status: 'absent'),
          );
          if (attendance.status == 'present') {
            attendedSessions++;
          }
        }

        final attendancePercentage = totalSessions > 0
            ? ((attendedSessions / totalSessions) * 100).round()
            : 0;

        totalScore += 75 + (attendancePercentage ~/ 10);
        classCount++;
      }

      return classCount > 0 ? (totalScore / classCount).round() : 0;
    } catch (e) {
      return 0;
    }
  }

  Widget _buildInfoBadge(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistikCard(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics_outlined,
                  size: 20, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Statistik Belajar',
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
              Expanded(
                child: _buildStatItem(
                  '${stats['completedQuizzes']}',
                  'Quiz Diselesaikan',
                  Icons.quiz,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  '${stats['totalStudyHours']} Jam',
                  'Total Waktu Belajar',
                  Icons.access_time,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatItem(
            '${stats['attendancePercentage']}%',
            'Tingkat Kehadiran',
            Icons.check_circle,
            Colors.green,
            isWide: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color,
      {bool isWide = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformaSection(List<Map<String, dynamic>> performanceList) {
    if (performanceList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: const Text('Belum ada data performa'),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.school_outlined, size: 20, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Performa Per Mata Pelajaran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...performanceList.asMap().entries.map((entry) {
            final index = entry.key;
            final perf = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                  bottom: index < performanceList.length - 1 ? 12 : 0),
              child: _buildPerformaItem(
                perf['subject'],
                perf['grade'],
                perf['score'],
                perf['subtitle'],
                perf['color'],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPerformaItem(
      String subject, String grade, int score, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          subject,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            grade,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: score / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList(List<SessionModel> sessions) {
    if (sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: const Center(
          child: Text('Belum ada sesi pertemuan'),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.event, size: 20, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Daftar Sesi Pertemuan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...sessions.map((session) {
            final attendance = session.attendance.firstWhere(
              (a) => a.studentId == _selectedStudent!.studentId,
              orElse: () => Attendance(studentId: '', status: 'absent'),
            );

            Color statusColor;
            IconData statusIcon;
            String statusText;

            switch (attendance.status) {
              case 'present':
                statusColor = Colors.green;
                statusIcon = Icons.check_circle;
                statusText = 'Hadir';
                break;
              case 'excused':
                statusColor = Colors.orange;
                statusIcon = Icons.info;
                statusText = 'Izin';
                break;
              default:
                statusColor = Colors.red;
                statusIcon = Icons.cancel;
                statusText = 'Tidak Hadir';
            }

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ParentSessionDetailPage(
                      session: session,
                      student: _selectedStudent!,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 60,
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Sesi ${session.sessionNumber}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(statusIcon,
                                        size: 14, color: statusColor),
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
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.book,
                                  size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  session.material,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                '${session.date.day} ${_getMonthName(session.date.month)} ${session.date.year}',
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
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCatatanPengajar(List<SessionModel> notes) {
    if (notes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.note_alt_outlined, size: 20, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Catatan Pengajar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...notes.map((session) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"${session.teacherNotes}"',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textDark,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      FutureBuilder<ClassModel?>(
                        future: _classRepository.getClassById(session.classId),
                        builder: (context, classSnapshot) {
                          // For now, use a default teacher name
                          return Text(
                            'Dibuat oleh: Pengajar',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        '${session.date.day} ${_getMonthName(session.date.month)} ${session.date.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade200,
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
