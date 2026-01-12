import 'package:flutter/material.dart';
import '../../../core/utils/colors.dart';
import '../../../core/models/progress_model.dart';

class RewardDialog extends StatefulWidget {
  final AchievementModel achievement;
  final VoidCallback? onClose;

  const RewardDialog({
    super.key,
    required this.achievement,
    this.onClose,
  });

  @override
  State<RewardDialog> createState() => _RewardDialogState();
}

class _RewardDialogState extends State<RewardDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Celebration particles (text emojis)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Text('🎉', style: TextStyle(fontSize: 20)),
                      Text('✨', style: TextStyle(fontSize: 20)),
                      Text('🎊', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Achievement icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.achievement.icon,
                        style: const TextStyle(fontSize: 60),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Luar Biasa! 🌟',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Achievement name
                  Text(
                    widget.achievement.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    widget.achievement.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Points earned
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.amber,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '⭐',
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+${widget.achievement.points} XP',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Close button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onClose?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Lanjut Belajar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RewardSnackBar extends StatefulWidget {
  final AchievementModel achievement;

  const RewardSnackBar({
    super.key,
    required this.achievement,
  });

  @override
  State<RewardSnackBar> createState() => _RewardSnackBarState();
}

class _RewardSnackBarState extends State<RewardSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              widget.achievement.icon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Pencapaian Baru!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.achievement.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '+${widget.achievement.points}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MotivationalMessage extends StatefulWidget {
  final String message;
  final Duration duration;

  const MotivationalMessage({
    super.key,
    required this.message,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<MotivationalMessage> createState() => _MotivationalMessageState();
}

class _MotivationalMessageState extends State<MotivationalMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeInQuart),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.blue[200]!,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '💪',
                style: TextStyle(fontSize: 36),
              ),
              const SizedBox(height: 8),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// List of motivational messages
const List<String> motivationalMessages = [
  'Hebat! Kamu semakin pintar! 🌟',
  'Luar biasa! Terus semangat! 🚀',
  'Kamu adalah bintang! ⭐',
  'Jenius! Kerjakan lagi! 🎯',
  'Sempurna! Lanjutkan! 💯',
  'Fantastis! Kamu hebat sekali! 🎉',
  'Terbaik! Bangga dengan kamu! 👏',
];

String getRandomMotivationalMessage() {
  return motivationalMessages[
      DateTime.now().millisecond % motivationalMessages.length];
}
