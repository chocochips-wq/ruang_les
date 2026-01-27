import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/routes.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../data/repositories/class_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/models/student_model.dart';
import '../../../core/models/class_model.dart';
import '../../../core/models/session_model.dart';
import '../widgets/parent_drawer.dart';
import '../widgets/parent_bottom_nav.dart';
import 'package:provider/provider.dart';
import '../providers/parent_provider.dart';

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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Anak Saya',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showAddChildDialog(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.add, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text('Tambah',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Children List - Real-time
                if (_parentId != null)
                  StreamBuilder<List<StudentModel>>(
                    stream:
                        _studentRepository.streamStudentsByParentId(_parentId!),
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
                    stream:
                        _studentRepository.streamStudentsByParentId(_parentId!),
                    builder: (context, studentsSnapshot) {
                      if (!studentsSnapshot.hasData ||
                          studentsSnapshot.data!.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      final studentIds = studentsSnapshot.data!
                          .map((s) => s.studentId)
                          .whereType<String>()
                          .toList();

                      return FutureBuilder<List<ClassModel>>(
                        future: Future.wait(
                          studentIds.map((id) =>
                              _classRepository.getClassesByStudentId(id)),
                        ).then(
                            (lists) => lists.expand((list) => list).toList()),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
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
        final sessions =
            await _sessionRepository.getSessionsByClassId(classModel.classId!);

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
        final averageScore =
            75 + (attendancePercentage ~/ 10); // Simplified calculation
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
    } else if (subjectLower.contains('bahasa') ||
        subjectLower.contains('english')) {
      return Colors.green;
    } else if (subjectLower.contains('fisika') ||
        subjectLower.contains('physics')) {
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
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.orangtuaLaporan,
                arguments: anak,
              );
            },
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

  void _showAddChildDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final linkFormKey = GlobalKey<FormState>();
    String fullName = '';
    String nickname = '';
    String linkEmail = '';
    int selectedTabIndex = 0;
    bool isLinking = false;

    // Default values
    String selectedLevel = 'SD';
    String selectedClassNumber = '1';
    String? selectedClassId;

    // Helper to get category for class filtering
    String getGradeCategory(String level, String number) {
      if (level == 'TK') return 'TK';
      if (level == 'SMP') return 'SMP';
      if (level == 'SMA') return 'SMA';

      // For SD
      int n = int.tryParse(number) ?? 1;
      if (n <= 3) return 'SD 1-3';
      return 'SD 4-6';
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final gradeCategory =
              getGradeCategory(selectedLevel, selectedClassNumber);

          return AlertDialog(
            title: const Text('Tambah Anak'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tab buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedTabIndex = 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: selectedTabIndex == 0
                                        ? AppColors.primary
                                        : Colors.grey[300]!,
                                    width: selectedTabIndex == 0 ? 2 : 1,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Buat Profil',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: selectedTabIndex == 0
                                      ? AppColors.primary
                                      : Colors.grey,
                                  fontWeight: selectedTabIndex == 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedTabIndex = 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: selectedTabIndex == 1
                                        ? AppColors.primary
                                        : Colors.grey[300]!,
                                    width: selectedTabIndex == 1 ? 2 : 1,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Tautkan Akun',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: selectedTabIndex == 1
                                      ? AppColors.primary
                                      : Colors.grey,
                                  fontWeight: selectedTabIndex == 1
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tab content
                    if (selectedTabIndex == 0) ...[
                      // Create new profile tab
                      Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Nama Lengkap',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              onChanged: (v) => fullName = v,
                              validator: (v) => v?.isEmpty ?? true
                                  ? 'Nama harus diisi'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Nama Panggilan',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              onChanged: (v) => nickname = v,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: DropdownButtonFormField<String>(
                                    value: selectedLevel,
                                    items: ['TK', 'SD', 'SMP']
                                        .map((g) => DropdownMenuItem(
                                            value: g, child: Text(g)))
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        setState(() {
                                          selectedLevel = v;
                                          if (v == 'SMP') {
                                            int current = int.tryParse(
                                                    selectedClassNumber) ??
                                                1;
                                            if (current < 7)
                                              selectedClassNumber = '7';
                                          } else if (v == 'SD') {
                                            int current = int.tryParse(
                                                    selectedClassNumber) ??
                                                7;
                                            if (current > 6)
                                              selectedClassNumber = '1';
                                          }
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Jenjang',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: DropdownButtonFormField<String>(
                                    value: selectedClassNumber,
                                    items: [
                                      '1',
                                      '2',
                                      '3',
                                      '4',
                                      '5',
                                      '6',
                                      '7',
                                      '8',
                                      '9'
                                    ].map((g) {
                                      return DropdownMenuItem(
                                          value: g, child: Text(g));
                                    }).toList(),
                                    onChanged: selectedLevel == 'TK'
                                        ? null
                                        : (v) {
                                            if (v != null) {
                                              setState(() {
                                                selectedClassNumber = v;
                                                int n = int.parse(v);
                                                if (n >= 7 && n <= 9) {
                                                  selectedLevel = 'SMP';
                                                } else if (n >= 1 && n <= 6) {
                                                  selectedLevel = 'SD';
                                                }
                                              });
                                            }
                                          },
                                    decoration: InputDecoration(
                                      labelText: 'Kelas',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Jenis Kelas (Opsional)',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'P', child: Text('Privat (P)')),
                                DropdownMenuItem(
                                    value: 'SP',
                                    child: Text('Semi Privat (SP)')),
                                DropdownMenuItem(
                                    value: 'R', child: Text('Reguler (R)')),
                              ],
                              onChanged: (v) =>
                                  setState(() => selectedClassId = v),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Link existing account tab
                      Form(
                        key: linkFormKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Masukkan email akun siswa yang sudah terdaftar untuk menautkannya ke akun Anda.',
                              style:
                                  TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Email Akun Siswa',
                                hintText: 'contoh@email.com',
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (v) => linkEmail = v,
                              validator: (v) {
                                if (v?.isEmpty ?? true)
                                  return 'Email harus diisi';
                                if (!v!.contains('@'))
                                  return 'Email tidak valid';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              if (selectedTabIndex == 0)
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final fullGrade = selectedLevel == 'TK'
                          ? 'TK'
                          : '$selectedLevel - Kelas $selectedClassNumber';

                      _createChildAccount(
                        fullName: fullName,
                        nickname: nickname,
                        gradeLevel: fullGrade,
                        classType: selectedClassId,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Simpan'),
                )
              else
                ElevatedButton(
                  onPressed: isLinking
                      ? null
                      : () async {
                          if (linkFormKey.currentState!.validate()) {
                            setState(() => isLinking = true);
                            final parentProvider =
                                context.read<ParentProvider>();
                            final success = await parentProvider
                                .linkStudentByEmail(linkEmail);
                            setState(() => isLinking = false);

                            if (success) {
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Akun siswa berhasil ditautkan!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(parentProvider.error ??
                                        'Gagal menautkan akun'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                  child: isLinking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Tautkan'),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _createChildAccount({
    required String fullName,
    required String nickname,
    required String gradeLevel,
    String? classType,
  }) async {
    if (_parentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Parent ID not found')),
      );
      return;
    }

    try {
      final studentId =
          FirebaseFirestore.instance.collection('students').doc().id;

      final student = StudentModel(
        studentId: studentId,
        userId:
            studentId, // Use studentId as placeholder userId for non-auth students
        parentId: _parentId!,
        fullName: fullName,
        nickname: nickname.isNotEmpty ? nickname : fullName.split(' ').first,
        gradeLevel: gradeLevel,
        classType: classType, // Store P, SP, or R
        createdAt: DateTime.now(),
        // Default values for others
        learningLevel: 1,
        totalPoints: 0,
        badges: [],
      );

      // Save to students collection
      await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .set(student.toMap());

      // CRITICAL FIX: Also create user entry for verification notification
      final currentUser = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('users').doc(studentId).set({
        'email': currentUser?.email ?? 'no-email@temp.com', // Temporary email
        'name': fullName,
        'role': 'student',
        'phone': '', // No phone for data-only accounts
        'verificationStatus': 'pending', // Will trigger teacher verification
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'verifiedAt': null,
        'verifiedBy': null,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Data anak berhasil ditambahkan dan menunggu verifikasi guru'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error membuat data anak: $e')),
      );
    }
  }
}
