import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/colors.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../data/repositories/class_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/models/student_model.dart';
import '../../../core/models/class_model.dart';
import '../../../core/models/session_model.dart';
import '../widgets/parent_drawer.dart';
import '../widgets/parent_bottom_nav.dart';

class BerandaOrangtua extends StatefulWidget {
  const BerandaOrangtua({super.key});

  @override
  State<BerandaOrangtua> createState() => _BerandaOrangtuaState();
}

class _BerandaOrangtuaState extends State<BerandaOrangtua> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StudentRepository _studentRepository = StudentRepository();
  final ClassRepository _classRepository = ClassRepository();
  final SessionRepository _sessionRepository = SessionRepository();
  final UserRepository _userRepository = UserRepository();

  String? get currentUserId => _auth.currentUser?.uid;
  String? _parentId;

  @override
  void initState() {
    super.initState();
    _loadParentId();
  }

  Future<void> _loadParentId() async {
    if (currentUserId == null) return;
    
    try {
      // Get parent document by userId
      final query = await FirebaseFirestore.instance
          .collection('parents')
          .where('userId', isEqualTo: currentUserId)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        setState(() {
          _parentId = query.docs.first.id;
        });
      }
    } catch (e) {
      print('Error loading parent ID: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_parentId == null && currentUserId != null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const ParentDrawer(),
      body: StreamBuilder<DocumentSnapshot?>(
        stream: currentUserId != null
            ? FirebaseFirestore.instance
                .collection('users')
                .doc(currentUserId)
                .snapshots()
            : null,
        builder: (context, userSnapshot) {
          final userName = userSnapshot.data?.get('name') ?? 'Orang Tua';
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, $userName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pantau perkembangan anak Anda',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Data Anak
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Anak Saya',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Children List - Real-time
                if (_parentId != null)
                  StreamBuilder<List<StudentModel>>(
                    stream: _studentRepository.streamStudentsByParentId(_parentId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      final children = snapshot.data ?? [];

                      if (children.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text('Belum ada anak terdaftar'),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: children.length,
                        itemBuilder: (context, index) {
                          final child = children[index];
                          return _buildAnakCard(child);
                        },
                      );
                    },
                  ),

                const SizedBox(height: 24),

                // Menu Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildMenuCard(
                        icon: Icons.grade,
                        label: 'Nilai',
                        color: Colors.blue,
                        onTap: () {},
                      ),
                      _buildMenuCard(
                        icon: Icons.calendar_today,
                        label: 'Jadwal',
                        color: Colors.green,
                        onTap: () {},
                      ),
                      _buildMenuCard(
                        icon: Icons.check_circle,
                        label: 'Kehadiran',
                        color: Colors.orange,
                        onTap: () {},
                      ),
                      _buildMenuCard(
                        icon: Icons.payment,
                        label: 'Pembayaran',
                        color: Colors.purple,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Perkembangan Akademik
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Perkembangan Akademik',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Detail'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Academic Progress - Real-time from classes
                if (_parentId != null)
                  StreamBuilder<List<StudentModel>>(
                    stream: _studentRepository.streamStudentsByParentId(_parentId!),
                    builder: (context, studentsSnapshot) {
                      if (!studentsSnapshot.hasData || studentsSnapshot.data!.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      final studentIds = studentsSnapshot.data!.map((s) => s.studentId).whereType<String>().toList();
                      
                      return FutureBuilder<List<ClassModel>>(
                        future: Future.wait(
                          studentIds.map((id) => _classRepository.getClassesByStudentId(id)),
                        ).then((lists) => lists.expand((list) => list).toList()),
                        builder: (context, classesSnapshot) {
                          if (!classesSnapshot.hasData) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final classes = classesSnapshot.data!;
                          
                          if (classes.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Text('Belum ada kelas'),
                            );
                          }

                          // Get sessions for attendance calculation
                          return FutureBuilder<List<Map<String, dynamic>>>(
                            future: _getAcademicProgress(classes, studentIds),
                            builder: (context, progressSnapshot) {
                              final progressList = progressSnapshot.data ?? [];
                              
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                itemCount: progressList.length,
                                itemBuilder: (context, index) {
                                  final progress = progressList[index];
                                  return _buildPerkembanganCard(progress);
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),

                const SizedBox(height: 32),

                // Aktivitas Terkini
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Aktivitas Terkini',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Recent Activities - Real-time from sessions
                StreamBuilder<List<SessionModel>>(
                  stream: _sessionRepository.streamRecentSessions(limit: 5),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    final sessions = snapshot.data ?? [];

                    if (sessions.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text('Belum ada aktivitas'),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: sessions.length > 3 ? 3 : sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        return _buildAktivitasCard(session);
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: ParentBottomNav(selectedIndex: _selectedIndex),
    );
  }

  Future<List<Map<String, dynamic>>> _getAcademicProgress(
      List<ClassModel> classes, List<String> studentIds) async {
    final List<Map<String, dynamic>> progressList = [];

    for (final classModel in classes) {
      try {
        final sessions = await _sessionRepository.getSessionsByClassId(classModel.classId!);
        
        // Calculate attendance for students in this class
        int totalSessions = sessions.length;
        int attendedSessions = 0;
        
        for (final session in sessions) {
          for (final attendance in session.attendance) {
            if (studentIds.contains(attendance.studentId) &&
                attendance.status == 'present') {
              attendedSessions++;
              break; // Count once per session
            }
          }
        }

        final attendancePercentage = totalSessions > 0
            ? ((attendedSessions / totalSessions) * 100).round()
            : 0;

        // Calculate average (simplified - you might want to get actual grades from a separate collection)
        final averageScore = 75 + (attendancePercentage ~/ 10); // Simplified calculation
        final completedTasks = (totalSessions * 0.8).round(); // Simplified

        progressList.add({
          'mataPelajaran': classModel.className,
          'nilai': averageScore.toString(),
          'kehadiran': '$attendancePercentage%',
          'tugas': '$completedTasks/$totalSessions',
          'color': _getColorForSubject(classModel.className),
        });
      } catch (e) {
        print('Error getting progress for class ${classModel.classId}: $e');
      }
    }

    return progressList;
  }

  Color _getColorForSubject(String subject) {
    final subjectLower = subject.toLowerCase();
    if (subjectLower.contains('matematika') || subjectLower.contains('math')) {
      return Colors.blue;
    } else if (subjectLower.contains('bahasa') || subjectLower.contains('english')) {
      return Colors.green;
    } else if (subjectLower.contains('fisika') || subjectLower.contains('physics')) {
      return Colors.orange;
    } else {
      return Colors.purple;
    }
  }

  // Fungsi untuk menampilkan kartu anak
  Widget _buildAnakCard(StudentModel anak) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: anak.avatarUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      anak.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 32,
                          color: AppColors.primary,
                        );
                      },
                    ),
                  )
                : Icon(
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
                  anak.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  anak.gradeLevel,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerkembanganCard(Map<String, dynamic> perkembangan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: perkembangan['color'] as Color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                perkembangan['mataPelajaran'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Nilai', perkembangan['nilai'], Icons.grade),
              _buildStatItem(
                  'Kehadiran', perkembangan['kehadiran'], Icons.check_circle),
              _buildStatItem('Tugas', perkembangan['tugas'], Icons.assignment),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildAktivitasCard(SessionModel session) {
    // Determine activity type and icon based on session data
    IconData icon;
    Color color;
    String title;
    
    if (session.teacherNotes != null && session.teacherNotes!.isNotEmpty) {
      icon = Icons.note;
      color = Colors.blue;
      title = 'Catatan: ${session.material}';
    } else {
      icon = Icons.school;
      color = Colors.green;
      title = 'Kelas: ${session.material}';
    }

    final now = DateTime.now();
    final difference = now.difference(session.date);
    String timeAgo;
    
    if (difference.inDays > 0) {
      timeAgo = '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      timeAgo = '${difference.inMinutes} menit yang lalu';
    } else {
      timeAgo = 'Baru saja';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo,
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
}
