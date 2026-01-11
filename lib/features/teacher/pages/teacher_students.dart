import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/colors.dart';
import '../widgets/teacher_app_bar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HalamanKelolaAkun extends StatefulWidget {
  const HalamanKelolaAkun({super.key});

  @override
  State<HalamanKelolaAkun> createState() => _HalamanKelolaAkunState();
}

class _HalamanKelolaAkunState extends State<HalamanKelolaAkun> {
  int _selectedMenuIndex = 7;
  final TextEditingController _searchController = TextEditingController();
  String _filterRole = 'Semua';
  final UserRepository _userRepository = UserRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<UserModel> _allUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
  }

  Future<void> _loadAllUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load all users from all roles
      final students = await _userRepository.getUsersByRole('student');
      final parents = await _userRepository.getUsersByRole('parent');
      final teachers = await _userRepository.getUsersByRole('teacher');

      setState(() {
        _allUsers = [...students, ...parents, ...teachers];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TeacherScaffold(
      title: 'Kelola Akun',
      selectedMenuIndex: _selectedMenuIndex,
      onMenuSelected: (index) => setState(() => _selectedMenuIndex = index),
      onNotificationTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifikasi')),
        );
      },
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(_allUsers.length),
                        const SizedBox(height: 24),
                        _buildSearchAndFilter(),
                        const SizedBox(height: 24),
                        _buildAkunList(_allUsers),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(int totalUsers) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.account_circle, color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kelola Data Akun',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: $totalUsers akun terdaftar',
                  style: const TextStyle(
                    fontSize: 14,
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

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Cari nama atau email...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        PopupMenuButton<String>(
          initialValue: _filterRole,
          onSelected: (value) => setState(() => _filterRole = value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list),
                const SizedBox(width: 8),
                Text(_filterRole),
              ],
            ),
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'Semua', child: Text('Semua')),
            const PopupMenuItem(value: 'student', child: Text('Murid')),
            const PopupMenuItem(value: 'parent', child: Text('Orang Tua')),
            const PopupMenuItem(value: 'teacher', child: Text('Guru')),
          ],
        ),
      ],
    );
  }

  Widget _buildAkunList(List<UserModel> users) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Tidak ada akun ditemukan',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    final filteredList = users.where((user) {
      final matchesSearch = user.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesFilter = _filterRole == 'Semua' || user.role == _filterRole;
      return matchesSearch && matchesFilter;
    }).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final user = filteredList[index];
        return _buildAkunCard(user);
      },
    );
  }

  Widget _buildAkunCard(UserModel user) {
    final roleName = user.role == 'student'
        ? 'Murid'
        : user.role == 'parent'
            ? 'Orang Tua'
            : 'Guru';
    final roleIcon = user.role == 'student'
        ? Icons.school
        : user.role == 'parent'
            ? Icons.family_restroom
            : Icons.person;
    final roleColor = user.role == 'student'
        ? Colors.blue
        : user.role == 'parent'
            ? Colors.green
            : Colors.orange;

    final verificationColor = user.verificationStatus == 'verified'
        ? Colors.green
        : user.verificationStatus == 'rejected'
            ? Colors.red
            : Colors.orange;

    final verificationText = user.verificationStatus == 'verified'
        ? 'Terverifikasi'
        : user.verificationStatus == 'rejected'
            ? 'Ditolak'
            : 'Menunggu';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: roleColor.withOpacity(0.1),
          radius: 28,
          backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child: user.photoUrl == null
              ? Icon(roleIcon, color: roleColor, size: 28)
              : null,
        ),
        title: Text(
          user.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    roleName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: roleColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: verificationColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    verificationText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: verificationColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'detail',
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 20, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  const Text('Detail'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline,
                      size: 20, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  const Text('Hapus'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'detail') {
              _showDetailDialog(user);
            } else if (value == 'delete') {
              _showDeleteDialog(user);
            }
          },
        ),
      ),
    );
  }

  void _showDetailDialog(UserModel user) {
    final roleName = user.role == 'student'
        ? 'Murid'
        : user.role == 'parent'
            ? 'Orang Tua'
            : 'Guru';
    final roleIcon = user.role == 'student'
        ? Icons.school
        : user.role == 'parent'
            ? Icons.family_restroom
            : Icons.person;
    final roleColor = user.role == 'student'
        ? Colors.blue
        : user.role == 'parent'
            ? Colors.green
            : Colors.orange;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: roleColor.withOpacity(0.1),
              backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child: user.photoUrl == null
                  ? Icon(roleIcon, color: roleColor)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                user.name,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.email, 'Email', user.email),
            _buildDetailRow(Icons.phone, 'No. HP', user.phone.isNotEmpty ? user.phone : '-'),
            _buildDetailRow(Icons.badge, 'Role', roleName),
            _buildDetailRow(
              Icons.verified_user,
              'Status Verifikasi',
              user.verificationStatus == 'verified'
                  ? 'Terverifikasi'
                  : user.verificationStatus == 'rejected'
                      ? 'Ditolak'
                      : 'Menunggu',
            ),
            _buildDetailRow(
              Icons.calendar_today,
              'Tanggal Daftar',
              '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
            ),
            if (user.verifiedAt != null)
              _buildDetailRow(
                Icons.check_circle,
                'Tanggal Verifikasi',
                '${user.verifiedAt!.day}/${user.verifiedAt!.month}/${user.verifiedAt!.year}',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Hapus Akun'),
          ],
        ),
        content: Text(
            'Apakah Anda yakin ingin menghapus akun "${user.name}"? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                if (user.userId == null) {
                  throw Exception('User ID tidak valid');
                }

                // Delete from Firestore
                await _userRepository.deleteUser(user.userId!);

                // Reload data
                await _loadAllUsers();

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Akun "${user.name}" berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
