import 'package:flutter/material.dart';
import '../../../core/models/progress_model.dart';
import '../../../core/utils/colors.dart';

class StudentProgressCard extends StatelessWidget {
  final StudentProgressModel? progress;

  const StudentProgressCard({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    if (progress == null) {
      return const SizedBox.shrink();
    }

    final percentage = progress!.getProgressPercentage();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${progress!.currentLevel}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Kemajuan Belajar',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                // Level indicator icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '⭐',
                      style: TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pengalaman',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${progress!.experiencePoints}/${progress!.maxExperiencePoints} XP',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress bar background
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Stack(
                    children: [
                      // Progress fill
                      Container(
                        width: double.infinity * percentage,
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: '📚',
                  label: 'Topik',
                  value: progress!.completedTopics.length.toString(),
                ),
                _buildStatItem(
                  icon: '✅',
                  label: 'Aktivitas',
                  value: progress!.completedActivities.length.toString(),
                ),
                _buildStatItem(
                  icon: '🎯',
                  label: 'Level Max',
                  value: '${progress!.currentLevel}/${progress!.maxLevel}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class AchievementBadges extends StatelessWidget {
  final List<AchievementModel> achievements;
  final int? maxDisplay;

  const AchievementBadges({
    super.key,
    required this.achievements,
    this.maxDisplay,
  });

  @override
  Widget build(BuildContext context) {
    final displayAchievements = maxDisplay != null
        ? achievements.take(maxDisplay!).toList()
        : achievements;

    if (displayAchievements.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Belum ada pencapaian. Mulai belajar untuk membuka lencana! 🎯',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pencapaian Mu 🏆',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: displayAchievements
                .map((achievement) => AchievementBadgeItem(
                      achievement: achievement,
                    ))
                .toList(),
          ),
          if (maxDisplay != null && achievements.length > maxDisplay!)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Center(
                child: Text(
                  'dan ${achievements.length - maxDisplay!} lencana lainnya',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AchievementBadgeItem extends StatelessWidget {
  final AchievementModel achievement;

  const AchievementBadgeItem({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${achievement.title}\n${achievement.description}',
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: achievement.isUnlocked
              ? AppColors.primary.withOpacity(0.1)
              : Colors.grey[300],
          border: Border.all(
            color: achievement.isUnlocked ? AppColors.primary : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              achievement.icon,
              style: TextStyle(
                fontSize: 28,
                color: achievement.isUnlocked ? null : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              achievement.category == 'badge' ? '⭐' : '✨',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
