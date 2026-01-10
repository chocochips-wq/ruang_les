import 'package:flutter/material.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/routes.dart';
import '../../../data/repositories/user_repository.dart';
import 'teacher_drawer.dart';

class TeacherAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title; // Sekarang optional
  final int selectedMenuIndex;
  final Function(int) onMenuSelected;
  final VoidCallback? onNotificationTap;
  final int? pendingVerificationCount;

  const TeacherAppBar({
    super.key,
    this.title, // Otomatis pakai nama menu jika null
    required this.selectedMenuIndex,
    required this.onMenuSelected,
    this.onNotificationTap,
    this.pendingVerificationCount,
  });

  // Fungsi untuk dapat nama halaman berdasarkan index
  String _getPageTitle() {
    if (title != null) return title!; // Pakai title custom jika ada

    switch (selectedMenuIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Kelola Murid';
      case 2:
        return 'Profile';
      case 3:
        return 'Kelas Saya';
      case 4:
        return 'Quiz';
      case 5:
        return 'Laporan Anak';
      case 6:
        return 'Pembayaran';
      case 7:
        return 'Pengaturan';
      default:
        return 'Ruang Les';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        _getPageTitle(), // Otomatis ambil nama
        style: const TextStyle(
          color: AppColors.textWhite,
          fontWeight: FontWeight.bold,
          fontSize: 19,
        ),
      ),
      backgroundColor: AppColors.primary,
      iconTheme: const IconThemeData(color: AppColors.textWhite),
      actions: [
        // Icon Notifikasi dengan badge pending verifications
        StreamBuilder<int>(
          stream: UserRepository()
              .streamPendingUsers(roles: ['student', 'parent'])
              .map((users) => users.length),
          builder: (context, snapshot) {
            final count = snapshot.data ?? pendingVerificationCount ?? 0;
            return IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications),
                  if (count > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: onNotificationTap ??
                  () {
                    // Default action - arahkan ke halaman verifikasi jika ada callback
                    if (onNotificationTap == null) {
                      Navigator.pushNamed(context, AppRoutes.pengajarVerifikasi);
                    }
                  },
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Scaffold wrapper untuk teacher
class TeacherScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final int selectedMenuIndex;
  final Function(int) onMenuSelected;
  final VoidCallback? onNotificationTap;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const TeacherScaffold({
    super.key,
    this.title,
    required this.body,
    required this.selectedMenuIndex,
    required this.onMenuSelected,
    this.onNotificationTap,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TeacherAppBar(
        title: title,
        selectedMenuIndex: selectedMenuIndex,
        onMenuSelected: onMenuSelected,
        onNotificationTap: onNotificationTap,
      ),
      drawer: TeacherDrawer(
        selectedMenuIndex: selectedMenuIndex,
        onMenuSelected: onMenuSelected,
      ),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
