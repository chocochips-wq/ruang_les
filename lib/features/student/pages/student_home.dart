import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/colors.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../data/repositories/class_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../core/models/class_model.dart';
import '../../../core/models/session_model.dart';
import '../widgets/student_drawer.dart';
import '../widgets/student_bottom_nav.dart';
import '../widgets/student_progress_widget.dart';

class BerandaMurid extends StatefulWidget {
  const BerandaMurid({super.key});

  @override
  State<BerandaMurid> createState() => _BerandaMuridState();
}

class _BerandaMuridState extends State<BerandaMurid> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StudentRepository _studentRepository = StudentRepository();
  final ClassRepository _classRepository = ClassRepository();
  final SessionRepository _sessionRepository = SessionRepository();
  final ProgressRepository _progressRepository = ProgressRepository();
  String? _studentId;

  @override
  void initState() {
    super.initState();
    _loadStudentId();
  }

  Future<void> _loadStudentId() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final student = await _studentRepository.getStudentByUserId(userId);
      if (student != null && student.studentId != null) {
        setState(() {
          _studentId = student.studentId;
        });
      }
    } catch (e) {
      print('Error loading student ID: $e');
    }
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 2,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Beranda',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: const DrawerMurid(),
      body: currentUserId == null || _studentId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUserId)
                  .snapshots(),
              builder: (context, userSnapshot) {
                final userName = userSnapshot.data?.get('name') ?? 'Siswa';

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeCard(userName),
                      const SizedBox(height: 20),
                      _buildStatistikCards(),
                      const SizedBox(height: 20),
                      _buildStudentProgress(),
                      const SizedBox(height: 20),
                      _buildAchievementsBadges(),
                      const SizedBox(height: 20),
                      _buildKelasAktif(),
                      const SizedBox(height: 20),
                      _buildProgressBelajar(),
                      const SizedBox(height: 20),
                      _buildAktivitasTerbaru(),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: const FooterMurid(selectedIndex: 1),
    );
  }

  Widget _buildWelcomeCard(String userName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.8),
            AppColors.primary
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Halo, $userName 👋',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 8),
                Text('Selamat datang!',
                    style: TextStyle(
                        fontSize: 14, color: Colors.white.withValues(alpha: 0.9))),
                const SizedBox(height: 4),
                Text('Mari tunjukkan semangat belajarmu hari ini',
                    style: TextStyle(
                        fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school, size: 32, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistikCards() {
    if (_studentId == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<SessionModel>>(
      stream: _sessionRepository.streamRecentSessions(limit: 100),
      builder: (context, sessionSnapshot) {
        if (sessionSnapshot.connectionState == ConnectionState.waiting) {
          return const Row(
            children: [
              Expanded(child: Center(child: CircularProgressIndicator())),
              SizedBox(width: 8),
              Expanded(child: Center(child: CircularProgressIndicator())),
              SizedBox(width: 8),
              Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          );
        }

        final allSessions = sessionSnapshot.data ?? [];
        
        // Filter sessions for this student's classes
        return StreamBuilder<List<ClassModel>>(
          stream: _classRepository.streamClassesByStudentId(_studentId!),
          builder: (context, classSnapshot) {
            if (classSnapshot.connectionState == ConnectionState.waiting) {
              return const Row(
                children: [
                  Expanded(child: Center(child: CircularProgressIndicator())),
                  SizedBox(width: 8),
                  Expanded(child: Center(child: CircularProgressIndicator())),
                  SizedBox(width: 8),
                  Expanded(child: Center(child: CircularProgressIndicator())),
                ],
              );
            }
            final classes = classSnapshot.data ?? [];
            final classIds = classes.map((c) => c.classId).whereType<String>().toList();
            
            // Count completed quizzes/tasks from sessions
            int completedTasks = 0;
            int activeTasks = 0;

            for (final session in allSessions) {
              if (classIds.contains(session.classId)) {
                // Check if student attended
                final attendance = session.attendance.firstWhere(
                  (a) => a.studentId == _studentId,
                  orElse: () => Attendance(studentId: '', status: 'absent'),
                );
                
                if (attendance.status == 'present') {
                  completedTasks++;
                } else {
                  activeTasks++;
                }
              }
            }

            // Get average from student points (simplified - you might have separate score tracking)
            final studentDoc = FirebaseFirestore.instance
                .collection('students')
                .doc(_studentId)
                .snapshots();
            
            return StreamBuilder<DocumentSnapshot>(
              stream: studentDoc,
              builder: (context, studentSnapshot) {
                final studentData = studentSnapshot.data?.data() as Map<String, dynamic>? ?? {};
                final totalPointsValue = studentData['totalPoints'];
                final totalPoints = totalPointsValue is int
                    ? totalPointsValue
                    : (totalPointsValue is num ? totalPointsValue.toInt() : 0);
                // Simplified: use points as proxy for performance
                final avgScore = totalPoints > 0 ? (totalPoints / 10).round() : 0;

                final statistik = [
                  {
                    'label': 'Tugas Selesai',
                    'value': '$completedTasks',
                    'icon': Icons.task_alt,
                    'color': Colors.green
                  },
                  {
                    'label': 'Tugas Aktif',
                    'value': '$activeTasks',
                    'icon': Icons.pending_actions,
                    'color': Colors.orange
                  },
                  {
                    'label': 'Rata-rata Nilai',
                    'value': '$avgScore',
                    'icon': Icons.trending_up,
                    'color': Colors.blue
                  },
                ];

                return Row(
                  children: statistik.map((stat) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                            right: stat == statistik.last ? 0 : 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey[200]!,
                                blurRadius: 4,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(stat['icon'] as IconData,
                                color: stat['color'] as Color, size: 24),
                            const SizedBox(height: 8),
                            Text(stat['value'] as String,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: stat['color'] as Color)),
                            const SizedBox(height: 4),
                            Text(stat['label'] as String,
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey[600]!),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildKelasAktif() {
    if (_studentId == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<ClassModel>>(
      stream: _classRepository.streamClassesByStudentId(_studentId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final classes = snapshot.data ?? [];

        if (classes.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Column(
              children: [
                Icon(Icons.class_, color: AppColors.primary, size: 24),
                SizedBox(width: 8),
                Text('Belum ada kelas aktif',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }

        // Map subject names to icons and colors
        final Map<String, Map<String, dynamic>> subjectStyles = {
          'Matematika': {
            'icon': Icons.calculate,
            'color': Colors.blue,
          },
          'Bahasa Inggris': {
            'icon': Icons.language,
            'color': Colors.purple,
          },
          'IPA': {
            'icon': Icons.science,
            'color': Colors.green,
          },
          'IPS': {
            'icon': Icons.map,
            'color': Colors.orange,
          },
          'Bahasa Indonesia': {
            'icon': Icons.menu_book,
            'color': Colors.red,
          },
        };

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.class_, color: AppColors.primary, size: 24),
                  SizedBox(width: 8),
                  Text('Kelas Aktif',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: classes.map((class_) {
                  final className = class_.className;
                  final style = subjectStyles[className] ??
                      {
                        'icon': Icons.school,
                        'color': Colors.grey,
                      };

                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: (style['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: (style['color'] as Color).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(style['icon'] as IconData,
                            size: 18, color: style['color'] as Color),
                        const SizedBox(width: 8),
                        Text(className,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: style['color'] as Color)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBelajar() {
    if (_studentId == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<ClassModel>>(
      stream: _classRepository.streamClassesByStudentId(_studentId!),
      builder: (context, classSnapshot) {
        if (classSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final classes = classSnapshot.data ?? [];
        final classIds = classes.map((c) => c.classId).whereType<String>().toList();

        if (classes.isEmpty) {
          return const SizedBox.shrink();
        }

        return StreamBuilder<List<SessionModel>>(
          stream: _sessionRepository.streamRecentSessions(limit: 100),
          builder: (context, sessionSnapshot) {
            if (sessionSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allSessions = sessionSnapshot.data ?? [];
            
            // Calculate progress for each class
            final Map<String, Map<String, dynamic>> progressMap = {};

            for (final class_ in classes) {
              final classSessions = allSessions
                  .where((s) => s.classId == class_.classId)
                  .toList();
              
              int completed = 0;
              for (final session in classSessions) {
                final attendance = session.attendance.firstWhere(
                  (a) => a.studentId == _studentId,
                  orElse: () => Attendance(studentId: '', status: 'absent'),
                );
                if (attendance.status == 'present') {
                  completed++;
                }
              }

              final total = class_.totalSessions;
              final progress = total > 0 ? completed / total : 0.0;

              progressMap[class_.classId ?? ''] = {
                'className': class_.className,
                'progress': progress,
                'completed': completed,
                'total': total,
                'color': _getSubjectColor(class_.className),
              };
            }

            final progressList = progressMap.values.toList();

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.insights, color: AppColors.primary, size: 24),
                      SizedBox(width: 8),
                      Text('Progres Belajarmu',
                          style:
                              TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (progressList.isEmpty)
                    const Text('Belum ada progress',
                        style: TextStyle(color: Colors.grey))
                  else
                    ...progressList.map((progress) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(progress['className'] as String,
                                    style: const TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.w500)),
                                Text(
                                    '${progress['completed']}/${progress['total']} Materi',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600]!)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: progress['progress'] as double,
                                      backgroundColor: Colors.grey[200]!,
                                      valueColor: AlwaysStoppedAnimation(
                                          progress['color'] as Color),
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                    '${((progress['progress'] as double) * 100).toInt()}%',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: progress['color'] as Color)),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAktivitasTerbaru() {
    if (_studentId == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<ClassModel>>(
      stream: _classRepository.streamClassesByStudentId(_studentId!),
      builder: (context, classSnapshot) {
        if (classSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final classes = classSnapshot.data ?? [];
        final classIds = classes.map((c) => c.classId).whereType<String>().toList();

        return StreamBuilder<List<SessionModel>>(
          stream: _sessionRepository.streamRecentSessions(limit: 10),
          builder: (context, sessionSnapshot) {
            if (sessionSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allSessions = sessionSnapshot.data ?? [];
            
            // Filter sessions for this student's classes and sort by date
            final relevantSessions = allSessions
                .where((s) => classIds.contains(s.classId))
                .toList()
              ..sort((a, b) => b.date.compareTo(a.date));

            final recentSessions = relevantSessions.take(3).toList();

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.history, color: AppColors.primary, size: 24),
                      SizedBox(width: 8),
                      Text('Aktivitas Terbaru',
                          style:
                              TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (recentSessions.isEmpty)
                    const Text('Belum ada aktivitas',
                        style: TextStyle(color: Colors.grey))
                  else
                    ...recentSessions.map((session) {
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

                      final icon = Icons.book;
                      final color = _getSubjectColor(class_.className);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50]!,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(icon, size: 20, color: color),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${class_.className} - ${session.material}',
                                    style: const TextStyle(
                                        fontSize: 13, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatTimeAgo(session.date),
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey[600]!),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right,
                                color: Colors.grey[400]!, size: 20),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStudentProgress() {
    if (_studentId == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder(
      stream: _progressRepository.streamProgressByStudentId(_studentId!),
      builder: (context, snapshot) {
        final progress = snapshot.data;
        return StudentProgressCard(progress: progress);
      },
    );
  }

  Widget _buildAchievementsBadges() {
    if (_studentId == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder(
      stream: _progressRepository.streamUnlockedAchievements(_studentId!),
      builder: (context, snapshot) {
        final achievements = snapshot.data ?? [];
        return AchievementBadges(
          achievements: achievements,
          maxDisplay: 6,
        );
      },
    );
  }

  Color _getSubjectColor(String subjectName) {
    if (subjectName.contains('Matematika')) return Colors.blue;
    if (subjectName.contains('Bahasa Inggris')) return Colors.purple;
    if (subjectName.contains('IPA')) return Colors.green;
    if (subjectName.contains('IPS')) return Colors.orange;
    if (subjectName.contains('Bahasa Indonesia')) return Colors.red;
    return Colors.grey;
  }
}
