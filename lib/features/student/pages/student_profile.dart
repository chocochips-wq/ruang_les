import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/data_seeding_dialog.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../data/repositories/progress_repository.dart';
import '../widgets/student_drawer.dart';
import '../widgets/student_bottom_nav.dart';
import '../widgets/student_progress_widget.dart';

class ProfileMurid extends StatefulWidget {
  const ProfileMurid({super.key});

  @override
  State<ProfileMurid> createState() => _ProfileMuridState();
}

class _ProfileMuridState extends State<ProfileMurid> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StudentRepository _studentRepository = StudentRepository();
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

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser?.uid;

    return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          title: const Text('Profil Kamu',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
          iconTheme: const IconThemeData(color: Colors.white),
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
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final userData = userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
                  final userName = userData['name'] ?? 'Siswa';
                  final phone = userData['phone'] ?? '';

                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('students')
                        .doc(_studentId)
                        .snapshots(),
                    builder: (context, studentSnapshot) {
                      if (studentSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final studentData =
                          studentSnapshot.data?.data() as Map<String, dynamic>? ?? {};
                      final fullName = studentData['fullName'] ?? '';
                      final gradeLevel = studentData['gradeLevel'] ?? '';
                      final avatarUrl = studentData['avatarUrl'];
                      final badges = List<String>.from(studentData['badges'] ?? []);
                      final totalPointsValue = studentData['totalPoints'];
                      final totalPoints = totalPointsValue is int 
                          ? totalPointsValue 
                          : (totalPointsValue is num ? totalPointsValue.toInt() : 0);

                      // Calculate statistics
                      final completedTasks = (totalPoints / 10).round(); // Simplified
                      final averageScore = totalPoints > 0 ? (80 + (totalPoints % 20)) : 0;

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildHeader(userName, fullName, gradeLevel, avatarUrl),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  // Show realtime progress from Firestore
                                  StreamBuilder(
                                    stream: _progressRepository
                                        .streamProgressByStudentId(_studentId!),
                                    builder: (context, progressSnapshot) {
                                      final progress = progressSnapshot.data;
                                      if (progress != null) {
                                        return StudentProgressCard(
                                          progress: progress,
                                        );
                                      } else {
                                        return _buildProgressSection(
                                            completedTasks, averageScore);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  // Show realtime achievements
                                  StreamBuilder(
                                    stream: _progressRepository
                                        .streamUnlockedAchievements(
                                            _studentId!),
                                    builder: (context, achievementSnapshot) {
                                      final achievements =
                                          achievementSnapshot.data ?? [];
                                      return AchievementBadges(
                                        achievements: achievements,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  _buildInfoCard(userName, phone, gradeLevel),
                                  const SizedBox(height: 20),
                                  _buildActionButtons(),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
        ),
        bottomNavigationBar: const FooterMurid(selectedIndex: 2));
  }

  Widget _buildHeader(
      String userName, String fullName, String gradeLevel, String? avatarUrl) {
    final displayName = fullName.isNotEmpty ? fullName : userName;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, bottom: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white,
                  backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl) as ImageProvider
                      : const AssetImage('assets/gambar/profile.png'),
                ),
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        )
                      ],
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: AppColors.primary, size: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.school, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  gradeLevel.isNotEmpty ? gradeLevel : 'Belum ada kelas',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(int completedTasks, int averageScore) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '📊 ',
                style: TextStyle(fontSize: 24),
              ),
              Text(
                'Perkembanganmu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressItem('Tugas Selesai', completedTasks, 30, Colors.green),
          const SizedBox(height: 16),
          _buildProgressItem('Nilai Rata-rata', averageScore, 100, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, int value, int max, Color color) {
    double percentage = value / max;
    if (percentage > 1.0) percentage = 1.0;
    if (percentage < 0.0) percentage = 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              '$value/$max',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 12,
            backgroundColor: Colors.grey[200]!,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildBadges(List<String> badges) {
    // Default badges if empty
    final defaultBadges = badges.isEmpty
        ? [
            {'title': 'Siswa Aktif', 'icon': '🏆', 'color': const Color(0xFFFFD700)},
            {'title': 'Rajin Belajar', 'icon': '📚', 'color': const Color(0xFF2196F3)},
          ]
        : badges.map((badge) {
            // Map badge names to icons and colors
            if (badge.toLowerCase().contains('aktif')) {
              return {
                'title': badge,
                'icon': '🏆',
                'color': const Color(0xFFFFD700)
              };
            } else if (badge.toLowerCase().contains('rajin') ||
                badge.toLowerCase().contains('belajar')) {
              return {
                'title': badge,
                'icon': '📚',
                'color': const Color(0xFF2196F3)
              };
            } else if (badge.toLowerCase().contains('juara') ||
                badge.toLowerCase().contains('quiz')) {
              return {
                'title': badge,
                'icon': '⭐',
                'color': const Color(0xFF4CAF50)
              };
            } else {
              return {
                'title': badge,
                'icon': '🎖️',
                'color': const Color(0xFF9C27B0)
              };
            }
          }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '🎖️ ',
                style: TextStyle(fontSize: 24),
              ),
              Text(
                'Badge Kamu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: (defaultBadges.take(3) as List<Map<String, dynamic>>)
                .map((badge) {
              return Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: (badge['color'] as Color).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: badge['color'] as Color,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        badge['icon'] as String,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 80,
                    child: Text(
                      badge['title'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String name, String phone, String gradeLevel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '👤 ',
                style: TextStyle(fontSize: 24),
              ),
              Text(
                'Tentang Kamu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSimpleInfoRow('👤', 'Nama', name),
          const SizedBox(height: 12),
          _buildSimpleInfoRow('📞', 'No. Telepon',
              phone.isNotEmpty ? phone : 'Belum diisi'),
          const SizedBox(height: 12),
          _buildSimpleInfoRow('📖', 'Kelas',
              gradeLevel.isNotEmpty ? gradeLevel : 'Belum ada kelas'),
        ],
      ),
    );
  }

  Widget _buildSimpleInfoRow(String emoji, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600]!,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildBigButton(
          'Ubah Profil',
          Icons.edit,
          Colors.blue,
          () {},
        ),
        const SizedBox(height: 12),
        _buildBigButton(
          'Butuh Bantuan?',
          Icons.help_outline,
          Colors.green,
          () {},
        ),
        const SizedBox(height: 12),
        // Seed data button (development only)
        _buildBigButton(
          'Seed Data (Dev)',
          Icons.data_usage,
          Colors.purple,
          () {
            showDialog(
              context: context,
              builder: (context) => FutureBuilder(
                future: Future.delayed(Duration.zero),
                builder: (context, snapshot) {
                  return const DataSeededDialog();
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBigButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
