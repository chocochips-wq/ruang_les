import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/colors.dart';
import '../widgets/student_drawer.dart';
import '../widgets/student_bottom_nav.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../core/models/progress_model.dart';
import '../../../core/models/student_model.dart';

class StudentRewardsPage extends StatefulWidget {
  const StudentRewardsPage({super.key});

  @override
  State<StudentRewardsPage> createState() => _StudentRewardsPageState();
}

class _StudentRewardsPageState extends State<StudentRewardsPage> {
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

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return DateFormat('d MMM y', 'id_ID').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const DrawerMurid(),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Penghargaan Saya',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _studentId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<StudentProgressModel?>(
              stream:
                  _progressRepository.streamProgressByStudentId(_studentId!),
              builder: (context, progressSnapshot) {
                final progress = progressSnapshot.data;
                // Fallback dummy if no progress yet (or create empty model)
                final totalPoints = progress?.experiencePoints ?? 0;
                final currentLevel = progress?.currentLevel ?? 1;

                return StreamBuilder<List<AchievementModel>>(
                  stream: _progressRepository
                      .streamAchievementsByStudentId(_studentId!),
                  builder: (context, achievementSnapshot) {
                    final achievements = achievementSnapshot.data ?? [];
                    final unlockedBadgesCount = achievements
                        .where((a) => a.isUnlocked && a.category == 'badge')
                        .length;
                    final unlockedStickersCount = achievements
                        .where((a) => a.isUnlocked && a.category == 'sticker')
                        .length;

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          // Header with stats
                          _buildHeaderSection(totalPoints, unlockedBadgesCount,
                              unlockedStickersCount, currentLevel),

                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Badges section
                                _buildBadgesSection(achievements),
                                const SizedBox(height: 24),

                                // Recent achievements
                                _buildRecentAchievements(achievements),
                                const SizedBox(height: 24),

                                // Coming soon notice
                                _buildComingSoonNotice(),
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
      bottomNavigationBar: const FooterMurid(selectedIndex: 3),
    );
  }

  Widget _buildHeaderSection(
      int totalPoints, int badgeCount, int stickerCount, int level) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Trophy icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Total Poin',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalPoints',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(Icons.workspace_premium, '$badgeCount', 'Badge'),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatItem(Icons.star, '$stickerCount', 'Stiker'),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatItem(Icons.flag, '$level', 'Level'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesSection(List<AchievementModel> achievements) {
    // Filter only badges
    final badges = achievements.where((a) => a.category == 'badge').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lencana Saya',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        if (badges.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Column(
              children: [
                Icon(Icons.info_outline, color: Colors.grey, size: 40),
                SizedBox(height: 10),
                Text(
                  'Belum ada lencana yang tersedia.\nTerus belajar untuk membukanya!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        else
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: badges.map((achievement) {
              // Determine color based on title/category logic or random/fixed if not stored
              // Since color isn't in model, we can infer or cycle
              Color color = Colors.blue;
              if (achievement.title.toLowerCase().contains('juara'))
                color = Colors.orange;
              if (achievement.title.toLowerCase().contains('rajin'))
                color = Colors.blue;
              if (achievement.title.toLowerCase().contains('hebat'))
                color = Colors.green;
              if (achievement.title.toLowerCase().contains('bintang'))
                color = Colors.amber;

              // Parse icon string if it's not a standard material icon code (assuming emoji or simple string now)
              // Since the model says 'icon' string (emoji or url), we handle it.
              // For now, if it's an emoji string, just display it. Only use IconData if we mapped it.

              return _buildBadgeCard(
                achievement.icon,
                achievement.title,
                color,
                achievement.isUnlocked,
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildBadgeCard(
      String iconString, String label, Color color, bool isUnlocked) {
    // Helper to detect if iconString is emoji or trying to be an IconData (needs mapping if so)
    // Assuming simple emoji for MVP or fallback icon

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked ? color.withOpacity(0.3) : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUnlocked ? color.withOpacity(0.1) : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Text(
              iconString.isNotEmpty ? iconString : '🏆',
              style: TextStyle(
                  fontSize: 32,
                  color: isUnlocked
                      ? null
                      : Colors.grey
                          .withOpacity(0.5) // Emoji color blending? Not really.
                  // Emoji grayscale is hard, maybe opacity
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isUnlocked ? AppColors.textDark : Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!isUnlocked)
            Icon(
              Icons.lock,
              size: 14,
              color: Colors.grey.shade400,
            ),
        ],
      ),
    );
  }

  Widget _buildRecentAchievements(List<AchievementModel> achievements) {
    // Show unlocked achievements sorted by date
    final recent = achievements.where((a) => a.isUnlocked).toList();
    // Already sorted by query, but double check
    recent.sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));
    final displayList = recent.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pencapaian Terbaru',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            if (displayList.isNotEmpty)
              Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (displayList.isEmpty)
          const Text('Belum ada pencapaian terbaru.',
              style: TextStyle(color: Colors.grey)),
        ...displayList.map((a) {
          Color color = Colors.blue;
          if (a.title.toLowerCase().contains('juara')) color = Colors.orange;
          if (a.title.toLowerCase().contains('bintang')) color = Colors.amber;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildAchievementCard(
              a.icon,
              a.title,
              a.description,
              color,
              _formatTimeAgo(a.unlockedAt),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAchievementCard(
    String iconString,
    String title,
    String description,
    Color color,
    String time,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              iconString.isNotEmpty ? iconString : '🏆',
              style: const TextStyle(fontSize: 28),
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
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonNotice() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade50,
            Colors.blue.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.celebration,
            size: 48,
            color: Colors.purple.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Fitur Lengkap Segera Hadir!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Kami sedang mengembangkan sistem penghargaan yang lebih interaktif dengan animasi, stiker, dan hadiah menarik!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
